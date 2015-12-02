$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'dev_flow/version'

Gem::Specification.new 'dev_flow', DevFlow::VERSION do |s|
  s.description       = "dev_flow is a bundle of tools for ROADMAP/git based development flow control."
  s.summary           = "a bundle of tools for ROADMAP/git based development flow control."
  s.authors           = ["Huang Wei"]
  s.email             = "huangw@pe-po.com"
  s.homepage          = "https://github.com/huangw/dev_flow-gem"
  s.files             = `git ls-files`.split("\n") - %w[.gitignore]
  s.executables       << "dw"
  s.test_files        = Dir.glob("{spec,test}/**/*.rb")
  s.rdoc_options      = %w[--line-numbers --inline-source --title DevFlow --main README.rdoc --encoding=UTF-8]

  s.add_dependency 'term-ansicolor', '~> 1.3'    # for colorful command line display
  s.add_dependency 'erubis', '~> 2.7'
  s.add_development_dependency 'rspec', '~> 2.5'
end

