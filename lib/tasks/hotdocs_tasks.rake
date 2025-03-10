namespace :hotdocs do
  desc "Install HotDocs into the app"
  task :install do
    previous_location = ENV["LOCATION"]
    ENV["LOCATION"] = File.expand_path("../install/install.rb", __dir__)
    Rake::Task["app:template"].invoke
    ENV["LOCATION"] = previous_location
  end
end
