Rails.application.routes.draw do
  get "gigi/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "hot_docs#index"

  get "quickstart", to: "hot_docs#quickstart"
  get "embedded", to: "hot_docs#embedded"
  get "standalone", to: "hot_docs#standalone"

  get "components", to: "hot_docs#components"
  get "nav", to: "hot_docs#nav"
  get "table-of-contents", to: "hot_docs#toc", as: "toc"
  get "markdown", to: "hot_docs#markdown"
  get "search", to: "hot_docs#search"
  get "static-export", to: "hot_docs#static_export"
  get "light-dark", to: "hot_docs#light_dark"
  get "footer", to: "hot_docs#footer"
  get "helpers", to: "hot_docs#helpers"
end
