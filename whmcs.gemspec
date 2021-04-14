require_relative 'lib/whmcs/version'

Gem::Specification.new do |spec|
  spec.name          = "whmcs"
  spec.version       = Whmcs::VERSION
  spec.authors       = ["Kris Watson"]
  spec.email         = ["kris@computestacks.com"]

  spec.summary       = %q{ WHMCS Integration for ComputeStacks }
  spec.description   = %q{ This provides the basic billing integration for ComputeStacks to communicate with WHMCS. }
  spec.homepage      = "https://github.com/ComputeStacks/whmcs-ruby"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com"
  spec.metadata['github_repo'] = "ssh://github.com/ComputeStacks/whmcs-ruby.git"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '>= 6.1'
  spec.add_runtime_dependency 'faraday', '~> 1'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'minitest-reporters', '> 1'
  spec.add_development_dependency 'vcr', '~> 6'
end
