# encoding: utf-8
ENV['APP_ROOT'] = File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift ENV['APP_ROOT'] + '/lib'

require 'rspec'
require 'dev_flow'

# load rspec support files:
def example_file(file)
  ENV['APP_ROOT'] + '/spec/support/examples/' + file
end

RSpec.configure do |config|
  # config.filter_run_excluding slow: true
  config.run_all_when_everything_filtered = true
  # config.after(:suite) {}
end
