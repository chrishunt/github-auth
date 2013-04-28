require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cane/rake_task'

desc 'Run all tests'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--color --order random'
end

desc 'Check code quality'
Cane::RakeTask.new(:quality) do |task|
  task.abc_max = 9
end

task default: :spec
task default: :quality
