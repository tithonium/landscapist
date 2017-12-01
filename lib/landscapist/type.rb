module Landscapist
  class Type < Definition
    
    attr_writer :param
    def to_param
      @param || self.name.gsub(/([a-z])([A-Z])/){$1+'_'+$2.downcase}.downcase
    end
    
    def inspect
      "<#T:#{name}>"
    end
    
    class CoreType < Type
      attr_reader :swagger_overrides
      def initialize(name, swagger_overrides)
        super(name)
        @swagger_overrides = swagger_overrides
      end
      def inspect ; "(#{name})" ; end
    end
    
    @core_types = {}
    class << self
      def define_core_type(type, swagger_overrides)
        unless @core_types[type.to_s]
          core_type = @core_types[type.to_s] = CoreType.new(type.to_s, swagger_overrides)
          CoreType.define_singleton_method(type.to_s) { core_type }
        end
      end
      
      def find_core_type(type)
        @core_types[type.to_s]
      end
      
    end
    
    class DSL < Landscapist::Definition::DSL
    end
  end
end
