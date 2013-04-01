module DevFlow
  class Cleanup < App

    def process!
      completed_branches = Array.new
      @roadmap.tasks.each {|t| completed_branches << t.branch_name if t.is_completed?}
      
      @git.branches.each do |t|
        if completed_branches.include? t
          print "delete completed branch #{t}? [Y/n]:"
          ans = STDIN.gets.chomp!
          unless ans == 'n'
            `git branch -d #{t}`
          end
        end
      end

      info "prune git remote (delete zoombie remote refs)"
      `git remote prune #{@config["git_remote"]}`
    end

  end # class
end
