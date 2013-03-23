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

      if @git.wd_clean? 
        # if work directory is clean, ready to switch
        if i_am_leader? and in_release? # concentrate
          puts "You are in a release branch, please release it as soon as possible."
        else # otherwise show switch options
          puts "You switch to other branches (type 0 to switch to develop trunk):"
          print @waiting.keys.join(", ") + ":"

          ans = STDIN.gets.chomp!
          if ans.to_i == 0
            switch_to! 'develop'
          else
            switch_to! @waiting[ans.to_i].branch_name
          end
        end
      else # if the wd is not clean
        # if in a task not assigned to you, warn
        # if you are not the leader and in release or completed branch, warn
        # if assigned to you prompt for pg or close or release
      end
      hrb
    end

  end # class
end
