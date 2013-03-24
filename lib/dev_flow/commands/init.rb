module DevFlow
  class Init < App

    def process!
      local_configuration = {}
      if File.exists? @config[:local_config]
        local_configuration = YAML.load(File.open(@config[:local_config], 'r:utf-8').read) || {}
      end

      # find the current user
      sugguest = @config["whoami"] if @config["whoami"]
      unless all_member_names.include? sugguest
        info "use system 'whoami' command to find user name"
        begin
          suggest = `whoami`
        end
        info "found #{suggest}" if all_member_names.include? sugguest
      end

      unless all_member_names.include? sugguest
        info "use git config to find user name"
        sugguest = @git.config["user.email"].gsub(/\@.+$/, '') if @git.config["user.email"]
        info "found #{suggest}" if all_member_names.include? sugguest
      end
      
      # ask the user for the user name
      puts "Tell us who you are: ".bold.yellow
      msg = all_member_names.join(", ")
      if all_member_names.include? sugguest
        msg += " [#{sugguest}]"
      end

      print msg + ":"
      ans = STDIN.gets.chomp!
      ans = sugguest unless ans.size > 0
      error "Unknown member! Can not continue." unless all_member_names.include? ans

      # find the default git remote server
      @config["whoami"] = ans
      info "Welcome #{self.user_name.bold}!"

      remotes = @git.remote_list
      error "You need to set at least one remote git server to interact with!" unless remotes.size > 0

      puts "Which remote git server to use?".bold.yellow
      msg = remotes.join ", "
      
      suggest = @config["git_remote"] || 'origin'
      msg += " [#{suggest}]" if remotes.include? suggest
      print msg + ":"

      ans2 = STDIN.gets.chomp!
      ans2 = suggest unless ans2.size > 0
      error "You must define a valid git remote server" unless remotes.include? ans2

      # write out to the local configuration file
      info "write contents to local configuration file"
      write_local_config(local_configuration.merge({"whoami" => ans, "git_remote" => ans2}))
      add_to_gitignore()
    end

    def write_local_config hash
      wh = File.open(@config[:local_config], 'w:utf-8')
      YAML.dump(hash, wh)
      wh.close
    end

    def add_to_gitignore
      had = false
      if File.exists?(".gitignore")
        fh = File.open(".gitignore")
        fh.each do |line|
          had = true if line =~ /#{@config[:local_config]}/
        end
        fh.close
      end
      
      unless had
        info "add local configuration file to gitignore list"
        wh = File.open(".gitignore", 'a')
        wh.puts @config[:local_config]
        wh.close
      end
    end

  end # class
end
