require 'git'
require 'term/ansicolor'
# mixin string to enable term-ansicolor
class String; include Term::ANSIColor end

# Develop Flow Management Tool Based on Git
module DevFlow
  class << self
    attr_reader :args, :options, :config

    def init(args, options)
      @args, @options = args, options
    end
  end

  # Helper methods all command use
  module Helpers
    # show debug messages
    def dd(msg)
      say "|#{clean_caller(caller[0]).white}| #{msg}" if DevFlow.options.debug
    end

    private

    def clean_caller(tc)
      tc.sub(%r{\A.+/lib/dev_flow/}, '').sub(/\:in .+\Z/, '')
    end
  end
end

Dir[File.expand_path('../dev_flow/**/*.rb', __FILE__)].each do |rb|
  require rb
end
