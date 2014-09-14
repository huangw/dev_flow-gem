require 'git'
require 'term/ansicolor'
# mixin string to enable term-ansicolor
class String; include Term::ANSIColor end

# Develop Flow Management Tool Based on Git
module DevFlow
  class << self
    attr_accessor :debug
  end
end

# load all other files
require 'dev_flow/version'
require 'dev_flow/helpers'
Dir[File.expand_path('../dev_flow/command/*.rb', __FILE__)].each do |rb|
  require rb
end
