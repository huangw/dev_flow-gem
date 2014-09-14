require_relative '../helpers'

# Develop Flow Management Tool Based on Git
module DevFlow
  # Name space for command handlers
  module Command
    # Common operations for all command
    class Base
      include DevFlow::Helpers
      attr_reader :args, :options, :dir, :git

      # Receive and save arguments and options from the command line
      def initialize(args, options, dir = nil)
        @args, @options = args, options
        @dir = find_working_directory(dir)
        fail 'Can not find .git directory under ' +
             'current directory and all upper directories' unless @dir
        @git = Git.open(@dir)
        say "(in #{@dir.bold})" unless @dir == Dir.pwd

        @git = Git.open(@dir)
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

      # Configuration Attributes
      # -----------------------
      def configured?
        git.config('backbone') && current_user
      end

      def current_user
        get_config('user')
      end

      def get_config(arg)
        key = config_key(arg)
        git.config(key) || Git.global_config(key)
      end

    # def set_config(arg, value)
    #   key = config_key(arg)
    #   if get_config(key)
    #     git.config(key, value)
    #     say 'set in local `.git/config`'
    #   else
    #     Git.global_config(key, value)
    #     say 'set git config with --global'
    #   end
    # end
    #
      # def set_local_config(arg, value)
      #   key = config_key(arg)
      #   git.config(key, value)
      # end

      def config_keys
        %w(user gitlab.host gitlab.private_token backbone)
      end

      def git_config_key(arg)
        key = arg.sub(/\Adw\./, '')
        fail "unknown config key #{arg}" unless config_keys.include?(key)
        "dw.#{key}"
      end

      private

      # find working directory unless explicitly given
      def find_working_directory(dir = nil)
        return dir if dir && File.directory?(File.join(dir, '.git'))
        return Dir.pwd if File.directory?(File.join(Dir.pwd, '.git'))

        # find upper directories recursively
        pwd_parts = Dir.pwd.split(File::SEPARATOR) unless @dir
        while pwd_parts.size > 0
          pwd_parts.pop
          cdir = pwd_parts.join(File::SEPARATOR)
          return cdir if File.directory?(File.join(cdir, '.git'))
        end
      end
    end # class Base
  end
end
