Discourse::Application.routes.append do
  mount ::UserFeedback::Engine, at: '/user-feedback', as: 'ratings'
end