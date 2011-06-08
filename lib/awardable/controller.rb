require 'active_support/core_ext'
require 'active_support/core_ext/string/inflections'

module Awardable

  ##
  # A simple proxy class to handle the Rack based request.
  #
  class Controller

    ##
    # @param class_name which class to use for this award check.
    # @param method_name the method in the class to call in the award check.
    #
    def initialize(class_name, method_name, *init_args)
      @method_name = method_name
      @obj = class_name.constantize.new *init_args
    end

    ##
    # The rack call. The body returned is an Array of awarded grants
    # returned by the award check class.
    #
    def call(env)
      [200, {}, Array(@obj.send @method_name, env)]
    end
  end

end
