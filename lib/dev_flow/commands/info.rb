module DevFlow
  class Info < App

    def process
      self.hello
      self.ask_rebase
      puts self.hr

      current_task = self.task

      if self.i_am_leader and self.need_to_close.size > 0
        self.display_close_waiting
      else
        self.display_tasks
      end

      # special treatment for release branches
      if current_task and current_task.is_release
        if self.i_am_leader
          puts "You are on a release branch".bold.red
          puts "You may should release it before swtitch to other tasks.".bold.red
        else
          puts "You do not have the permission to release this branch".bold.red
          if wd_clean? 
            puts "Please switch to other branches".bold.red
          else
            puts "Please undo you edition and switch to other branches".bold.red
          end
        end
        puts hrb
      elsif current_task and current_task.progress == 99 and self.i_am_leader
        puts "You may want to check and review the code and issue "
        puts "    $ dw close".bold.blue
        puts "to mark this task completed."
        puts hrb
      elsif @waiting.size > 0
        puts "You can choose to switch those branches, or press enter to leave"
        print @waiting.keys.join(", ").blue + ":"
        ans = STDIN.gets.chomp!
        # if @waiting[ans]
      else
        puts hrb
      end
    end

    def process!
      self.hello
      self.ask_rebase

      puts hr
      current_task = self.task

      # if i am the leader and there are closed branches, warn:
      if i_am_leader? and tasks_for_close.size > 0
        display_close_waiting
      else
        display_tasks
      end
      puts hrh

      if @git.wd_clean? 
        # if work directory is clean, ready to switch
        if i_am_leader? and in_release? # concentrate
          puts "You are in a release branch, please release it as soon as possible."
        else # otherwise show switch options
          puts "You switch to other branches:"
          puts "Type #{0.to_s.bold} to switch to develop trunk."
          puts "Simply press enter to keep working on the current branch."
          print @waiting.keys.join(", ") + ":"

          ans = STDIN.gets.chomp!
          if ans.to_i == 0
            switch_to! 'develop'
          else
            switch_to! @waiting[ans.to_i].branch_name
          end
        end
      else # if the wd is not clean
        
        if (not i_am_leader?) and current_task and in_release?
          puts "WARN: You are on a release branch, only leader can edit release branches.".yellow
          puts "Please undo you edit. Do not push your edition to the remote server."
          exit
        end

        if (not i_am_leader?) and current_task and current_task.progress == 99
          puts "WARN: You are on a completed branch, call the leader (#{leader_name.bold}) to close it.".yellow
          exit
        end
        
        if current_task
          unless current_task.resources.include? @config["whoami"]
            puts "WARN: You are editing a task not assigned to you.".yellow
            puts hr
          end
        end
        
        # if assigned to you prompt for pg or close or release
      end
      hrb
    end

  end # class
end
