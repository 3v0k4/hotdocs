namespace :hotdocs do
  desc "Install HotDocs into the app"
  task :install do
    location = File.expand_path("../install/install.rb", __dir__)
    system("#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{location}")
  end
end
