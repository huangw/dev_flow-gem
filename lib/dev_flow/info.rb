module DevFlow
  class Info < App

    def process!
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

  end # class
end
