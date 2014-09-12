# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dev_flow/version'

Gem::Specification.new do |spec|
  spec.name          = "dev_flow"
  spec.version       = DevFlow::VERSION
  spec.authors       = ["Huang Wei"]
  spec.email         = ["huangw@7lime.com"]
  spec.summary       = %q{Develop Flow Management Tool Based on Git.}
  spec.description   = %q{Develop Flow Management Tool Based on Git.}
  spec.homepage      = "https://github.com/huangw/dev_flow-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "commander", "~> 4.2"
  spec.add_dependency "term-ansicolor", "~> 1.3"
  spec.add_dependency "git", "~> 1.2"
  spec.add_dependency "gitlab", "~> 3.2"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake" #, "~> 10.3"
  spec.add_development_dependency "yard" #, "~> 0.8"
  spec.add_development_dependency "guard" #, "~> 2.6"
  spec.add_development_dependency "rubocop" #, "~> 0.25"
  spec.add_development_dependency "guard-rubocop" #, "~> 1.1"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec" #, "~> 4.3"
end
