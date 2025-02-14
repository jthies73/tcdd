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
        post 'enable_registration', to: 'clean_ups#enable_registration'
        post 'disable_registration', to: 'clean_ups#disable_registration'
        post 'start', to: 'clean_ups#start'
        post 'end', to: 'clean_ups#end'
      end
    end
  end

  root to: redirect("/go")

  get "go" => "participations#new", as: :new_participation

  post "register" => "participations#register", as: :register
  post "start" => "participations#start", as: :start
  post "return" => "participations#return", as: :return

  get "thank-you" => "pages#thank_you", as: :thank_you
end
