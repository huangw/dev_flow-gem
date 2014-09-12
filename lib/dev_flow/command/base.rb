# Develop Flow Management Tool Based on Git
module DevFlow
  # Name space for command handlers
  module Command
    # Common operations for all command
    class Base
      # Receive and save arguments and options from the command line
      def initialize(args, options)
        DevFlow.init args, options
      end

      # Common hook upon command initializing
      def before_run
        @config = DevFlow::Config.new
      end

      # Default run methods prints a PENDING message
      def run!
        before_run
        say 'Not implemented yet'
      end
    end
  end
end
