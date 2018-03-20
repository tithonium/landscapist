require 'active_support/inflector'
module Landscapist
  class Renderer
    class Swagger
      class Endpoint < Renderer
        class Parameters < Landscapist::Renderer::Swagger::Schema
          
          attr_reader :endpoint
          def initialize(root, endpoint, target_type, target, details = {})
            super(root, target_type, target, details)
            @endpoint = endpoint
          end
          
          def swagger
            location = case endpoint.http_method
            when :get, :delete
              'query'
            else
              'body'
            end
            case target_type
            when :hash
              target.map do |key, spec|
                schema = case spec
                when Landscapist::Payload
                  {
                    name:     key.to_s.sub(/\?\Z/, ''),
                    in:       location,
                    required: !key.to_s.end_with?('?'),
                    type:     'object',
                    schema:   {
                      '$ref': spec,
                    },
                  }
                else
                  {
                    name:     key.to_s.sub(/\?\Z/, ''),
                    in:       location,
                    required: !key.to_s.end_with?('?'),
                    type:     'string',
                  }.merge(Landscapist::Renderer::Swagger::Schema.new(root, nil, spec).properties)
                end
              end
            when :payload
              target.contents.map do |name, spec|
                details = target.content_metadata[name]
                field_name = name.to_s.sub(/\?\Z/,'')
                definition = {
                  name:     field_name,
                  in:       location,
                }
                schema = Landscapist::Renderer::Swagger::Schema.new(root, nil, spec)
                case spec
                when Array, ::Landscapist::Payload, ::Landscapist::Type
                  definition.merge! schema.properties
                else
                  definition.merge! schema.properties[:schema]
                end
                definition[:required] = !name.to_s.end_with?('?')
                definition
              end
            end
          end
          
        end
      end
    end
  end
end
