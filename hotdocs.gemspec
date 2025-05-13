require_relative "lib/hotdocs/version"

Gem::Specification.new do |spec|
  spec.name        = "hotdocs"
  spec.version     = Hotdocs::VERSION
  spec.authors     = [ "3v0k4" ]
  spec.email       = [ "riccardo.odone@gmail.com" ]
  spec.homepage    = "https://hotdocsrails.com/"
  spec.summary     = "Write your docs with Ruby on Rails"
  spec.description = "HotDocs is a set of optimized Rails components & tools for writing docs."
  spec.licenses    = %w[LGPL-3.0 Commercial]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/3v0k4/hotdocs"
  spec.metadata["changelog_uri"] = "https://github.com/3v0k4/hotdocs/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do # rubocop:disable ThreadSafety/DirChdir
    Dir["{app,config,lib}/**/*", "LICENSE*", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.1.0"
  spec.add_dependency "rails", ">= 7.1.0"
  spec.add_dependency "kramdown", "~> 2.5"
  spec.add_dependency "kramdown-parser-gfm"
  spec.add_dependency "rouge", "~> 4.5"
end
