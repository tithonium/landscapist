module Landscapist
  class Renderer
    class Swagger
      class Endpoint < Renderer
        class Response < Renderer
          
          attr_reader :status, :return_type
          def initialize(root, status, return_type, target)
            super(root, target)
            @status = status
            @return_type = return_type
          end
          
          def to_s
            YAML.dump(swagger)
          end
        
          def swagger
            {
              description: Rack::Utils::HTTP_STATUS_CODES[status],
              schema: schema
              # examples: {
              #   'content_type': {}
              # },
            }.compact
          end
        
          def schema
            return nil if target == Type::CoreType.null
            Landscapist::Renderer::Swagger::Schema.new(root, return_type, target).swagger
          end
          
        end
      end
    end
  end
end
