lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphql/extras/version"

Gem::Specification.new do |spec|
  spec.name          = "graphql-extras"
  spec.version       = GraphQL::Extras::VERSION
  spec.authors       = ["Ray Zane"]
  spec.email         = ["raymondzane@gmail.com"]

  spec.summary       = %q{Utiltities for building GraphQL APIs.}
  spec.description   = %q{A set of modules and types for buildign GraphQL APIs.}
  spec.homepage      = "https://github.com/rzane/graphql-extras"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rzane/graphql-extras"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.2"
  spec.add_dependency "graphql", [">= 1.12", "< 3"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "actionpack"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "sqlite3"
end
