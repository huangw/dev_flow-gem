require_relative 'base'
# Develop Flow Management Tool Based on Git
module DevFlow
  # Name space for command handlers
  module Command
    # Display or update dev_flow options
    class Config < Base
      # disable fail for non-configuration reasons
      def before_run; end

      def run!
        case DevFlow.args.size
        when 0 then DevFlow.user ? show! : setup!
        when 1 then say DevFlow.get_config(DevFlow.args[0])
        when 2 then DevFlow.git.config(key(DevFlow.args[0]), DevFlow.args[1])
        else
          fail "too many argument (#{DevFlow.args.join(', ')})"
        end
      end

      def show!

      end

      def setup!
        setup_user! unless DevFlow.user
      end

      private

      def setup_user!

      end
    end # class Config
  end
end
