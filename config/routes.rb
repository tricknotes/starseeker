Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if defined?(LetterOpenerWeb)

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
  # The username is passed on to the GitHub API as a path segment, so anything
  # GitHub would not accept as a username (e.g. an encoded "../") must not reach it.
  get 'stars/:username' => 'stars#index', as: 'stars', constraints: { username: /[A-Za-z0-9-]+/ }
  get 'stars/:username.private.:format' => 'activities#feed', as: 'feed'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'sessions/activate/:activation_token' => 'sessions#activate', as: 'activate'
  delete 'logout' => 'sessions#destroy'
end
