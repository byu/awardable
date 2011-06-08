require 'awardable/controller'
require 'awardable/engine'
require 'awardable/request'
require 'rack/mount'

module Awardable

  ##
  # A builder class to create the Awardable::Engine instance that
  # is used to check and grant awards (not to mention revoking awards).
  #
  class Builder

    attr_reader :map

    ##
    # A simple RouteMap to use before actually creating the RackMount::RouteSet.
    #
    class RouteMap < Array
      def add_route(class_name, method_name, conditions={}, *args)
        self << [class_name, method_name, conditions, args]
      end
    end

    ##
    # Initializes a builder to properly create an Awarding engine
    # to handle some awardable extended features.
    #
    # @param [Hash] opt options
    # @option opt [Class] :controller_class (Controller) the rack based
    #   app to handle do the proxying for the AwardCheck classes.
    # @option opt [Class] :engine_class (Engine) An alternate awarding
    #   engine to use.
    # @option opt [Class] :request_class (Request) An alternate Rack based
    #   request class to use for Rack::Mount::RouteSet conditional routing.
    # @option opt [Class] :router_class (Rack::Mount::RouteSet) An alternate
    #   router class to use.
    def initialize(opt={})
      @controller_class = opt.fetch(:controller_class) { Controller }
      @engine_class = opt.fetch(:engine_class) { Engine }
      @request_class = opt.fetch(:request_class) { Request }
      @router_class = opt.fetch(:router_class) { Rack::Mount::RouteSet }
      @map = RouteMap.new
      yield @map if block_given?
    end

    ##
    # Adds a route. This is based off the Rack::Mount::RouteSet routes.
    #
    # @see Rack::Mount::RouteSet
    #
    # @param class_name which class to use for this award check. An instance
    #   of this class is created for each route it is added.
    # @param method_name the method in the class to call in the award check.
    # @param conditions the Rack::Mount::RouteSet compatible routing conditions.
    #   This is also related to the request_class we use.
    # @param args a list of parameters to pass to the initialization of the
    #   class_name award check class.
    #
    def add_route(class_name, method_name, conditions={}, *args)
      @map.add_route class_name, method_name, conditions, *args
    end

    ##
    # @returm a build awardable engine.
    #
    def build
      routes = @router_class.new :request_class => @request_class
      for route in map
        class_name, method_name, conditions, args = route
        controller = @controller_class.new class_name, method_name, *args
        routes.add_route controller, conditions
      end
      routes.freeze
      return @engine_class.new routes
    end
  end
end
