module Awardable
  module AwardingBase
    ##
    # Callback for Awarding class to set up the ActiveRecord model
    # relationships and the Awarding validations.
    def self.included(base)
      base.class_eval do
        belongs_to :award
        belongs_to :awardable, :polymorphic => true

        # We require both the award and the awardable because Awarding
        # is a linking model.
        validates_presence_of :award
        validates_presence_of :awardable

        # This validation is used when the award we are trying to assign
        # is set to be globally unique.
        validates_uniqueness_of :award_id, :if => Proc.new { |awarding|
          awarding.award and awarding.award.once_global
        }

        # This validation is used when the award we are trying to assign
        # is set to be unique within an instance.
        validates_uniqueness_of :award_id,
            :scope => [:awardable_type, :awardable_id],
            :if => Proc.new { |awarding|
          awarding.award and awarding.award.once_instance
        }
      end
    end
  end
end
