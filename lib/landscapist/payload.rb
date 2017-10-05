module Landscapist
  class Payload < Definition
    
    attr_reader :contents
    def initialize(*)
      super
      @contents = {}
    end
    
    def add_content(name, type, details = nil)
      @contents[name.to_s.gsub(/([a-z])([A-Z])/){$1+'_'+$2.downcase}.downcase.to_sym] = _resolve_spec(type)
    end
    
    def merge_other_payloads(others)
      key_counts = Hash.new{|h,k|h[k] = 0}
      constants = Hash.new{|h,k|h[k] = []}
      others.each do |other|
        other = _resolve_spec(other) unless other.is_a?(Definition)
        other.contents.each do |name, spec|
          unless spec.is_a?(Definition)
            constants[name] << spec
            spec = :CONSTANT
          end
          key_counts[[name, spec]] += 1
        end
      end
      key_counts.each do |(name, spec), count|
        name = "#{name}?".to_sym unless count == others.count
        if constants[name]
          add_content(name, :enum, constants[name])
        else
          add_content(name, spec)
        end
      end
    end
    
    attr_writer :param
    def to_param
      @param || self.name.gsub(/([a-z])([A-Z])/){$1+'_'+$2.downcase}.downcase
    end
    
    def inspect
      # "<#P:#{name} #{contents.keys.join(', ')}>"
      "<#P:#{name} #{contents.map{|k,v| "#{k}:#{v.inspect}"}.join(', ')}>"
    end
    
    class DSL < Landscapist::Definition::DSL
      
      def union(*others)
        __getobj__.merge_other_payloads(others)
      end
      
      def method_missing(m, *args)
        __getobj__.add_content(m, *args)
      end
    end
  end
end
