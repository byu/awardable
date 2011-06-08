module Awardable

  ##
  # A RackMount request object to use instead of the normal Rack request
  # class, which fits our needs more.
  #
  # If this Request model doesn't fit, then it can be overriden via the
  # Awardable::Builder by specifying a different class and altering the
  # route conditions.
  #
  # @see Awardable::Builder
  #
  class Request

    ##
    # Initializer that takes in a Rack request environment.
    #
    # @param [Hash] env the rack call environment.
    #
    def initialize(env)
      @env = env
      @source = env[:source]
    end

    ##
    # Returns the class name of the source.
    #
    def source_type
      @source.class.to_s
    end

    ##
    # Returns the relevant ID to use for routing. In general, this
    # id is the id of the source object. However, it may be proper to use
    # a related objects (in a belongs_to, has_many, etc) for routing to
    # an award checking class.
    def relevant_id
      @source.respond_to?(:id) ? @source.id : @source.object_id
    end

    ##
    # Returns an action string about the event.
    #
    def action
      @env[:action]
    end
  end

end
