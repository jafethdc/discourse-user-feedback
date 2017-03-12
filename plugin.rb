# name: discourse-user-feedback
# about: A discourse plugin that allow users to give feedback each other
# version: 0.1
# authors: Jafeth Díaz
# url: https://github.com/JafethDC/discourse-user-feedback

enabled_site_setting :user_feedback_enabled

register_asset 'stylesheets/user-feedback.scss'

def plugin_require(path)
  require Rails.root.join('plugins', 'discourse-user-feedback', 'app', path).to_s
end

after_initialize do
  plugin_require 'initializers/user-feedback'

  plugin_require 'routes/user-feedback'
  plugin_require 'routes/discourse'

  plugin_require 'models/guardian'
  plugin_require 'models/user_action'

  plugin_require 'serializers/rating_serializer'

  plugin_require 'controllers/ratings_controller'

  User.register_custom_field_type('feedback_topic_id', :integer)

  if SiteSetting.user_feedback_enabled
    add_to_serializer(:user, :feedback_topic_id, false) {
      object.custom_fields['feedback_topic_id']
    }

    # We could reuse UserActionSerializer, but rating is not a property applicable to all the user actions...
    # add_to_serializer(:user_action, :rating, false) {
    #   Post.find(object.post_id).custom_fields['feedback_rating']
    # }
  end


end