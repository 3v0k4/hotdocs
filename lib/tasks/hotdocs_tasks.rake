namespace :hotdocs do
  desc "Install HotDocs into the app"
  task :install do
    location = File.expand_path("../install/install.rb", __dir__)
    system("#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{location}")
    # Needed for hotdocs:index to find the generated ::HotdocsController
    Rails.application.reloader.reload!
    Rake::Task["hotdocs:index"].invoke
  end

  desc "Build search data"
  task index: :environment do
    path = Rails.root.join("app/assets/builds/search_data.json")
    # Propshaft caches the `@load_path`s. Rendering data goes through Propshaft
    # because of the assets, so the file must exist before rendering.
    File.write(path, "")
    data = render_search_data.call.to_json
    File.write(path, data)
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance([ "hotdocs:index" ])
end

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance([ "hotdocs:index" ])
elsif Rake::Task.task_defined?("spec:prepare")
  Rake::Task["spec:prepare"].enhance([ "hotdocs:index" ])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance([ "hotdocs:index" ])
end

def render_search_data
  renderer = Class.new(::HotdocsController) do
    include Hotdocs::ApplicationHelper

    def call
      with_no_view_annotations { render_search_data }
    end

    private

    def with_no_view_annotations(&)
      annotate = Rails.application.config.action_view.annotate_rendered_view_with_filenames
      Rails.application.config.action_view.annotate_rendered_view_with_filenames = false
      yield
    ensure
      Rails.application.config.action_view.annotate_rendered_view_with_filename = annotate
    end

    def render_search_data
      pages = pages_from(menu_items)
      $stderr.puts "Indexing #{pages.size} pages:"
      render_pages(pages).tap { $stderr.puts }
    end

    def render_pages(pages)
      pages.filter_map do |page|
        $stderr.putc "."
        html = render_path(page.fetch(:url))
        next unless html
        { **page, html: html }
      end
    end

    def pages_from(menu_items, parent = "Docs")
      menu_items
        .filter { _1.fetch(:url).start_with?("/") }
        .flat_map do |item|
          current = { title: item.fetch(:label), parent: parent, url: item.fetch(:url) }
          children = pages_from(item.fetch(:children, []), item.fetch(:label))
          [ current ] + children
        end
    end

    def render_path(path)
      base = ENV.fetch("RAILS_RELATIVE_URL_ROOT", "")
      baseless_path = path.sub(/\A#{base}/, "")
      controller, action = Rails.application.routes.recognize_path(baseless_path).values_at(:controller, :action)
      render_to_string("#{controller}/#{action}", layout: false)
    rescue ActionController::RoutingError => error
      logger.info("Skipped building #{path}: #{error}")
      nil
    end

    def request
      ActionDispatch::TestRequest.create
    end
  end

  renderer.new
end
