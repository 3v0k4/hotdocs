Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "root#index"

  get "quickstart", to: "root#quickstart"
  get "embedded", to: "root#embedded"
  get "standalone", to: "root#standalone"

  get "components", to: "root#components"
  get "nav", to: "root#nav"
  get "menu", to: "root#menu"
  get "table-of-contents", to: "root#toc", as: "toc"
  get "markdown", to: "root#markdown"
  get "search", to: "root#search"
  get "static-export", to: "root#static_export"
  get "light-dark", to: "root#light_dark"
  get "footer", to: "root#footer"
  get "microcomponents", to: "root#microcomponents"
end
