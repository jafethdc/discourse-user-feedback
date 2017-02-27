class ::UserFeedback::RatingSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :name,
             :username,
             :user_deleted,
             :avatar_template,
             :cooked,
             :raw,
             :post_number,
             :topic_id,
             :created_at,

  def avatar_template
    object.user.try(:avatar_template)
  end

  def name
    object.user.try(:name)
  end

  def username
    object.user.try(:username)
  end
end