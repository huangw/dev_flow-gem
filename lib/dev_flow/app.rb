require 'yaml'
require 'logger'
class String; include Term::ANSIColor end

module DevFlow
  attr_accessor :config, :roadmap, :logger, :command, :girc
  class App
    def initialize config, command
      @config, @command = config, command

      if @config[:members_file] and File.exists? (@config[:members_file])
        @config = @config.merge(YAML.load(File.open(@config[:members_file], 'r:utf-8').read)) 
      end

      if @config[:local_config] and File.exists? (@config[:local_config])
        @config = @config.merge(YAML.load(File.open(@config[:local_config], 'r:utf-8').read)) 
      end

      if @config[:roadmap] and File.exists? (@config[:roadmap])
        @roadmap = RoadMap.new(@config[:roadmap], @config).parse 
        @config = @roadmap.config
      end

      @girc = Girc::Console.new

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
      @logger.formatter = proc { |severity, datetime, progname, msg|
        "#{msg.to_s}\n"
      }
    end

    def all_member_names
      @config["members"] ? @config["members"].keys : []
    end

    def user
      wi = @config["whoami"]
      if wi and @config["members"] and @config["members"][wi] and @config["members"][wi][0]
        @config["members"][wi][0]
      else
        wi
      end
    end

  end
end
