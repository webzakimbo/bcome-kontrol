
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  if filename = ENV["TEST"]
    raise "Missing test file #{filename}" unless File.exist?(filename)
    t.test_files = [filename]
  else
    t.test_files = FileList['test/**/*_test.rb']
  end
end
desc 'Run tests'

task default: :test
