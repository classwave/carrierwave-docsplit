require "bundler/gem_tasks"
require 'rake/testtask'

task :console do
  sh "irb -r ./test/test_uploader"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end