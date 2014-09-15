require 'git'
require 'term/ansicolor'
# mixin string to enable term-ansicolor
class String; include Term::ANSIColor end

# Develop Flow Management Tool Based on Git
module DevFlow
  # save global options as module level attributes:
  class << self
    attr_accessor :debug
  end
end

# load all other files
require 'dev_flow/version'
require 'dev_flow/helpers'
require 'dev_flow/git_config'
Dir[File.expand_path('../dev_flow/command/*.rb', __FILE__)].each do |rb|
  require rb
end
