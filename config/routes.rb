Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post "/signup", to: "auth#signup"
      post "/login", to: "auth#login"
      delete "/logout", to: "auth#logout"
      get "/me", to: "auth#me"

      get "me/posts", to: "posts#my_posts"

      resources :posts, only: [ :index, :show, :create, :update, :destroy ]

      resources :users, only: [] do
        resources :posts, only: [ :index ]
      end
    end
  end
end
