module Landscapist
  class Renderer
    class Swagger
      class Payload < Landscapist::Renderer::Swagger::Schema
        
        def initialize(root, target)
          super(root, nil, target)
        end
        
        def swagger
          properties = target.contents.each_with_object({}) do |(name, spec), h|
            details = target.content_metadata[name]
            field_name = name.to_s.sub(/\?\Z/,'')
            h[field_name] = case spec
            when Array
              types = spec.map {|subspec| Landscapist::Renderer::Swagger::Schema.new(root, :array, subspec).properties.tap{|h| h.delete(:required) } }
              types = if types.length == 1
                types.first
              else
                { 'anyOf': types }
              end
              {
                type: 'array',
                items: types
              }
            when String
              {
                type:        'string',
                enum:        [spec],
                description: 'hard-coded value',
              }
            when Landscapist::Type::CoreType.enum
              {
                type:        'string',
                enum:        details.map(&:to_s),
              }
            else
              Landscapist::Renderer::Swagger::Schema.new(root, nil, spec).properties.tap{|h| h[:required] = false if name.to_s.end_with?('?')}
            end
          end
          required = properties.select{|k,v| Hash === v && v.delete(:required) }.keys
          {
            type:       'object',
            properties: properties,
            required:   required.size > 0 ? required : nil,
          }.compact
        end
        
      end
    end
  end
end
