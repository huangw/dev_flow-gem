module DevFlow
  class Init < App

    def process!

      # find the current user
      raise "No known members defined!" unless all_member_names.size > 0
        
      sugguest = @config["whoami"] if @config["whoami"]
      begin
        suggest = `whoami` unless all_member_names.include? sugguest
      end

      unless all_member_names.include? sugguest
        sugguest = @girc.config["user.email"].gsub(/\@.+$/, '') if @girc.config["user.email"]     
      end
      
      puts "Tell us who you are: ".bold.yellow
      msg = all_member_names.join(", ")
      if all_member_names.include? sugguest
        msg += " [#{sugguest}]"
      end

      print msg + ":"
      ans = STDIN.gets.chomp!

      ans = sugguest unless ans.size > 0
      raise "Unknown member!" unless all_member_names.include? ans

      # find the default git remote server
      @config["whoami"] = ans
      puts "Welcome #{self.user.bold}!"

      remotes = @girc.remote_list
      raise "You need to set at least one remote git server to interact with!" unless remotes.size > 0

      puts "Which remote git server to use?".bold.yellow
      msg = remotes.join ", "
      
      suggest = @config["git_remote"] || 'origin'
      msg += " [#{suggest}]" if remotes.include? suggest
      print msg + ":"

      ans2 = STDIN.gets.chomp!
      ans2 = suggest unless ans2.size > 0
      raise "You must define a valid git remote server" unless remotes.include? ans2

      # write out to the local configuration file
      write_local_config({"whoami" => ans, "git_remote" => ans2})
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
        wh = File.open(".gitignore", 'a')
        wh.puts @config[:local_config]
        wh.close
      end
    end

  end # class
end
