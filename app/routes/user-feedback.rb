UserFeedback::Engine.routes.draw do
  resources :ratings, path: 'u/:user_id', only: [:index, :create]
end
