module DevFlow
  ## a road map represents a list of tasks
  class RoadMap
    attr_accessor :file, :config, :tasks,
      :branch_tasks, # branch name to task hash
      :ln_tasks, # line number to task hash, used for rewrite
      :top_tasks # level 1 task list (used for id calculation)

    def initialize file, config
      @file, @config = file, config
      @tasks = Array.new
      @branch_tasks = Hash.new
      @ln_tasks = Hash.new
      @top_tasks = Array.new
    end

    def last_task
      @tasks.last
    end
    
    def title
      @config[:title]
    end

    def parse file = nil
      self.file = file if file
      fh = File.open(self.file, "r:utf-8")
      head_part = ""
      in_header = 0
      fh.each do |line|
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
            @config = @config.merge YAML.load(head_part) 
            head_part = ""
          end
          line.chomp!
          task = Task.new(plus_.to_s.count("+"), self.file, $.).parse(contents_, @config)
          task.validate! # raise for format errors
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

      # check and set dependencies
      self.tasks.each do |task|
        task.dependencie_names.each do |branch|
          d_task = @branch_tasks[branch]
          raise "task #{task.branch_name} (#{task.file}:#{task.ln}) has dependency #{branch} not found on the file" unless d_task
          task.dependencies << d_task
        end
      end
      self
    end

    ## the last task in row that less than the given level is parent task
    def find_parent level
      self.tasks.reverse.each { |t| return t if t.level < level }
      nil
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
