module DevFlow
  class Ur < App

    def process!
      error "Not on develop trunk" unless @git.current_branch == 'develop'
      error "Only leader/moderator and supervisor can edit ROADMAP" unless i_have_power?
      #p @git.modified_files
      error "No change detected on #{@config[:roadmap]}" unless @git.modified_files.include? File.expand_path(@config[:roadmap])

      `git add .`
      `git commit -am 'update roadmap'`
      info "Push your change to the remote server"
      `git push #{@config[:git_remote]} develop` if @config[:git_remote]
    end

  end # class
end
