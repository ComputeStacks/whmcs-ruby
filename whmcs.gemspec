# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whmcs/version'

Gem::Specification.new do |spec|
  spec.name          = "whmcs"
  spec.version       = Whmcs::VERSION
  spec.authors       = ["Kris Watson"]
  spec.email         = ["kris@computestacks.com"]

  spec.summary       = ""
  spec.description   = ""
  spec.homepage      = ""

  spec.add_dependency "httparty", "~> 0.17"
  spec.add_dependency "php-serialization", "~> 1.0.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "pry", ">= 0.10.0"
end
