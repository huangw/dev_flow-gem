# representations for a task in roadmap and in Gantt chart.
# ==========================================================
#
# @author: Huang Wei <huangw@pe-po.com>
# version 1.0a

module DevFlow
  ## Task object represent a single line on the Gantt chart
  class Task
    attr_accessor :file, :ln, # which line of file defined the task
      :level, :branch_name, :display_name, :resources, :resource_names,
      :progress, :completed_at, # complete date time
      :dependencies, # depends on those tasks (list of branch_names)
      :dependencie_names, # denpendencies in branch names (for display)
      :start_date, :end_date,
      :parent, :children, # all in branch_names first
      :is_pending, :is_deleted
  
    # initialize with level, file and line number
    def initialize level,file="-",ln=0
      @level = level.to_i
      raise "invalid level #{level}" unless level.to_i > 0
      @file, @ln = file, ln
      @children = Array.new
      @dependencies = Array.new
      @dependencie_names = Array.new
      @progress = 0
      @resources = Array.new
      @resource_names = Array.new
    end

    # filter methods
    def is_milestone?
      self.branch_name =~ /^(milestone|release)\_/ ? true : false
    end

    def is_release?
      self.branch_name =~ /^release\_/ ? true : false
    end

    def is_completed?
      self.progress == 100
    end

    def is_pending?
      self.is_pending ? true :false
    end

    def is_deleted?
      self.is_deleted ? true : false
    end

    def is_parent?
      self.children.size > 0 ? true : false
    end

    def is_urgent?  # usually orange
      today = DateTime.now.strftime("%Y%m%d").to_i 
      start_day = self.start_date.strftime("%Y%m%d").to_i 
      end_day = self.end_date.strftime("%Y%m%d").to_i
      
      return true if start_day == today and progress == 0
      return true if end_day == today and self.progress < 100
      false
    end

    def is_delayed? # usually red
      today = DateTime.now.strftime("%Y%m%d").to_i 
      start_day = self.start_date.strftime("%Y%m%d").to_i 
      end_day = self.end_date.strftime("%Y%m%d").to_i
      return true if self.progress < 100 and today > end_day
      return true if self.progress == 0 and today > start_day
      false
    end

    ## check whether the task is well defined, raise error otherwise.
    def validate!
      if self.is_milestone?
        unless self.level == 1
          raise "you can only tag a top level task as a release, on #{self.file}:#{self.ln}" if self.branch_name =~ /^release\_/
        end
      end
      raise "resource not found on #{self.file}:#{self.ln}" unless self.resources.size > 0
      raise "display_name not found on #{self.file}:#{self.ln}" unless self.display_name
      raise "valid start_date not found on #{self.file}:#{self.ln}" unless self.start_date
      raise "wrong date on #{self.file}:#{self.ln}" unless self.start_date and self.end_date and self.start_date <= self.end_date

      self
    end

    ## parse the line from file:ln (line number), initialize the
    # task object
    def parse line, headers = {}
      line = line.strip # delete head/trailing spaces

      /^((?<branch_name_>[a-zA-Z0-9_\-\#\.\/]+):)?\s*(?<display_name_>.+)\s+(?<start_date_>(\d\d\d\d\/)?\d\d?\/\d\d?)(-(?<end_date_>(\d\d\d\d\/)?\d\d?\/\d\d?))?(\s+\@(?<resource_>[a-z\@\;]+))?(\:(?<status_>(P|D))?(?<progress_>[\d\/]+)?)?(\s+\-\>\s*(?<dependencies_>.+))?$/ =~ line

      # assign branch name and display name
      self.branch_name = branch_name_

      self.display_name = display_name_

      # assign start and end date
      end_date_ = start_date_ unless end_date_
      raise "no valid start date found on #{self.file}:#{self.ln}" unless start_date_ and start_date_.size > 0
      if headers["year"]
        start_date_ = headers["year"].to_s + "/" + start_date_ unless start_date_ =~ /^\d\d\d\d/
        end_date_ = headers["year"].to_s + "/" + end_date_ unless end_date_ =~ /^\d\d\d\d/
      end

      begin
        self.start_date = DateTime.parse(start_date_)
        self.end_date = DateTime.parse(end_date_)
      rescue Exception => e
        raise "invalid date on #{self.file}:#{self.ln}"  
      end
      
      # assign for the resources (user name)
      unless resource_
        if headers["leader"]
          resource_ = headers["leader"]
        else
          raise "no resource defined on #{self.file}:#{self.ln}"
        end
      end

      resource_.gsub!("\@", "") # @ for other user is optional
      resource_.split(";").each do |r|
        self.resources << r
        # if the user is listed on known members
        rname = r
        if headers["members"] and headers["members"][r] and headers["members"][r][0]
          rname = headers["members"][r][0]
        end
        self.resource_names << rname
      end

      if dependencies_
        dependencies_.strip!
        dependencies_.gsub!(/;$/, "")
        self.dependencie_names = dependencies_.split(/;/)
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
    end

  end # class Task
end
