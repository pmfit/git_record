require_relative "lib/local_record/version"

Gem::Specification.new do |spec|
  spec.name        = "local_record"
  spec.version     = LocalRecord::VERSION
  spec.authors     = [""]
  spec.email       = [""]
  spec.homepage    = "https://github.com/pmfit/local_record"
  spec.summary     = "A Rails gem for sourcing models from the filesystem"
  spec.description = "A Rails gem for sourcing models from the filesystem"
    spec.license     = "MIT"
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pmfit/local_record"
  spec.metadata["changelog_uri"] = "https://github.com/pmfit/local_record/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.4.3"
  spec.add_dependency "kramdown"
  spec.add_dependency "front_matter_parser"
  spec.add_dependency "htmlentities"
end
