# name: discourse-user-feedback
# about: A discourse plugin that allow users to give feedback each other
# version: 0.1
# authors: Jafeth Díaz
# url: https://github.com/JafethDC/discourse-user-feedback

register_asset 'stylesheets/user-feedback.scss'

enabled_site_setting :user_feedback_enabled

def plugin_require(path)
  require Rails.root.join('plugins', 'discourse-user-feedback', 'app', path).to_s
end

after_initialize do
  plugin_require 'initializers/user-feedback'

  plugin_require 'routes/user-feedback'
  plugin_require 'routes/discourse'

  plugin_require 'controllers/ratings_controller'

  plugin_require 'serializers/feedback_topic_serializer'
  plugin_require 'serializers/rating_serializer'

  plugin_require 'models/guardian'

  User.register_custom_field_type('feedback_topic_id', :integer)
  Post.register_custom_field_type('feedback_rating', :integer)

  if SiteSetting.user_feedback_enabled
    add_to_serializer(:user, :feedback_topic_id, false) {
      object.custom_fields['feedback_topic_id']
    }

    # This might not be necessary: custom_fields is included in the serializer by default
    add_to_serializer(:user, :custom_fields, false) {
      object.custom_fields.nil? ? {} : object.custom_fields
    }

    add_to_serializer(:post, :feedback_rating, false){
      object.custom_fields['feedback_rating']
    }

    add_to_serializer(:post, :custom_fields, false){
      object.custom_fields.nil? ? {} : object.custom_fields
    }
  end


end