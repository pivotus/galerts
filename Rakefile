require "bundler/gem_tasks"

task :default => [:build]

desc 'Build Gem'
task :build => :environment do
  `gem build galerts.gemspec`
end
