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
                    name:     key.to_s,
                    in:       location,
                    required: true,
                    type:     'object',
                    schema:   {
                      '$ref': spec,
                    },
                  }
                else
                  {
                    name:     key.to_s,
                    in:       location,
                    required: true,
                    type:     'string',
                  }.merge(Landscapist::Renderer::Swagger::Schema.new(root, nil, spec).properties)
                end
              end
            when :payload
              target.contents.map do |name, spec|
                details = target.content_metadata[name]
                field_name = name.to_s.sub(/\?\Z/,'')
                definition = {
                  name:     name.to_s,
                  in:       location,
                  required: true,
                }
                schema = Landscapist::Renderer::Swagger::Schema.new(root, nil, spec)
                case spec
                when Array, ::Landscapist::Payload, ::Landscapist::Type
                  definition.merge schema.properties
                else
                  definition.merge schema.properties[:schema]
                end
                
                # [{
                #   name: ActiveSupport::Inflector.underscore(target.name),
                #   in:   location,
                #   required: true,
                #   schema: {
                #     '$ref': target
                #   },
                # }]
              end
            end
          end
          
        end
      end
    end
  end
end
