require 'git'
require 'term/ansicolor'
# mixin string to enable term-ansicolor
class String; include Term::ANSIColor end

# Develop Flow Management Tool Based on Git
module DevFlow
  class << self
    attr_reader :args, :options, :dir, :git

    def init(args, options, dir = nil)
      @args, @options = args, options
      @dir = dir ? dir : find_working_directory

      fail 'Can not find .git directory under \
           current directory and all upper directories' unless @dir
      @git = Git.open(@dir)
    end

    def user
      get_config('user')
    end

    def gitlab
      %w(host private_token).each_with_object({}) do |key, hsh|
        hsh[key] = get_config(key)
      end
    end

    def get_config(arg)
      key = config_key(arg)
      git.config(key) || Git.global_config(key)
    end

    def set_config(arg, value)
      key = config_key(arg)
      if get_config(key)
        git.config(key, value)
        say 'set in local `.git/config`'
      else
        Git.global_config(key, value)
        say 'set git config with --global'
      end
    end

    def set_local_config(arg, value)
      key = config_key(arg)
      git.config(key, value)
    end

    private

    def config_keys
      %w(user gitlab.host gitlab.private_token backbone)
    end

    def config_key(arg)
      key = arg.sub(/\Adw\./, '')
      fail "unknown config key #{arg}" unless config_keys.include?(key)
      "dw.#{key}"
    end

    # find working directory unless explicitly given
    def find_working_directory
      return Dir.pwd if File.directory?(File.join(Dir.pwd, '.git'))

      # find upper directories recursively
      pwd_parts = Dir.pwd.split(File::SEPARATOR) unless @dir
      while pwd_parts.size > 0
        pwd_parts.pop
        cdir = pwd_parts.join(File::SEPARATOR)
        return cdir if File.directory?(File.join(cdir, '.git'))
      end
    end
  end # class << self
end

# load all other files
Dir[File.expand_path('../dev_flow/**/*.rb', __FILE__)].each do |rb|
  require rb
end
