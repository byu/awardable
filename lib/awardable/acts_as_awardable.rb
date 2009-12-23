module Awardable

  ##
  # A callback that is executed with the Awardable module is included.
  # This is set to be called when the module is included by the
  # ActiveRecord::Base class, and its only job is to extend
  # that class with the Awardable::ClassMethods module.
  def self.included(base)
    base.extend ClassMethods
  end

  ##
  # The Module that ActiveRecord::Base automatically extends, and
  # whose only method is to help bootstrap ActiveRecord models
  # to be able to use the Awardable gem.
  module ClassMethods
    ##
    # Bootstraps an ActiveRecord model to become an Awardable.
    #
    #   class User < ActiveRecord::Base
    #     acts_as_awardable
    #   end
    # @return [nil] no return value
    def acts_as_awardable(options={})
      send :include, InstanceMethods
      send :extend, DynamicClassMethods

      # We hook in the ActiveRecord relations for this model
      # to the Awards.
      self.class_eval do
        has_many :awardings,
          :as => :awardable,
          :include => :award,
          :dependent => :destroy
        has_many :awards, :through => :awardings
      end
      return nil
    end
  end

  ##
  # Module that defines the methods that will be extended into
  # the ActiveRecord model that becomes an acts_as_awardable.
  module DynamicClassMethods
    ##
    # Start of an ActiveRecord query chain to find the Awardable objects that
    # have been awarded with a given Award.
    #
    #   # Our hypothetical ActiveRecord model.
    #   AwardableModel < ActiveRecord::Base
    #     acts_as_awardable
    #   end
    #
    #   # We create an Award, and assign it to a new AwardableModel.
    #   award = Award.create(:name => 'award_1', :display_name => 'Award 1')
    #   awardable1 = Awardable.create
    #   awardable1.award_with!(award)
    #
    #   # Now we can query to see what AwardableModels have been granted
    #   # the award.
    #   awardables = AwardableModel.find_awarded_with(:award_1)
    #   awardables.each do |awardable|
    #     puts awardable.id
    #   end
    #
    # @param [Award, #to_s] value The award, or the award name.
    # @return [Array] The found Awardables, or empty array.
    def find_awarded_with(value)
      case value
      when Award
        return find(:all,
            :joins => :awardings,
            :conditions => { :awardings => { :award_id => value.id } } )
      else
        return find(:all,
            :joins => :awards,
            :conditions => { :awards => { :name => value.to_s } } )
      end
    end
  end

  ##
  # Module that defines the instance methods of the ActiveRecord model
  # that becomes an acts_as_awardable.
  module InstanceMethods
    ##
    # Provides a histogram of the Awards the Awardable model has received.
    #
    # @return [Hash{String=>Integer}] Award names and their counts.
    def award_counts
      awards.count :group => :name
    end

    ##
    # Grants an Awardable object with an Award.
    #
    # @param [Award, #to_s] award The award to be granted. If #to_s, then an
    #   Award with the given name must exist in the database.
    # @return [Boolean] The success of the save.
    def award_with!(award, options={})
      return false unless award
      awarding = Awarding.new
      case award
      when Award
        awarding.award = award
      else
        result = Award.find_by_name award.to_s
        return false unless result
        awarding.award = result
      end
      options.each do |key, value|
        awarding.send("#{key}=", value) if awarding.respond_to? "#{key}="
      end
      awarding.awardable = self
      # Save this awarding, and also makes it available in the Awardable model.
      return awarding.save
    end

    ##
    # Returns an ordered array of the titles bestowed upon the Awardable
    # from acquired achievements.
    #
    # @option options [Symbol] :gender (:male) The primary gender to extract
    #   when generating the title list. :male or :female are valid Symbols.
    #   Defaults to male if the passed option is unrecognized.
    # @option options [Symbol] :order (:prestige) The ordering field of list.
    #   The symbol is the field name to query.
    # @option options [Boolean] :alt_gender_ok (false) Use the alternate
    #   gender title if primary gender is unavailable.
    # @option options [Boolean] :reverse (false) Reverse the sorting.
    #   Descending order by default so higher prestige is first in list.
    # @param [Proc] &filter Block called by the awards Array#delete_if
    #   remove unwanted titles from the final ordered list.
    # @return [Array<String>] List of titles order by prestige, or empty array.
    def awarded_titles(options={}, &filter)
      use_male = options[:gender] != :female
      alt_ok = options[:alt_gender_ok] ? true : false
      order_by = options[:order_by] || :prestige
      reverse = options[:reverse] ? true : false
      # Create a new Array of unique awards, sort the array,
      # extract the title and compact the nils.
      ordered_awards = awards.uniq.sort! do |a,b|
        b.read_attribute(order_by) <=> a.read_attribute(order_by)
      end
      ordered_awards.delete_if &filter if filter
      ordered_awards.reverse! if reverse
      ordered_awards.map! do |award|
        if use_male
          title = award.masculine_title
          if title.blank? and alt_ok
            title = award.feminine_title
          end
        else
          title = award.feminine_title
          if title.blank? and alt_ok
            title = award.masculine_title
          end
        end
        title
      end.compact!
      ordered_awards
    end

    ##
    # Checks to see if the Awardable object has been granted a particular
    # award.
    #
    # @param [Award, Array, Set, #to_s] value The award to be checked. The
    #   method recurses if parameter is an Array or Set.
    # @return [Boolean] If the Awardable has been granted the Award, or at
    #   least one of the Awards described by the input. A false is returned
    #   if the Awardable has been granted none of the Awards passed to this
    #   method.
    def awarded_with?(value)
      case value
      when Award
        return awards.any? do |item|
          item == value
        end
      when Array, Set
        return value.any? do |item|
          awarded_with? item
        end
      else
        award_str = value.to_s
        return awards.any? do |item|
          item.name == award_str
        end
      end
    end

    ##
    # Returns a new unique set of awards that have been awarded to the
    # Awardable model.
    #
    # @return [Set] A set of unique Awards, or empty set.
    def awards_set
      awards.to_set
    end

    ##
    # Returns a new unique array of awards that have been awarded to the
    # Awardable model.
    #
    # @return [Array] An array of unique Awards, or empty array.
    def unique_awards
      awards.uniq
    end
  end
end
