# representations for a task in roadmap and in Gantt chart.
# ==========================================================
#
# @author: Huang Wei <huangw@pe-po.com>
# version 1.0a
#

module DevFlow
  ## Task object represent a single line on the Gantt chart
  class Task
    attr_accessor :file, :ln, # which line of file defined the task
      :level, :branch_name, :display_name, :resources, 
      :progress, :completed_at, # complete date time
      :dependencie_ids, :start_date, :end_date,
      :parent, # task object the represents the parent
      :children, # array of task object represent children
      #:is_milestone, # if represent a milestone or a release
      #:is_pending, :is_deleted

    def initialize level,file="-",ln=0
      self.level = level.to_i
      raise "invalid level #{level}" unless level.to_i > 0
      self.file, self.ln = file, ln
      self.children = Array.new
      self.dependencies = Array.new
      self.dependencie_ids = Array.new
      self.progress = 0
      self.resources = Array.new
      self.resource_names = Array.new
    end

    def number_of_children; self.children.size end
    def is_completed?; self.completed_at ? true : false end
    def is_milestone?; self.is_milestone ? true : false end
    def is_parent?; self.children.size > 0 ? true : false end

    ## a task is completable if all children complated
    def is_completable?
      # {{{
      return false if self.is_completed? 
      self.children.each do |child|
        return false unless child.is_completed?
      end
      true
      # }}}
    end

    ## a task is workable (can be started) if all children
    # task and dependent task are completed
    def is_workable?
      # {{{
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
      #}}}
    end

    ## task_id in the roadmap
    def task_id
      self.ln
    end
    
    ## color reflects the status of a task, return a hex code without heading "#"
    def color
      # {{{
      today = DateTime.now.strftime("%Y%m%d").to_i 
      start_day = self.start_date.strftime("%Y%m%d").to_i 
      end_day = self.end_date.strftime("%Y%m%d").to_i 
      hex = "B0C4DE" # light steel blue as default 
      hex = "808080" unless self.is_workable? # grey for no able to start
      hex = "008000" if self.is_completed?    # green for completed
      hex = "FFD700" if start_day == today and progress == 0 # gold for must start now
      hex = "FFFF00" if self.progress > 0 and self.progress < 100 # blue for working
      hex = "FFA500" if end_day == today and self.progress < 100 # orange for master complete today
      hex = "FF0000" if self.progress < 100 and today > end_day   # red for not completed on time 
      hex = "FF0000" if self.progress == 0 and today > start_day  # red for late start
      hex = "EEE8AA" if self.is_deleted
      hex = "C0C0C0" if self.is_pending
     #  puts hex + ":" + self.progress.to_s + ";" + DateTime.now.strftime("%Y%m%d") + ":" + self.start_date.strftime("%Y%m%d")
      hex
      # }}}
    end

    def resource_name; self.resource_names.join ", " end
    def resource; self.resources.join ", " end

    ## captions for display behind the bar of the Gantt chart
    def caption
      # {{{
      return "" if self.children.size > 0
      cap = self.resource_name
      cap = sprintf("Pending (%s)", cap) if self.is_pending
      cap = sprintf("Deleted (%s)", cap) if self.is_deleted
      if self.is_completed?
        cap += self.completed_at.strftime("%F")
      else
        cap += sprintf(':%02d\%', self.progress) if self.progress > 0
      end
      cap
      # }}}
    end

    ## range task title string
    def title
      tt = sprintf "%s (%s)", self.display_name, self.branch_name
      tt = "<em>&lt;" + tt + "&gt;</em>" if self.is_milestone?
      tt = "<strong>" + tt + "</strong>" if self.level == 1
      #tt = "<span style=\"color:#666666\">(Pending)" + tt + "</span>" if self.is_pending
      #tt = "<span style=\"text-decoration:line-through\">(Deleted)" + tt + "</span>" if self.is_deleted
      tt
    end

    def dependencies_str
      self.dependencies.map {|d| d.task_id}.join ","
    end

    def parent_id
      self.parent ? self.parent.task_id : 0 
    end

    ## render task as a line in the Gantt chart JS
    def as_js 
      # {{{
      is_milestone_flag = self.is_milestone ? 1 : 0
      is_parent_flag = self.is_parent? ? 1 : 0
      task_str = "    g.AddTaskItem(new JSGantt.TaskItem(%d,'%s','%s','%s','%s','%s',%d,'%s',%d,%d,%d,%d,'%s','%s'));\n"
      sprintf(task_str, self.task_id, self.title, 
              self.start_date.strftime("%m/%d/%Y"), 
              self.end_date.strftime("%m/%d/%Y"), 
              self.color, '', is_milestone_flag, 
              self.resource_name, self.progress.to_i, is_parent_flag, 
              self.parent_id, 1, self.dependencies_str, self.caption)
      # }}}
    end
    
    ## check whether the task is well defined, raise error otherwise.
    def validate!
      #{{{
      raise "resource not found on #{self.file}:#{self.ln}" unless self.resource
      raise "display_name not found on #{self.file}:#{self.ln}" unless self.display_name
      raise "valid start_date not found on #{self.file}:#{self.ln}" unless self.start_date
      self
      #}}}
    end

    ## parse the line from file:ln (line number), initialize the
    # task object
    def parse line, headers = {}
      # {{{
      line.strip! # delete head/trailing spaces

      /^((?<branch_name_>[a-zA-Z0-9_\-\#\.\/]+):)?\s*(?<display_name_>.+)\s+(?<start_date_>(\d\d\d\d\/)?\d\d?\/\d\d?)(-(?<end_date_>(\d\d\d\d\/)?\d\d?\/\d\d?))?(\s+\@(?<resource_>[a-z\@\;]+))?(\:(?<status_>(P|D))?(?<progress_>[\d\/]+)?)?(\s+\-\>\s*(?<dependencies_>.+))?$/ =~ line

      # assign branch name and display name
      self.branch_name = branch_name_
      if self.branch_name =~ /^(release|milestone)\_/
        self.is_milestone = true
        unless self.level == 1
          raise "you can only tag a top level task as a release, on #{self.file}:#{self.ln}" if self.branch_name =~ /^release\_/
        end
      end

      self.display_name = display_name_

      # assign start and end date
      end_date_ = start_date_ unless end_date_
      raise "no valid start date found on #{self.file}:#{self.ln}" unless start_date_ and start_date_.size > 0
      if headers["year"]
        start_date_ = headers["year"].to_s + "/" + start_date_ unless start_date_ =~ /^\d\d\d\d/
        end_date_ = headers["year"].to_s + "/" + end_date_ unless end_date_ =~ /^\d\d\d\d/
      end

      self.start_date = DateTime.parse(start_date_)
      self.end_date = DateTime.parse(end_date_)
      raise "wrong date on #{self.file}:#{self.ln}" unless self.start_date and self.end_date and self.start_date <= self.end_date

      # assign for the resources (user name)
      unless resource_
        if headers["leader"]
          resource_ = headers["leader"]
        else
          raise "no resource defined on #{self.file}:#{self.ln}"
        end
      end

      resource_.gsub!("\@", "")
      resource_.split(";").each do |r|
        self.resources << r
        self.resource_names << r
      end

      if dependencies_
        dependencies_.strip!
        dependencies_.gsub!(/;$/, "")
        self.dependencie_ids = dependencies_.split(/;/)
      end

      # pending or deleted status
      if status_
        if status_ == "P"
          self.is_pending = true
        elsif status_ == "D"
          self.is_deleted = true
        end
      end

      # progress
      if progress_
        if progress_ =~ /^\d\d?$/ and progress_.to_i > 0 and progress_.to_i < 100
          self.progress = progress_.to_i
        elsif progress_ =~ /^\d\d\d\d\/\d\d?\/\d\d?$/
          self.progress = 100
          self.completed_at = DateTime.parse(progress_)
        elsif progress_ =~ /^\d\d?\/\d\d?$/ and headers["year"]
          self.progress = 100
          self.completed_at = DateTime.parse(headers["year"].to_s + "/" + progress_.to_s)
        else
          msg = "worng format around progress parameter '#{progress_}', on #{self.file}:#{self.ln}"
          msg += " (HINT: use date to complete a task, not 100)" if progress_.to_i == 100
          raise msg
        end
      end

      self
      #}}}
    end
  end # end class Task
end
