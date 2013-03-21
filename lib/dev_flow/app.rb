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

        raise "No leader defined for your porject!" unless @config['leader']
      else
        raise "no roadmap file found!"
      end

      @girc = Girc::Console.new 'git', @config[:verbose]

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

    def need_to_close 
      self.roadmap.tasks.select {|task| task.progress == 99}
    end

    # display informations
    # -----------------------
    def hr; "-"*76 end
    def hrb; "="*76 end
     
    def hello
      puts hrb
      puts "Hello, #{user.bold}."
      puts "This is the DevFlow console, version: " + VERSION
      puts hr
      puts "You are on branch #{@girc.current_branch.bold.green}"
      puts "You are the #{'leader'.bold} of the project." if self.i_am_leader
      puts "You are the #{'moderator'.bold} of the project." if self.i_am_moderator
      puts "You are the #{'supervisor'.bold} of the project." if self.i_am_supervisor
    end

    def display_close_waiting
      return false unless self.need_to_close.size > 0
      puts hr
      puts "There have "
      i = 0
      self.need_to_close.each do |task|
        i += 1
        forme = ' '
        forme = '*'.bold.blue if task.resources.include? @config["whoami"]
        puts "[#{i.to_s.bold}]#{forme} " + task.as_title
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
          header = ' ' unless @girc.wd_clean? 
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
      @girc.rebase @config["git_remote"], 'develop'
    end

  end # class
end
