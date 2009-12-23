require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'awardable'
    gem.summary = %Q{An awards, achievements and badges plugin for Rails.}
    gem.description = %Q{
      Awardable is a Ruby on Rails plugin for projects that want to give
      badges (or trophies, or achievements) to their Users (or any other
      ActiveRecord model).}
    gem.email = 'benjaminlyu@gmail.com'
    gem.homepage = 'http://github.com/byu/awardable'
    gem.authors = ['Benjamin Yu']

    # NOTE: We comment out some development dependencies here because they
    # are pulled down with the Bundler Gemfile.
    #gem.add_development_dependency 'activerecord'
    #gem.add_development_dependency 'activesupport'
    gem.add_development_dependency 'cucumber'
    gem.add_development_dependency 'rspec', '>= 1.2.9'
    #gem.add_development_dependency 'sqlite3-ruby'
    gem.add_development_dependency 'yard'

    gem.files = FileList[
      'lib/**/*.rb',
      'bin/*',
      '[A-Z]*',
      'spec/**/*',
      'features/**/*',
      'generators/**/*'].to_a
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
rescue LoadError
  task :features do
    abort 'Cucumber is not available. In order to run features, you must: sudo gem install cucumber'
  end
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort 'YARD is not available. In order to run yardoc, you must: sudo gem install yard'
  end
end
