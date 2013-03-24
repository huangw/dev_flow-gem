module DevFlow
  class Complete < App

    def process!
      self.hello

      # whether I am working on a proper task branch
      current_task = self.task
      error "Not on a known task branch. Can not continue." unless current_task
      
      unless current_task.resources.include?(@config[:whoami]) 
        if i_have_power?
          role = 'supervisor' if i_am_supervisor?
          role = 'moderator' if i_am_moderator?
          role = 'leader' if i_am_leader?
          warn "You are complete the task as a #{role}"
        else
          error "You are not in the resource list for that task."
        end      
      end

      self.ask_rebase true # force rebase
      puts hr

      # commit you current branch and push
      progress = 99
      message = ARGV[2] || "complete your branch by set progress to 99."
      message = "[complete] " + message

      info "commit your progress"
      `git commit -am '#{message}'`
      if @config[:git_remote]
        info "push your progress to remote server"
        `git push #{@config[:git_remote]} #{current_task.branch_name}`
      end
      
      # rewrite progress in ROADMAP file under develop trunk
      upload_progress! current_task, progress, true
    end

  end # class
end