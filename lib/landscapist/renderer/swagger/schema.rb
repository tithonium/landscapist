module Landscapist
  class Renderer
    class Swagger
      class Schema < Renderer
        
        attr_reader :target_type
        def initialize(target_type, target)
          @target_type = target_type
          super(target)
        end
      
        def to_s
          YAML.dump(swagger)
        end
        
        def swagger
          {
            type: type,
            properties: properties,
          }
        end
      
        def type
          case target_type
          when :array
            :array
          else
            :object
          end
        end
        
        def properties
          case target
          when Hash
            target.each_with_object({}) do |(name, spec), h|
              h[name.to_s] = Landscapist::Renderer::Swagger::Schema.new(nil, spec).properties
            end
          when Array
            Array(target).each_with_object({}) do |spec, h|
              h.merge!(Landscapist::Renderer::Swagger::Schema.new(nil, spec).properties)
            end
          when Payload
            target.contents.each_with_object({}) do |(name, spec), h|
              STDERR.puts [name, spec].inspect
              h[name.to_s.sub(/\?\Z/,'')] = Landscapist::Renderer::Swagger::Schema.new(nil, spec).properties.tap{|h| h[:required] = false if name.to_s.end_with?('?')}
            end
          when Type
            return nil if target.name == 'null'
            {
              type: target.name,
              # format: int32
              # description: Number of records skipped before returning.
              # default: 0
              # minimum: 0
            }.compact
          else
            target
          end
        end
      
      
      end
    end
  end
end
