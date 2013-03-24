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

      current_task = self.task
      self.ask_rebase if current_task or in_trunk?

      puts hr

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
          puts "You switch to other branches:".bold.yellow
          puts "Type #{0.to_s.bold} to switch to develop trunk."
          puts "Simply press enter to keep working on the current branch."
          print @waiting.keys.join(", ") + ":"

          ans = STDIN.gets.chomp!
          if ans == 0.to_s
            switch_to! 'develop'
          elsif @waiting[ans.to_i]
            switch_to! @waiting[ans.to_i].branch_name
          end
        end
      else # if the wd is not clean
        
        if current_task and in_release?
          if i_am_leader?
            puts "You are in a release branch, if you are ready to release it, use:"
            puts "  $ dw release".bold.blue
          else
            puts "WARN: You are on a release branch, only leader can edit release branches.".yellow
            puts "Please undo you edit. Do not push your edition to the remote server."
          end
          exit
        end

        if current_task and current_task.progress == 99
          if i_am_leader
            puts "You are in a branch marked complete. Please test and review the code, and close it by:"
            puts "  $ dw close".bold.blue
            puts "Or reject the branch by issue:"
            puts "  $ dw progress 60".bold.blue
          else
            puts "WARN: You are on a completed branch, call the leader (#{leader_name.bold}) to close it.".yellow
          end
          exit
        end
        
        if current_task
          unless current_task.resources.include? @config["whoami"]
            puts "WARN: You are editing a task not assigned to you.".yellow
          end

          puts "You are encouraged to push your progress often by:"
          puts "  $ dw progress 40 'git commit message'".bold.blue
          puts "Or use the short version:"
          puts "  $ dw pg 40 'git commit message'".bold.blue
          puts "If you fully implemented and tested the code, issue:"
          puts "  $ dw complete"
          puts "Then #{'do not forget'.bold.red} inform the leader (#{leader_name.bold})."
        else
          puts "You are not on any non-branches. You may commit all you changes and"
          puts "switch to develop trunk before the next move:"
          puts "  $ git commit -am 'git commit message'".bold.blue
          puts "  $ git checkout develop".bold.blue
        end

        if in_trunk?
          if @git.current_branch == 'develop' and i_have_power?
            puts "You should only edit ROADMAP files on develop trunk, when you done, use:"
            puts "  $ dw update-roadmap".bold.blue
            puts "Or use the short version:"
            puts "  $ dw ur".bold.blue
          else
            warn "Avoid directly edit files under trunk branches."
            puts "Please undo you change and switch to work on a task branch."
          end
        end
        
      end
      hrb
    end

  end # class
end
