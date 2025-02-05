Rails.application.routes.draw do
  get "gigi/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "hotdocs#index"

  get "quickstart", to: "hotdocs#quickstart"
  get "embedded", to: "hotdocs#embedded"
  get "standalone", to: "hotdocs#standalone"

  get "components", to: "hotdocs#components"
  get "nav", to: "hotdocs#nav"
  get "table-of-contents", to: "hotdocs#toc", as: "toc"
  get "markdown", to: "hotdocs#markdown"
  get "search", to: "hotdocs#search"
  get "static-export", to: "hotdocs#static_export"
  get "light-dark", to: "hotdocs#light_dark"
  get "footer", to: "hotdocs#footer"
  get "microcomponents", to: "hotdocs#microcomponents"
end
