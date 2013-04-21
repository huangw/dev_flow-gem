module DevFlow
  class Ur < App

    def process!
      error "Not on the develop trunk" unless @git.current_branch == 'develop'
      error "Only leader/moderator and supervisor can edit ROADMAP" unless i_have_power?

      #p @git.modified_files
      error "No change detected on #{@config[:roadmap]}" unless @git.modified_files.include? File.expand_path(@config[:roadmap])

      `git add ROADMAP`
      msg = ARGV[1] || 'update roadmap'
      `git commit -am '#{msg}'`
      if sync?
        info "Push your change to the remote server"
        `git push #{@config["git_remote"]} develop` 
      else
        warn "Offline update for ROADMAP."
      end
    end

  end # class
end
