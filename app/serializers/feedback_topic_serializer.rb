class ::UserFeedback::FeedbackTopicSerializer <  ActiveModel::Serializer
  attributes :id,
             :title,
             :post_stream,


  def post_stream
    rating_serializer = UserFeedback::RatingSerializer
    array_serializer = ActiveModel::ArraySerializer
    {
        posts: array_serializer.new(object.posts, each_serializer: rating_serializer, scope: scope, root: false),
        stream: object.posts.pluck(:id).sort
    }
  end
end