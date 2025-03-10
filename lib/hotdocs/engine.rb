require_relative "markdown"

module Hotdocs
  class Engine < ::Rails::Engine
    isolate_namespace Hotdocs

    initializer "hotdocs.importmap", before: "importmap" do |app|
      # https://github.com/rails/importmap-rails#composing-import-maps
      app.config.importmap.paths << Engine.root.join("config/importmap.rb")

      # https://github.com/rails/importmap-rails#sweeping-the-cache-in-development-and-test
      app.config.importmap.cache_sweepers << Engine.root.join("app/assets/javascript")
    end

    config.before_initialize do
      MarkdownHandler.prepare(self)
      ActionView::Template.register_template_handler :mderb, MarkdownHandler.new(self)
    end
  end
end
