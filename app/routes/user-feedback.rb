UserFeedback::Engine.routes.draw do
  resources :ratings, path: 'users/:user_id', only: [:index, :create]
end