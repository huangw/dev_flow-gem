# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rubocop, all_on_start: false, cli: ['--format', 'clang'] do
  watch(%r{^app/(.+)\.rb$})
end

guard :rspec, cmd: 'bundle exec rspec --color -f d' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^examples/(.+)\.rb$})     { |m| "spec/examples/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  watch(%r{^app/(.+)\.rb$})          { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/support/(.+)\.rb$}) { "spec" }
end
