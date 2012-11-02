require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rdoc/task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = "rdoc_html"
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_files.exclude("**/*test*")
  rd.rdoc_files.exclude('multipart.rb')
end

