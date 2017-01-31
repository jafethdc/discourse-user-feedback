class ::UserFeedback::RatingsController < ::ApplicationController
  requires_plugin UserFeedback::PLUGIN_NAME

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { errors: [e.message] }, status: 404
  end

  before_filter :ensure_topic_existence

  def index
    render json: @feedback_topic.posts
  end

  private

  def ensure_topic_existence
    @user = User.find(params[:user_id])
    @feedback_topic = @user.topics.where(archetype: :feedback).take
    @feedback_topic ||= @user.topics.create(title: "discourse-user-feedback#{@user.id}", archetype: :feedback, visible: false)
  end
end