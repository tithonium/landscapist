require 'yaml'

require "landscapist/renderer/swagger/schema"

module Landscapist
  class Renderer
    class Swagger
      
      def initialize(yard)
        @yard = yard
      end
      def to_s
        Landscapist::Renderer::Swagger::Yard.new(@yard).to_s
      end
      
      
      class Yard < Renderer
      
        def to_s
          YAML.dump(_deep_stringify_keys_in_object(swagger))
        end
      
        def swagger
          {
            swagger: '2.0',
            info: {
              title:       '',
              description: '',
              version:     '1.0',
            },
            host: '',
            schemes: ['https'],
            basePath: '',
            produces: ['application/json'],
            paths: paths,
            parameters: parameters,
            definitions: definitions,
          }
        end
        
        def _deep_stringify_keys_in_object(object)
         case object
         when Hash
           object.each_with_object({}) do |(key, value), result|
             result[key.is_a?(Symbol) ? key.to_s : key] = _deep_stringify_keys_in_object(value)
           end
         when Array
           object.map {|e| _deep_stringify_keys_in_object(e) }
         else
           object
         end
       end
        
        def paths
          all_endpoints = descendant_endpoints#endpoints + yards.flat_map{|y| Landscapist::Renderer::Swagger::Yard.new(y).paths }
          STDERR.puts all_endpoints.inspect
          all_endpoints.each_with_object({}) do |endpoint, h|
            path = endpoint.expanded_path + '#' + endpoint.full_name.gsub(/[^a-z]/i, '')
            h[path] ||= {}
            h[path][endpoint.http_method.to_s.downcase] = {
              summary: nil,
              description: nil,
              parameters: endpoint.expects && Landscapist::Renderer::Swagger::Schema.new(endpoint.expect_type, endpoint.expects).swagger,
              responses: endpoint.returns.sort.each_with_object({}) do |(status, returns), hh|
                hh[status] = {
                  description: Rack::Utils::HTTP_STATUS_CODES[status],
                  schema: Landscapist::Renderer::Swagger::Schema.new(endpoint.return_type[status], returns).swagger,
                  # examples: {
                  #   'content_type': {}
                  # },
                }
              end,
            }.compact
          end
        end
      
        def parameters
          []
        end
      
        def definitions
          []
        end
      
      
      end
    end
  end
end
