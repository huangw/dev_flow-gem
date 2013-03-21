# encoding: utf-8

require "yaml"

module DevFlow
  ## a road map represents a list of tasks
  class RoadMap
    attr_accessor :file, :headers, :tasks,
      :branch_tasks, # branch name to task hash
      :ln_tasks, # line number to task hash
      :top_tasks # level 1 task list (used for id calculation)

    def initialize
      self.headers = Hash.new
      self.tasks = Array.new
      self.branch_tasks = Hash.new
      self.ln_tasks = Hash.new
      self.top_tasks = Array.new
    end

    def last_task
      @tasks.last
    end
    
    def title; self.headers["title"] end
    
    def parse file
      #{{{
      self.file = file if file
      fh = File.open(self.file, "r:utf-8")
      head_part = ""
      in_header = 0
      first_line = nil
      fh.each do |line|
        first_line = line unless first_line
        if /^\%\s*\-\-\-+/ =~ line
          in_header += 1
          next
        end
        
        # before any task defined, parse line begin with % as head field:
        if in_header == 1 and @tasks.size == 0
          head_part += line
        end

        if /^\s*\[(?<plus_>[\+\s]+)\]\s(?<contents_>.+)/ =~ line
          if @tasks.size == 0 and head_part.size > 0
            self.headers = YAML.load(head_part) 
            head_part = ""
          end
          line.chomp!
          task = Task.new(plus_.to_s.count("+"), self.file, $.).parse(contents_, self.headers).validate!
          raise "branch name #{task.branch_name} already used on #{self.file}:#{self.branch_tasks[task.branch_name].ln}" if self.branch_tasks[task.branch_name]
          if task.is_a?(Task)
            # find perant for the task:
            parent = self.find_parent task.level
            if parent
              parent.children << task
              task.parent = parent
              # task.id = (sprintf "%d%d", parent.id, parent.child_number).to_i
            end
            @tasks << task
            @branch_tasks[task.branch_name] = task
            @ln_tasks[task.ln] = task
            @top_tasks << task if task.level == 1
          end
        end
      end
      fh.close
      self.headers["title"] = first_line unless self.headers["title"]

      # check and set dependencies
      self.tasks.each do |task|
        task.dependencie_ids.each do |id|
          d_task = @branch_tasks[id]
          raise "task #{task.branch_name} (#{task.file}:#{task.ln}) has dependency #{id} not found on the file" unless d_task
          task.dependencies << d_task
        end
      end

      self
      #}}}
    end

    ## the last task in row that less than the given level is parent task
    def find_parent level
      self.tasks.reverse.each { |t| return t if t.level < level }
      nil
    end

    ## write out data.js for jquery.gantt plugin
    def as_data_js file="data.js"
      # {{{
      wfh = File.open(file, "w:utf-8")
      wfh.puts "var ganttData=["
      top_id = 1
      self.tasks.each do |task|
        next unless task.level == 1
        wfh.puts "  {"
        body = sprintf('    id: %d, name: "%s (%s)", ', top_id, task.display_name, self.headers["team"][task.resource])
        body += "series: [\n" if task.children.size > 0
        task.children.each do |child|
          body += sprintf('      { name: "%s (%s)", start: new Date(%s), end: new Date(%s), color: "%s" }, %s', 
                          child.display_name, self.headers["team"][child.resource], 
                          child.start_date.strftime("%Y,%m,%d"), child.end_date.strftime("%Y,%m,%d"),
                          "#f0f0f0", "\n")
        end

        body += "    ]" if task.children.size > 0 
        wfh.puts body
        wfh.puts "  },"
        top_id += 1
      end
      wfh.puts "]"
      wfh.close
      # }}}
    end

    def rewrite task_hash
      # task_hash: {task_line_as_integer => progress_as_integer}
      task_hash.each do |ln, progress|
        raise "invalid line number #{ln}" unless ln.to_s =~ /^\d+$/ and ln > 0
        raise "invalid progress #{progress}" unless progress.to_s =~ /^\d+$/ and progress > 0 and progress <= 100
      end

      file = self.file
      tmp_file = self.file + ".tmp"

      # backup the file to tmp_file
      FileUtils.mv file, tmp_file
      tfh = File.open(tmp_file, "r:utf-8")
      wfh = File.open(file, "w:utf-8")

      tfh.each do |line|
        if task_hash[$.]
          progress = task_hash[$.]
          task = @ln_tasks[$.]

          if progress == 100
            com_date = DateTime.now.strftime("%Y/%m/%d")
            com_date = DateTime.now.strftime("%m/%d") if DateTime.now.year == self.headers["year"]
            progress = com_date
          end
          
          new_line = line
          if /(?<resource_>\@[a-z\@\;]+)(\:[PD\d\/]+)?/ =~ line
            new_line.gsub!(/(?<resource_>\@[a-z\@\;]+)(\:[PD\d\/]+)?/, resource_ + ":" + progress.to_s)
          elsif /(?<dep_>\-\>.+)$/ =~ line
            new_line.gsub!(/\s*\-\>.+$/, '@' + self.headers["leader"] + ":" + progress.to_s + " " + dep_)
          else
            new_line += '@' + self.headers["leader"] + ":" + progress.to_s
          end

          wfh.puts new_line
        else
          wfh.puts line
        end
      end
      tfh.close
      wfh.close

      FileUtils.rm tmp_file
    end
  end
end
