require 'yaml'

module DevFlow
  attr_accessor :config, :roadmap, :logger, :command
  class App
    def initialize config, command
      @config, @command = config, command

      if File.exists? (@config[:members_file])
        @config.merge(YAML.load(File.open(@config[:members_file], 'r:utf-8').read)) 
      end

      if File.exists? (@config[:local_config])
        @config.merge(YAML.load(File.open(@config[:local_config], 'r:utf-8').read)) 
      end

      if File.exists? (@config[:roadmap])
        # fh = File.open(@config[:roadmap], 'r:utf-8')
        # TODO: load roadmap, @config.merge roadmap.config
        
      end

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
      @logger.formatter = proc { |severity, datetime, progname, msg|
        "#{msg.to_s}\n"
      }

    end

    def all_members

    end
  end
end
