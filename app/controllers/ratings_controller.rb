class ::UserFeedback::RatingsController < ::ApplicationController
  requires_plugin UserFeedback::PLUGIN_NAME

  before_filter :ensure_topic_existence

  def index
    per_chunk = 30
    offset = params[:offset].to_i
    help_key = params['no_results_help_key']

    opts = { user_id: @user.id,
             user: @user,
             target_topic_id: @feedback_topic.id,
             offset: offset,
             limit: per_chunk,
             action_types: [UserAction::REPLY],
             guardian: guardian,
             ignore_private_messages: true }

    stream = UserAction.ratings(opts).to_a

    if stream.length == 0 && help_key
      if @user.id == guardian.user.try(:id)
        help_key += ".self"
      else
        help_key += ".others"
      end
      render json: {
          user_action: [],
          no_results_help: I18n.t(help_key)
      }
    else
      render_serialized(stream, UserActionSerializer, root: 'user_actions')
    end

  end

  def create
    rating = PostCreator.new(current_user, rating_params).create
    if rating.persisted?
      # We could notify the user here
      serializer = UserFeedback::RatingSerializer
      render json: serializer.new(rating, scope: self, root: false).as_json , status: :created
    else
      render json: { errors: 'Unable to create or update post' }, status: :unprocessable_entity
    end
  end

  UserAction.instance_eval do
    def ratings(opts)
      opts ||= {}

      action_types = opts[:action_types]
      target_topic_id = opts[:target_topic_id]
      offset = opts[:offset] || 0
      limit = opts[:limit] || 60

      # The weird thing is that target_post_id can be null, so it makes everything
      #  ever so more complex. Should we allow this, not sure.
      builder = SqlBuilder.new <<-SQL
        SELECT
          a.id,
          t.title, a.action_type, a.created_at, t.id topic_id,
          t.closed AS topic_closed, t.archived AS topic_archived,
          a.user_id AS target_user_id, au.name AS target_name, au.username AS target_username,
          coalesce(p.post_number, 1) post_number, p.id as post_id,
          p.reply_to_post_number,
          pu.username, pu.name, pu.id user_id,
          pu.uploaded_avatar_id,
          u.username acting_username, u.name acting_name, u.id acting_user_id,
          u.uploaded_avatar_id acting_uploaded_avatar_id,
          coalesce(p.cooked, p2.cooked) cooked,
          CASE WHEN coalesce(p.deleted_at, p2.deleted_at, t.deleted_at) IS NULL THEN false ELSE true END deleted,
          p.hidden,
          p.post_type,
          p.action_code,
          p.edit_reason,
          t.category_id
        FROM user_actions as a
        JOIN topics t on t.id = a.target_topic_id
        LEFT JOIN posts p on p.id = a.target_post_id
        JOIN posts p2 on p2.topic_id = a.target_topic_id and p2.post_number = 1
        JOIN users u on u.id = a.acting_user_id
        JOIN users pu on pu.id = COALESCE(p.user_id, t.user_id)
        JOIN users au on au.id = a.user_id
        LEFT JOIN categories c on c.id = t.category_id
        /*where*/
        /*order_by*/
        /*offset*/
        /*limit*/
      SQL

      builder.where("a.action_type in (:action_types)", action_types: action_types) if action_types && action_types.length > 0
      builder.where("a.target_topic_id = :target_topic_id", target_topic_id: target_topic_id)
      builder
          .order_by("a.created_at desc")
          .offset(offset.to_i)
          .limit(limit.to_i)

      builder.map_exec(UserAction::UserActionRow)
    end
  end

  private

  # Create a first post, if not the first rating will be omitted
  def ensure_topic_existence
    @user = User.find_by(id: params[:user_id])
    raise Discourse::NotFound if @user.blank?

    feedback_topic_id = @user.custom_fields['feedback_topic_id']
    if feedback_topic_id
      @feedback_topic = Topic.find_by(id: feedback_topic_id)
    else
      create_feedback_topic
    end
  end

  def rating_params
    {
        topic_id:         @feedback_topic.id,
        raw:              params[:raw],
        custom_fields:    { feedback_rating: params[:rating] },
        skip_validations: true
    }
  end

  def create_feedback_topic
    @feedback_topic = @user.topics.create(title: "Feedback: User #{@user.username}", archetype: :feedback)
    @user.custom_fields['feedback_topic_id'] = @feedback_topic.id
    @user.save_custom_fields
    PostCreator.new(@user, topic_id: @feedback_topic.id, raw: "This is a topic for all the ratings of #{@user.username}", skip_validations: true).create
  end
end