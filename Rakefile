require "bundler/setup"

APP_RAKEFILE = File.expand_path("website/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

namespace :assets do
  desc "Expose app:assets:precompile to Heroku"
  task :precompile do
    Rake::Task["app:assets:precompile"].invoke
  end
end
