UserFeedback::Engine.routes.draw do
  resources :ratings, path: '/:user_id', only: [:index, :create]
end