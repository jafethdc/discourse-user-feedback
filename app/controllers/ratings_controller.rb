class ::UserFeedback::RatingsController < ::ApplicationController
  requires_plugin UserFeedback::PLUGIN_NAME

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { errors: [e.message] }, status: 404
  end

  before_filter :ensure_topic_existence

  def index
    serializer = UserFeedback::FeedbackTopicSerializer
    render json: serializer.new(@feedback_topic, scope: self, root: false).as_json, status: :ok
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

  private

  def ensure_topic_existence
    @user = User.find(params[:user_id])
    feedback_topic_id = @user.custom_fields['feedback_topic_id']
    if feedback_topic_id
      @feedback_topic = Topic.find(feedback_topic_id)
    else
      @feedback_topic = @user.topics.create(title: "discourse-user-feedback#{@user.id}", archetype: :feedback)
      @user.custom_fields['feedback_topic_id'] = @feedback_topic.id
      @user.save_custom_fields
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
end