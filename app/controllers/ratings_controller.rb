class ::UserFeedback::RatingsController < ::ApplicationController
  requires_plugin UserFeedback::PLUGIN_NAME

  before_filter :ensure_topic_existence

  def index
    per_chunk = 30
    offset = params[:offset].to_i

    opts = { user_id: @user.id,
             user: @user,
             target_topic_id: @feedback_topic.id,
             offset: offset,
             limit: per_chunk,
             action_types: [UserAction::REPLY],
             guardian: guardian,
             ignore_private_messages: true }

    stream = UserAction.ratings(opts).to_a
    render_serialized(stream, UserFeedback::RatingSerializer, root: 'user_actions')
  end

  def create
    rating = PostCreator.new(current_user, rating_params).create
    if rating.persisted?
      action = UserAction.where(target_post_id: rating.id, action_type: UserAction::REPLY).first

      if SiteSetting.user_feedback_notifications_enabled
        data = {
            topic_title: @user.username,
            original_post_id: rating.id,
            original_post_type: rating.post_type,
            original_username: rating.username,
            display_username: rating.username,
            message: 'user_feedback.notification'
        }
        Notification.create!(user_id: @user.id,
                             notification_type: Notification.types[:custom],
                             #topic_id: rating.topic_id,
                             post_number: rating.post_number,
                             data: data.to_json)
      end

      render_serialized(UserAction.ratings(action_id: action.id).first, UserFeedback::RatingSerializer)
    else
      render json: { errors: rating.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Create a first post, otherwise the first rating will be omitted
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