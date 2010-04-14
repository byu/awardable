require 'awardable/acts_as_awardable'
require 'awardable/award_base'
require 'awardable/awarding_base'

require 'active_record'

ActiveRecord::Base.send :include, Awardable
