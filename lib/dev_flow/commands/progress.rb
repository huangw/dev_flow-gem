module DevFlow
  class Progress < App

    def process!
      self.hello

      # whether I am working on a proper task branch
      current_task = self.task
      error "Not on a known task branch. Can not continue." unless current_task
      
      self.ask_rebase
      puts hr

      # commit you current branch and push
      progress = ARGV[1]
      progress = progress.to_i if progress
      
      unless (progress and progress > 0 and progress < 99)
        if progress
          error "invalid progress. Use percentage between 1 to 98."
        else
          puts "Current progress for task #{current_task.to_s.bold} is #{current_task.progress.to_s.bold}."
        end
      end

      warn "draw back complete percentage from #{current_task.progress.to_s.bold} to #{progress.to_s.bold}" if current_task.progress > progress

      message = ARGV[2] || "update progress to #{progress}"
      message = "[progress] " + message

      info "commit your progress"
      `git commit -am '#{message}'`
      if sync?
        info "push your progress to remote server"
        `git push #{@config["git_remote"]} #{current_task.branch_name}`
      else
        warn "your change did not pushed to the remote server."
      end
      
      # rewrite progress in ROADMAP file under develop trunk
      upload_progress! current_task, progress
    end

  end # class
end
