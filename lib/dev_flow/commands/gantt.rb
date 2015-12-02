require 'fileutils'
require 'erubis'

module DevFlow
  class Gantt < App

    ## fetch git log
    def git_log
      git_log = ''
      committer = ''
      last_header = ''
      `git log --graph --format=email --date=relative -n 50`.split(/\n/).each do |line|
        # {{{
        line.chomp!
        line.gsub!(">", "&gt;")
        line.gsub!("<", "&lt;")
        if /^(?<header_>\W+)From\s+(?<hash_code_>\w+)/ =~ line
          git_log += "#{header_}<em style='color:grey'>#{hash_code_}</em>\n"
        elsif /^(?<header_>\W+)From\:\s+(?<committer_>.+)$/ =~ line
          committer = committer_
          last_header = header_
        elsif /^(?<header_>\W+)Date\:\s*(?<date_>.+)$/ =~ line
          git_log += sprintf("%s<strong>%s</strong> By %s\n", last_header, DateTime.parse(date_).strftime("%F %R"), committer)
          git_log += header_
        elsif /^(?<header_>\W+)Subject\:\s+\[PATCH\]\s*(?<message_>.+)$/ =~ line
          color = 'green'
          git_log += "#{header_}<strong style='color:#{color}'>#{message_}</strong>\n"
        else
          git_log += line + "\n"
        end
      end
      git_log
    end

    ## create gantt chart from templates
    def process!
      error "Not on the develop trunk" unless @git.current_branch == 'develop'
      # error "Only leader/moderator and supervisor can edit ROADMAP" unless i_have_power?

      docs = @config[:docs]
      html_file = "#{docs}/gantt.html"
      FileUtils.mkdir_p "#{docs}" unless File.directory? "#{docs}"

      tpl_dir = File.expand_path(File.dirname(__FILE__) + "/../../../templates")
      FileUtils.cp_r "#{tpl_dir}/css", docs
      FileUtils.cp_r "#{tpl_dir}/js", docs

      wfh = File.open(html_file, "w:utf-8")
      wfh.puts Erubis::Eruby.new(File.read("#{tpl_dir}/jsgantt.html.erb")).result(:rm => @roadmap, :is_roadmap => true, :git_log => git_log, :resource => nil)
      wfh.close

      # update to server
      if sync?
        `git add .`
        `git commit -am 'update Gantt chart'`
        `git push #{@config["git_remote"]} develop`
      end
    end

  end
end
