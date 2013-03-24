module DevFlow
  class Task

    def as_title header = ' '
      name = self.display_name
      name = self.display_name.bold if self.is_workable?
      name = self.display_name.blue if self.progress > 0
      name = self.display_name.green if self.is_completed?
      name = self.display_name.magenta if self.is_urgent?
      name = self.display_name.red if self.is_delayed?

      if self.progress > 0 and self.progress < 100
        on_branch = sprintf "(=> %s, %02d%%)", self.branch_name.bold, self.progress
      end

      title = sprintf("%s[%s]%s%s", '  '*(self.level-1), header, name, on_branch)
    end

    ## a task is completable if all children complated
    def is_completable?
      return false if self.is_completed? 
      self.children.each do |child|
        return false unless child.is_completed?
      end
      true
    end

    ## a task is workable (can be started) if all children
    # task and dependent task are completed
    def is_workable?
      # trivial: if already completed, do not start again
      return false if self.is_completed?
      return false if self.is_pending or self.is_deleted

      self.dependencies.each do |t|
        return false unless t.is_completed?
      end

      self.children.each do |t|
        return false unless t.is_completed?
      end
      true
    end
    
  end
end
