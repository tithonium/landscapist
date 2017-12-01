module Landscapist
  class Renderer
    class Swagger
      class Schema < Renderer
        
        attr_reader :target_type, :details
        def initialize(root, target_type, target, details = {})
          super(root, target)
          @target_type = target_type
          @details = details
        end
        
        def to_s
          YAML.dump(swagger)
        end
        
        def swagger
          s = (case target_type
          when :array
            {
              type: 'array',
              items: properties,
            }
          when :scalar
            {
              type: type,
            }
          else
            {
              type: type,
              properties: properties,
            }
          end).merge(details)
          if s[:type] == 'object' && Hash === s[:properties] && s[:properties].keys == [:'$ref']
            return s[:properties]
          end
          s
        end
        
        def type
          case target_type
          when :array
            'array'
          when :scalar
            target.swagger_name
          else
            'object'
          end
        end
        
        def properties
          case target
          when Hash
            target.each_with_object({}) do |(name, spec), h|
              h[name.to_s] = Landscapist::Renderer::Swagger::Schema.new(root, nil, spec).properties
            end
          when Array
            Array(target).each_with_object({}) do |spec, h|
              h.merge!(Landscapist::Renderer::Swagger::Schema.new(root, nil, spec).properties)
            end
          when Landscapist::Payload
            {
              '$ref': target
            }
          when Landscapist::Type
            return nil if target.name == 'null'
            {
              type: target.name,
              required: true,
              # format: int32
              # description: Number of records skipped before returning.
              # default: 0
              # minimum: 0
            }.compact.tap do |s|
              s.merge!(target.swagger_overrides) if target.respond_to?(:swagger_overrides)
            end
          else
            target
          end
        end
      
      
      end
    end
  end
end
