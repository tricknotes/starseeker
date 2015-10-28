Rails.application.routes.draw do
  root to: 'root#index'
  resource 'dashboard', only: %w(show), controller: 'dashboard'
  namespace :settings do
    resource 'email', only: %w(show update) do
      member do
        get 'send_confirmation'
      end
    end
  end

  get 'hot_repositories' => 'activities#starring', as: :hot_repositories
  get 'stars/:username' => 'stars#index', as: 'stars'
  get 'stars/:username.private.:format' => 'activities#feed', as: 'feed'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'sessions/activate/:activation_token' => 'sessions#activate', as: 'activate'
  delete 'logout' => 'sessions#destroy'
end
