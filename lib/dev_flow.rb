require 'yaml'
require 'logger'
require 'fileutils'

# model layer
require 'dev_flow/task'
require 'dev_flow/roadmap'
require 'dev_flow/member'

# presenter
require 'dev_flow/task_console'

# application and commands
require 'dev_flow/app'
require 'dev_flow/version'
require 'dev_flow/date_name'

# other helper and libraries
require 'dev_flow/girc'

module DevFlow
  def self.invoke! config, command
    # autoload command required files
    require "dev_flow/commands/#{command}"
    klass = command.to_s.capitalize
    eval(klass).new(config, command).process!
  end
end
