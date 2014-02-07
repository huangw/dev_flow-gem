require 'rspec'
require 'dev_flow'
require "term/ansicolor"
class String; include Term::ANSIColor end

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
