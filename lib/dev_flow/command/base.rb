require_relative '../helpers'

# Develop Flow Management Tool Based on Git
module DevFlow
  # Name space for command handlers
  module Command
    # Common operations for all command
    class Base
      include DevFlow::Helpers
      include DevFlow::GitConfig

      attr_reader :args, :options, :dir, :git

      # Receive and save arguments and options from the command line
      def initialize(args, options, dir = nil)
        @args, @options = args, options
        @dir = find_working_directory(dir)
        fail 'Can not find .git directory under ' \
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

      private

      # find working directory unless explicitly given
      # rubocop:disable CyclomaticComplexity
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
