# Develop Flow Management Tool Based on Git
module DevFlow
  # Configuration for dev_flow
  class Config
    attr_reader :dir, :data
    include DevFlow::Helpers

    def initialize(dir = nil)
      @dir = dir
      @dir = find_git_directory unless @dir

      fail 'Can not find .git directory under \
           current directory and all upper directories' unless @dir
      dd "use #{@dir.bold} as the working directory" unless @dir == Dir.pwd
    end

    def find_git_directory
      return Dir.pwd if File.directory?(File.join(Dir.pwd, '.git'))

      # find upper directories recursively
      pwd_parts = Dir.pwd.split(File::SEPARATOR) unless @dir
      while pwd_parts.size > 0
        pwd_parts.pop
        cdir = pwd_parts.join(File::SEPARATOR)
        return cdir if File.directory?(File.join(cdir, '.git'))
      end
    end
  end
end
