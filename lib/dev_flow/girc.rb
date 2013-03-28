module DevFlow
  class Girc
    attr_accessor :git

    def initialize cmd = 'git', v = true
      @git = cmd
      @v = v
    end

    def info msg
      return unless @v
      puts "[GITC] #{msg}" if msg.size > 0
    end

    # general informations
    # -----------------------
    # return modified files (without additions/deletions)
    def modified_files
      files = Array.new
      `#{@git} status`.split("\n").each do |line|
        if /modified\:\s+(?<file_>.+)/ =~ line
          files << File.expand_path(file_)
        end
      end
      files
    end

    # return config list as a hash
    def config
      h = Hash.new
      `#{@git} config --list`.split("\n").each do |line|
        key, value = line.split("=")
        h[key] = value
      end
      h
    end
    
    # return the value of user.name in configuration
    def me
      config["user.name"] || "?"
    end

    # all branches include remote branches
    def branches
      branch_list = Array.new
      `#{@git} branch -a`.split("\n").each do |line|
        line.gsub!('* ', '')
        line.gsub!(/\s/, '')
        branch_list << line unless branch_list.include? line
      end
      branch_list
    end

    # the branch currently working on
    def current_branch
      `#{@git} branch`.split("\n").each do |line|
        if /\*/.match line
          return line.gsub('* ', '')
        end
      end
      nil
    end

    def remote_list
      lst = Array.new
      `#{@git} remote -v`.split("\n").each do |line|
        rn = line.split(/\s+/)[0]
        lst << rn unless lst.include? rn
      end
      lst
    end

    # is the working directory has modified file
    def wd_clean?
      clean = true
      `#{@git} status`.split("\n").each do |line|
        clean = false if /Changes/.match line
      end
      clean
    end

    # whether the current directory is a git working directory
    def in_git_dir?
      `#{@git} status` =~ /fatal/ ? false : true
    end

    # modifications
    # --------------------
    
    # pull from the remote use fetch/merge
    def pull! remote = 'origin'
      cb = self.current_branch
      info "Fetch from #{remote}"
      rslt = `#{@git} fetch #{remote}`
      raise "fetch failed with message: #{rslt}" unless $?.success?
      info rslt
      info `#{@git} merge #{remote}/#{cb}`
    end

    # create a new branch, if remote set, push it to remote too
    # then switch to that branch
    def new_branch! branch, remote=nil
      raise "You need clean up you working directory" unless wd_clean?
      raise "Branch #{branch} already exists" if self.branches.include? branch
      `#{@git} checkout -b #{branch}`
      `#{@git} push #{remote} #{branch}` if remote
    end

    # delete a branch
    def del_branch! branch, remote=nil
      rslt = `#{@git} branch -d #{branch}`
      raise "Cat not delete branch #{branch}: #{rslt}" unless $?.success?
      `#{@git} push #{remote} :#{branch}` if remote
    end

    def stash!
      unless wd_clean?
        info "Save you change to stash"
        `#{@git} add .`
        `#{@git} stash`
      end
    end

    def stash_pop!
      raise "You may clean up you work directroy first before pop out from the stash" unless wd_clean?
      info "Pop out from you last stash"
      `#{@git} stash pop`
    end

    # remote from a specified remote ref
    def rebase! remote = 'origin', branch = 'develop'
      cb = self.current_branch
      stashed = false
      unless self.wd_clean?
        info "Stash your local changes"
        self.stash!
        stashed = true
      end

      if branch == self.current_branch
        info "Pull from remote"
        # `#{@git} pull --rebase #{remote} #{branch}`
        `#{@git} pull #{remote} #{branch}`
      else
        info "pull branch #{self.current_branch} from remote"
        `#{@git} pull #{remote} #{self.current_branch}`
        info "Switch to branch #{branch}"
        `#{@git} fetch #{remote}`
        rslt = `#{@git} checkout #{branch}`
        raise "Checkout failed: #{rslt}" unless $?.success?
        info "Update branch from remote"
        # rslt = `#{@git} pull --rebase #{remote} #{branch}`
        rslt = `#{@git} pull #{remote} #{branch}`
        raise "Pull for #{branch} failed: #{rslt}" unless $?.success?
        info "Switch back to branch #{cb}"
        `#{@git} checkout #{cb}`
        info "Merge from #{branch}"
        rslt = `#{@git} merge #{branch}`
        raise "Merge with #{branch} failed: #{rslt}" unless $?.success?
      end

      self.stash_pop! if stashed
    end

  end
end
