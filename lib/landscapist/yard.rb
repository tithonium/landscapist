module Landscapist
  class Yard < Definition
    
    attr_reader :path, :version
    def initialize(*)
      super
      @path = '/'
      @version = nil
      @children = {
        endpoints: {},
        payloads: {},
        types:     {},
        yards:     {},
      }
    end
    
    def set_path(path)
      @path = path
    end
    
    def set_version(version)
      @version = version
    end
    
    %w[yard endpoint payload type].each do |child|
      class_eval <<-"EOF", __FILE__, __LINE__
        def find_own_#{child}(name)
          @children[:#{child}s][name.to_s]
        end
        
        def find_#{child}(name)
          @children[:#{child}s][name.to_s] || parental_delegator.find_own_#{child}(name)
        end
        
        def get_#{child}(name)
          if found = find_#{child}(name)
            return found
          end
          @children[:#{child}s][name.to_s] ||= #{child.sub(/\A([a-z])/){$1.upcase}}.new(name.to_s, self)
        end
        
        def new_#{child}(name)
          @children[:#{child}s][name.to_s] = #{child.sub(/\A([a-z])/){$1.upcase}}.new(name.to_s, self)
        end
        
        def #{child}s
          @children[:#{child}s].values
        end
      EOF
    end
    
    def descendant_endpoints
      endpoints + yards.flat_map(&:descendant_endpoints)
    end
    
    def import_yard(other_yard)
      other_yard = parental_delegator.find_yard(other_yard) unless other_yard.is_a?(Yard)
      other_yards = other_yard.yards
      other_yards.each do |yard|
        y = get_yard(yard.name)
        y.instance_variable_set(:@parent, self)
        y.import_yard(yard)
      end
      other_endpoints = other_yard.endpoints
      other_endpoints.each do |endpoint|
        ep = get_endpoint(endpoint.name)
        ep.instance_variable_set(:@path, endpoint.path.dup)
        ep.instance_variable_set(:@returns, endpoint.returns.dup)
        ep.instance_variable_set(:@parent, self)
      end
      @children[:types].merge!(other_yard.instance_variable_get(:@children)[:types])
      @children[:payloads].merge!(other_yard.instance_variable_get(:@children)[:payloads])
    end
    
    def inspect
      "<#Y:#{name}" +
      (endpoints.empty? ? '' : " endpoints: #{endpoints.inspect}") +
      (yards.empty? ? '' : " namespaces: #{yards.inspect}") +
      ">"
    end

    def tree
      Landscapist::Renderer::Tree.new(self).to_s
    end

    def swagger
      Landscapist::Renderer::Swagger.new(self).to_s
    end

    def typescript
      Landscapist::Renderer::Typescript.new(self).to_s
    end

    class DSL < Landscapist::Definition::DSL
    
      def path(url_fragment)
        set_path url_fragment
      end
    
      def version(v)
        set_version v
      end
      
      def namespace(name, &block)
        Landscapist::Yard::DSL.new(get_yard(name)).instance_eval(&block)
      end
      
      def extends(other_yard)
        import_yard(other_yard)
      end
    
      def endpoint(name, &block)
        Landscapist::Endpoint::DSL.new(new_endpoint(name)).instance_eval(&block)
      end
    
      def payload(name, &block)
        Landscapist::Payload::DSL.new(new_payload(name)).instance_eval(&block)
      end
    
      def type(name, &block)
        Landscapist::Type::DSL.new(new_type(name)).instance_eval(&block)
      end
    end
    
  end
end
