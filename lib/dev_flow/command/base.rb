require_relative '../helpers'

# Develop Flow Management Tool Based on Git
module DevFlow
  # Name space for command handlers
  module Command
    # Common operations for all command
    class Base
      include DevFlow::Helpers

      # Receive and save arguments and options from the command line
      def initialize(args, options)
        DevFlow.init args, options
        say "(in #{DevFlow.dir.bold})" unless DevFlow.dir == Dir.pwd
      end

      # Common hook upon command initializing
      def before_run
        fail 'please run `dw config` first' unless configured?
      end

      # Default run methods prints a PENDING message
      def run!
        before_run
        say 'Not implemented yet'
      end

      # configuration related
      def configured?
        DevFlow.git.config('whoami') && DevFlow.git.config('backbone')
      end
    end
  end
end
