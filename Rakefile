require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = ['--color', '--format progress']
end

task default: [:unit]
