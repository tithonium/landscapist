module Landscapist
  class Endpoint < Definition
    class Expectation
      
      attr_reader :type, :optional
      def initialize(type, optional = true)
        @type = type
        @optional = optional
      end
      
    end
  end
end
