module DevFlow
  class Init < App

    def process!
      raise "No known members defined!" unless all_member_names.size > 0
        
      sugguest = @config["whoami"] if @config["whoami"]
      begin
        suggest = `whoami` unless all_member_names.include? sugguest
      end

      unless all_member_names.include? sugguest
        sugguest = @girc.config["user.email"].gsub(/\@.+$/, '') if @girc.config["user.email"]     
      end
      
      puts "Known members: " + all_member_names.join(", ")
      msg = "Tell us who you are: "
      if all_member_names.include? sugguest
        msg += "[#{sugguest}]"
      end

      print msg
      ans = STDIN.gets.chomp!

      ans = sugguest unless ans.size > 0
      raise "Unknown member!" unless all_member_names.include? ans

      write_local_config({"whoami" => ans})
      add_to_gitignore()

      @config["whoami"] = ans
      puts "Welcome #{self.user.bold}!"
    end

    def write_local_config hash
      wh = File.open(@config[:local_config], 'w:utf-8')
      hash.each do |k,v|
        wh.puts "#{k}: #{v}"
      end
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
