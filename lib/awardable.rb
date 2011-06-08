require 'awardable/acts_as_awardable'
require 'awardable/award_base'
require 'awardable/awarding_base'
require 'awardable/version'

require 'active_record'

module Awardable
  autoload :Builder, 'awardable/builder'
  autoload :Controller, 'awardable/controller'
  autoload :Engine, 'awardable/engine'
  autoload :Grant, 'awardable/grant'
  autoload :Request, 'awardable/request'
end

ActiveRecord::Base.send :include, Awardable
