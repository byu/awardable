module Awardable
  module AwardBase
    ##
    # Callback for Award classes that sets up the ActiveRecord model
    # relationships and the Award validations.
    def self.included(base)
      # Execute the block in the Award class.
      base.class_eval do
        # Our awardings relationship
        has_many :awardings

        # Set up restrictions for name where the name must made up only of
        # lower case alpha, numbers and underscores.
        validates_format_of :name, :with => /\A[a-z0-9_]+\Z/
        validates_presence_of :name
        validates_uniqueness_of :name

        # Validations for the display_name
        validates_presence_of :display_name
        validates_uniqueness_of :display_name
      end
    end
  end
end
