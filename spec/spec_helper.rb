# Load in all dependent libs using Bundler
require "#{File.dirname(__FILE__)}/../vendor/bundler_gems/environment"
Bundler.require_env :spec

# Set the loading for the project
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'awardable'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

# Create a Test Database
ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3", "database" => ":memory:")
load(File.dirname(__FILE__) + '/schema.rb')

class AwardableModel < ActiveRecord::Base
  acts_as_awardable
end

class AltAwardableModel < ActiveRecord::Base
  acts_as_awardable
end

class InheritAwardableModel < AwardableModel 
end

class Award < ActiveRecord::Base
  include Awardable::AwardBase
end

class Awarding < ActiveRecord::Base
  include Awardable::AwardingBase
end
