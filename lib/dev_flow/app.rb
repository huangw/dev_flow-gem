module DevFlow

  class App
    attr_accessor :config, :roadmap, :logger, :command, :git, :members, :sugguests

    def initialize config, command
      @config, @commnad = config, command

      # initialize logger
      @logger = Logger.new(STDOUT)
      @logger.level = config[:verbose] ? Logger::INFO : Logger::WARN
      @logger.formatter = proc {|severity, datetime, progname, msg| "#{msg.to_s}\n"}

      # load configurations
      if @config[:members_file] and File.exists? (@config[:members_file])
        @config = @config.merge(YAML.load(File.open(@config[:members_file], 'r:utf-8').read)) 
      end

      if @config[:local_config] and File.exists? (@config[:local_config])
        @config = @config.merge(YAML.load(File.open(@config[:local_config], 'r:utf-8').read)) 
      end
      
      # load roadmap, reload config 
      if @config[:roadmap] and File.exists? (@config[:roadmap])
        @roadmap = RoadMap.new(@config[:roadmap], @config).parse 
        @config = @roadmap.config

        error "No leader defined for your porject!" unless @config['leader']
      end

      # convert member list to member name=>object hash
      @members = Hash.new
      @config["members"].each do |name, ary|
        @members[name] = Member.new(name, *ary)
      end

      # suggest user to take those tasks
      @sugguests = Hash.new
    end

    # log message handler
    # ------------------------------
    def error msg
      @logger.fatal msg.bold.red
      exit
    end

    def warn msg
      @logger.warn msg.yellow
    end

    def info msg
      @logger.info msg
    end

    # helper function
    # ------------------------------
    def all_member_names
      @members.keys
    end

    def user_name
      wi = @config["whoami"]
      @members[wi] ? @members[wi].display_name : wi
    end

    def task
      @roadmap.tasks.each do |task|
        return task if task.branch_name == @git.current_branch
      end
      nil
    end

    def in_trunk?
      %w[master develop staging production].include? @git.current_branch
    end

    def i_am_leader
      @config["whoami"] and @config["leader"] == @config["whoami"]
    end

    def i_am_moderator
      @config["whoami"] and @config["moderator"] == @config["whoami"]
    end

    def i_am_supervisor
      @config["whoami"] and @config["supervisor"] == @config["whoami"]
    end

    def i_have_power
      [@config["leader"], @config["supervisor"], @config["moderator"]].include? @config["whoami"]
    end

    def tasks_for_close 
      @roadmap.tasks.select {|task| task.progress == 99}
    end

  end # class
end
