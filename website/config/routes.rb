Rails.application.routes.draw do
  mount Hotdocs::Engine => "/hotdocs"

  root "hotdocs#index"

  get "quickstart", to: "hotdocs#quickstart"
  get "embedded", to: "hotdocs#embedded"
  get "standalone", to: "hotdocs#standalone"

  get "markdown", to: "hotdocs#markdown"
  get "static-export", to: "hotdocs#static_export"

  get "components", to: "hotdocs#components"
  get "announcement", to: "hotdocs#announcement"
  get "nav", to: "hotdocs#nav"
  get "table-of-contents", to: "hotdocs#toc", as: "toc"
  get "search", to: "hotdocs#search"
  get "light-dark", to: "hotdocs#light_dark"
  get "footer", to: "hotdocs#footer"
  get "helpers", to: "hotdocs#helpers"
end
