module DevFlow

  class App
    attr_accessor :config, :roadmap, :logger, :command, :git, :members, :sugguests

    def initialize config, command
      @config, @commnad = config, command

      # initialize logger
      @logger = Logger.new(STDOUT)
      @logger.level = config[:verbose] ? Logger::INFO : Logger::WARN
      @logger.formatter = proc {|severity, datetime, progname, msg| "#{msg.to_s}\n"}

      # initialize git console
      @git = DevFlow::Girc.new 'git', config[:verbose]
      error "Please use dw in a git directory" unless @git.in_git_dir?

      # load configurations
      if @config[:members_file] and File.exists? (@config[:members_file])
        info "Load member information form #{@config[:members_file]}"
        @config = @config.merge(YAML.load(File.open(@config[:members_file], 'r:utf-8').read))
      else
        warn "No member file to load"
      end

      if @config[:local_config] and File.exists? (@config[:local_config])
        info "Load local configuration from #{@config[:local_config]}"
        @config = @config.merge(YAML.load(File.open(@config[:local_config], 'r:utf-8').read)) 
      end
      
      # load roadmap, reload config 
      if @config[:roadmap] and File.exists? (@config[:roadmap])
        info "Load roadmap from #{@config[:roadmap]}"
        @roadmap = RoadMap.new(@config[:roadmap], @config).parse 
        @config = @roadmap.config

        error "No leader defined for your porject!" unless @config['leader']
      end

      # convert member list to member name=>object hash
      @members = Hash.new
      @config["members"].each do |name, ary|
        @members[name] = Member.new(name, *ary)
      end
      error "No known members defined!" unless all_member_names.size > 0

      error "You (#{user_name}) are not in the known member list. You may use 'dw init' to setup the working environment." unless all_member_names.include? @config["whoami"]

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

    def in_release?
      task.is_release?
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

    # display informations
    # -----------------------
    def hr; "-"*76 end
    def hrh; hr.bold end
    def hrb; "="*76 end
    def hrbh; hrb.bold end
     
    def hello
      puts hrbh
      puts "Hello, #{user_name.bold}."
      puts "This is the DevFlow console, version: " + VERSION
      puts hrh
      puts "You are on branch #{@git.current_branch.bold.green}"
      puts "You task is: #{self.task.display_name.bold}" if self.task
      puts "You are the #{'leader'.bold} of the project." if self.i_am_leader
      puts "You are the #{'moderator'.bold} of the project." if self.i_am_moderator
      puts "You are the #{'supervisor'.bold} of the project." if self.i_am_supervisor
    end
#
    def display_close_waiting
      return false unless self.need_to_close.size > 0
      puts hrh
      puts "There have tasks marked 99% progress and need to be reviewed:"
      i = 0
      self.need_to_close.each do |task|
        i += 1
        if @git.wd_clean?
          puts "[#{i.to_s.bold}] " + task.as_title
          @waiting[i] = task
        else
          puts "[ ] " + task.as_title
        end
      end
    end

    def display_tasks
      i = 0
      j = 0
      remain = 0
      @roadmap.tasks.each do |task|
        next if task.parent and task.parent.is_completed?
        next if task.is_pending? or task.is_deleted?
        if i > 16 # only show 16 task lines at most
          remain += 1
          next
        end
        forme = ''
        forme = '*'.bold.blue if task.resources.include? @config["whoami"]
        
        header = nil
        header = '+'.bold.green if task.is_completed? 
        header = '-' unless header or task.is_workable?
        unless header
          j += 1
          header = j.to_s.bold
          header = ' ' unless @git.wd_clean? 
          @waiting[j] = task if @git.wd_clean? 
        end
        
        puts task.as_title(header) + forme
        i += 1
      end
    end

    # interactive methods with git remote server
    # ------------------------------------------------------
    def ask_rebase
      return false if @config[:offline]
      print "Rebase your wokring directory? [Y/n]:".bold.yellow
      ans = STDIN.gets.chomp!
      return false if ans == 'n'

      # do the rebase:
      puts "rebase you working directory from #{@config["git_remote"]}/devleop"
      @git.rebase! @config["git_remote"], 'develop'
    end

  end # class
end
