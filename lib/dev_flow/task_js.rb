module DevFlow

  class Task

    def task_id
      self.ln
    end

    def parent_id
      self.parent ? self.parent.task_id : 0 
    end

    def resource_name
      self.resource_names.join ","
    end

    def dependencies_str
      self.dependencies.map {|d| d.task_id}.join ","
    end

    ## color reflects the status of a task, return a hex code without heading "#"
    def color resource_ = nil
      today = DateTime.now.strftime("%Y%m%d").to_i 
      start_day = self.start_date.strftime("%Y%m%d").to_i 
      end_day = self.end_date.strftime("%Y%m%d").to_i 
      hex = "B0C4DE" # light steel blue as default 
      hex = "808080" unless self.is_workable? # grey for no able to start
      hex = "FFD700" if start_day == today and progress == 0 # gold for must start now
      hex = "FFFF00" if self.progress > 0 and self.progress < 100 # blue for working
      hex = "FFA500" if end_day == today and self.progress < 100 # orange for master complete today

      if resource_
        hex = "CCCCCC" unless self.resources.include? resource_
      end
      
      hex = "008000" if self.is_completed?    # green for completed
      hex = "FF0000" if self.progress < 100 and today > end_day   # red for not completed on time 
      hex = "FF0000" if self.progress == 0 and today > start_day  # red for late start
      hex = "EEE8AA" if self.is_deleted?
      hex = "C0C0C0" if self.is_pending?
     #  puts hex + ":" + self.progress.to_s + ";" + DateTime.now.strftime("%Y%m%d") + ":" + self.start_date.strftime("%Y%m%d")
      hex
    end

    def caption 
      return "" if self.children.size > 0
      cap = self.resource_name
      cap = sprintf("Pending (%s)", cap) if self.is_pending?
      cap = sprintf("Deleted (%s)", cap) if self.is_deleted?
      if self.is_completed?
        cap += self.completed_at.strftime("%F")
      else
        cap += sprintf(':%02d\%', self.progress) if self.progress > 0
      end
      cap
    end

    def as_js resource
      is_milestone_flag = self.is_milestone? ? 1 : 0
      is_parent_flag = self.is_parent? ? 1 : 0
      task_str = "    g.AddTaskItem(new JSGantt.TaskItem(%d,'%s','%s','%s','%s','%s',%d,'%s',%d,%d,%d,%d,'%s','%s'));\n"
      sprintf(task_str, self.task_id, self.display_name, 
              self.start_date.strftime("%m/%d/%Y"), 
              self.end_date.strftime("%m/%d/%Y"), 
              self.color(resource), '', is_milestone_flag, 
              self.resource_name, self.progress.to_i, is_parent_flag, 
              self.parent_id, 1, self.dependencies_str, self.caption)
    end
  end

end
