Rails.application.routes.draw do
  get "clean_up/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :admin do
    resources :clean_ups, only: %i[index new create show] do
      member do
        post "change_status", to: "clean_ups#change_status"
      end
    end
  end

  root to: redirect("/go")
  get "go" => "participations#new", as: :new_participation
  get "go/:id" => "participations#show", as: :show_participation
  resources :participations, only: %i[create update]
end
