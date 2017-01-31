# name: discourse-user-feedback
# about: A discourse plugin that allow users to give feedback each other
# version: 0.1
# authors: Jafeth Díaz

enabled_site_setting :user_feedback_enabled

register_asset 'stylesheets/user-feedback.scss'

def plugin_require(path)
  require Rails.root.join('plugins', 'discourse-user-feedback', 'app', path).to_s
end

after_initialize do
  plugin_require 'initializers/user-feedback'

  plugin_require 'routes/user-feedback'
  plugin_require 'routes/discourse'

  plugin_require 'controllers/ratings_controller'

=begin
  class UserFeedback::Rating
    class << self
      def add(target_user_id, origin_user_id, score, comment)
        id = SecureRandom.hex(16)
        record = { id: id, target_user_id: target_user_id, origin_user_id: origin_user_id, score: score, comment: comment }

        ratings = PluginStore.get(UserFeedback::PLUGIN_NAME, UserFeedback::STORE_NAME) || {}

        ratings[id] = record
        PluginStore.set(UserFeedback::PLUGIN_NAME, UserFeedback::STORE_NAME, ratings)

        record
      end

      def received()

      end

      def given()

      end
    end
  end
=end
end