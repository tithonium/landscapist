module Landscapist
  class Payload < Definition
    
    attr_reader :contents, :content_metadata
    def initialize(*)
      super
      @contents = {}
      @content_metadata = {}
    end
    
    def add_content(name, type, details = nil)
      cleaned_name = name.to_s.gsub(/([a-z])([A-Z])/){$1+'_'+$2.downcase}.downcase.to_sym
      @contents[cleaned_name] = _resolve_spec(type)
      @content_metadata[cleaned_name] = details if details
    end
    
    def merge_other_payloads(others)
      key_counts = Hash.new{|h,k|h[k] = 0}
      constants = Hash.new{|h,k|h[k] = []}
      details = {}
      others.each do |other|
        other = _resolve_spec(other) unless other.is_a?(Definition)
        other.contents.each do |name, spec|
          unless spec.is_a?(Definition)
            constants[name] << spec
            spec = :CONSTANT
          end
          key_counts[[name, spec]] += 1
          details[name] = other.content_metadata[name] if other.content_metadata[name]
        end
      end
      key_counts.each do |(name, spec), count|
        corrected_name = name
        corrected_name = "#{name}?".to_sym unless count == others.count
        if constants[name].size > 0
          add_content(corrected_name, :enum, constants[name])
        else
          add_content(corrected_name, spec, details[name])
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
