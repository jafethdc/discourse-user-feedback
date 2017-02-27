require_dependency 'application_controller'

module ::UserFeedback
  PLUGIN_NAME ||= 'user_feedback'.freeze

  class Engine < ::Rails::Engine
    engine_name UserFeedback::PLUGIN_NAME
    isolate_namespace UserFeedback
  end
end

