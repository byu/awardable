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
