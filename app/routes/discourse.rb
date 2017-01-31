Discourse::Application.routes.append do
  mount ::UserFeedback::Engine, at: '/ratings', as: 'ratings'
end