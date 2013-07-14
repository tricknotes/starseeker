Starseeker::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resource 'dashboard', only: %w(show), controller: 'dashboard'
  namespace :settings do
    resource 'email', only: %w(show update) do
      member do
        get 'send_confirmation'
      end
    end
  end

  get 'hot_repositories' => 'activities#starring', as: :hot_repositories

  get 'auth/:provider/callback', to: 'oauths#callback' # TODO Rename action

  root to: 'root#index'

  get 'stars/:username' => 'stars#index', as: 'stars'

  get 'stars/:username.private.:format' => 'activities#feed', as: 'feed'

  get 'sessions/activate/:activation_token' => 'sessions#activate', as: 'activate'
  delete 'logout' => 'sessions#destroy'

  # You can have the root of your site routed with "root"
  # root to: 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
