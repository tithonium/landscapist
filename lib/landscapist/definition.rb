module Landscapist
  class Definition
    
    attr_accessor :name
    attr_reader :parent
    def initialize(name, parent = nil)
      @name = name.to_s
      @parent = parent
      @path = nil
    end
    
    def full_name
      return name unless parent
      return parent.full_name unless name
      return name if parent.full_name == ''
      (parent.full_name + '::' + name) .gsub(/\/\/+/, '/')
    end
    
    def full_path
      return path unless parent
      return parent.full_path unless path
      (parent.full_path + '/' + path) .gsub(/\/\/+/, '/')
    end
    
    def expanded_path
      full_path.gsub(/\{\{([a-z0-9_]+)\}\}/){parental_delegator.send($1) || "{{#{$1}}}"}.gsub(/\/\/+/, '/')
    end
    
    def parental_delegator
      @parental_delegator ||= ParentalDelegator.new(self)
    end

    class ParentalDelegator
      def initialize(root)
        @delegated_root = root
        if root.parent
          @parent_delegator = self.class.new(root.parent)
        end
      end
      
      def respond_to_missing?(*args)
        @delegated_root.respond_to?(*args) || (@parent_delegator && @parent_delegator.respond_to?(*args))
      end
      
      def method_missing(m, *args, &block)
        v = @delegated_root.send(m, *args) if @delegated_root.respond_to?(m)
        v ||= @parent_delegator.send(m, *args) if @parent_delegator
        v
      end
      
    end

    class DSL < SimpleDelegator
      def param(v) ; __getobj__.param = v.to_s ; end
      
      def path(*a)
        __getobj__.set_path a.first
      end
    end
    
    private
    
    def _resolve_spec(spec)
      return spec unless spec.is_a?(Symbol) || spec.is_a?(Array)
      # return spec if spec.is_a?(Definition)
      return spec.map(&method(:_resolve_spec)) if spec.is_a?(Array)
      parent.find_payload(spec) || Type.find_core_type(spec) || parent.get_type(spec)
    end
    
  end
end
