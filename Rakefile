# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/awardable/version.rb'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = 'awardable'
  gem.homepage = 'http://github.com/byu/awardable'
  gem.summary = %Q{An awards, achievements and badges plugin for Rails.}
  gem.description = %Q{
    Awardable is a Ruby on Rails plugin for projects that want to give
    badges (or trophies, or achievements) to their Users (or any other
    ActiveRecord model).}
  gem.email = 'benjaminlyu@gmail.com'
  gem.authors = ['Benjamin Yu']
  gem.license = "APACHE-2.0"
  gem.version = Awardable::VERSION::STRING

  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
