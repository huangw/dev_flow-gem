module DevFlow
  class Close < App

    def process!
      self.hello

      error "Only leader (#{leader_name.bold}) can close a branch." unless i_am_leader?

      # whether I am working on a proper task branch
      current_task = self.task
      error "Not on a known task branch. Can not continue." unless current_task      

      if current_task and (in_release? or current_task.branch_name =~ /^hotfix\_/)
        error "Use command 'release' to close a release/hotfix branch." unless @config[:release]
      else
        error "Use command 'close' to close a non-release branch." if @config[:release]
      end

      if in_release? and @config[:release]
        error "You should use release only on branches just completed." unless current_task and current_task.progress == 99 
      end
      

      self.ask_rebase true # force rebase
      puts hr

      # commit you current branch and push
      progress = 100
      message = ARGV[2] || "close the branch by set progress to 100."
      message = "[close] " + message

      info "commit progress"
      `git commit -am '#{message}'`
      if @config[:git_remote]
        info "push your progress to remote server"
        `git push #{@config[:git_remote]} #{current_task.branch_name}`
      end
      
      # goto develop branch and merge
      `git checkout develop`
      rslt = `git merge --no-ff #{current_task.branch_name}`
      error "Not fast forward merge failed: #{rslt}" unless $?.success?

      # rewrite progress in ROADMAP file under develop trunk
      upload_progress! current_task, progress, true
      
      # merge into the master
      if @config[:release]
        info "Merge the release branch into master trunk"
        `git checkout master`
        `git merge --no-ff develop`
        tag = new_version current_task.branch_name
        if tag
          info "Tag your release as #{tag}"
          `git tag #{tag}`
        end
        info "Push your change to remote server"
        `git push #{@config[:git_remote]} --tags master` if @config[:git_remote]
      end
      
      info "Delete closed branch #{current_task.branch_name}"
      `git branch -d #{current_task.branch_name}`
    end

  end # class
end
