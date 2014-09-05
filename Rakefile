require "bundler/gem_tasks"

require 'rspec/core/rake_task'
desc 'Run all (r)spec tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  # t.spec_files = FileList[ENV['F']] if ENV['F']
  t.rspec_opts = '--format documentation --color'
end

desc 'Run all (r)spec tests with profile'
RSpec::Core::RakeTask.new(:prof) do |t|
  # t.spec_files = FileList[ENV['F']] if ENV['F']
  t.rspec_opts = '--profile --color'
end

require 'rubocop/rake_task'
desc 'Run rubocop for local directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['{app,config,lib}/**/*.rb']
  task.fail_on_error = false
end

desc 'Create ctags file for vim'
task :ctags do
  sh 'ctags -R --exclude=*.js .'
end

task default: [:ctags, :rubocop, :spec]
