module Landscapist
  class Renderer
    class Swagger
      class Endpoint < Renderer
        
        def to_s
          YAML.dump(swagger)
        end
        
        def path
          # expanded_path + '#' + full_name.gsub(/[^a-z0-9]/i, '')
          expanded_path + '#' + name.gsub(/[^a-z0-9]/i, '')
        end
        
        def swagger
          {
            summary: nil,
            description: nil,
            parameters: parameters,
            responses: responses,
          }.compact
        end
        
        def parameters
          expects && Landscapist::Renderer::Swagger::Endpoint::Parameters.new(root, target, expect_type, expects).swagger
        end
        
        def responses
          returns.sort.each_with_object({}) do |(status, returns), hh|
            hh[status] = Landscapist::Renderer::Swagger::Endpoint::Response.new(root, status, return_type[status], returns).swagger
          end
        end
        
      end
    end
  end
end

require "landscapist/renderer/swagger/endpoint/response"
require "landscapist/renderer/swagger/endpoint/parameters"
