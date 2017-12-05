require 'yaml'

require "landscapist/renderer/swagger/schema"
require "landscapist/renderer/swagger/payload"
require "landscapist/renderer/swagger/endpoint"

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
        
        attr_accessor :definition_data
        def initialize(target)
          super(self, target)
          @definition_data = {}
        end
      
        def to_s
          YAML.dump(_deep_stringify_keys_in_object(swagger))
        end
      
        def swagger
          process_references(swagger_with_unprocessed_references)
        end
        
        def swagger_with_unprocessed_references
          {
            swagger: '2.0',
            info: {
              title:       '',
              description: '',
              version:     '1.0',
            },
            host: 'example.com',
            schemes: ['https'],
            basePath: '/',
            produces: ['application/json'],
            paths: paths,
            # parameters: parameters,
          }
        end
        
        def process_references(structure)
          _process_references(structure)
          structure[:definitions] = definitions if root.definition_data.size > 0
          structure
        end
        
        def _process_references(structure)
          reference_containers = _find_references(structure)
          references = reference_containers.group_by {|substructure| substructure[:'$ref'] }
          references.each do |reference, containers|
            definition_name = reference.full_name.gsub('::', '')
            root.definition_data[definition_name] ||= _process_references(Landscapist::Renderer::Swagger::Payload.new(root, reference).swagger)
            containers.each do |substructure|
              substructure[:'$ref'] = "#/definitions/#{definition_name}"
            end
          end
          structure
        end
        
        def _find_references(structure)
          case structure
          when Array
            structure.flat_map {|substructure| _find_references(substructure) }
          when Hash
            return [structure] if structure[:'$ref']
            structure.each_value.flat_map {|substructure| _find_references(substructure) }
          else
            []
          end
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
          descendant_endpoints.each_with_object({}) do |endpoint, h|
            endpoint_renderer = Landscapist::Renderer::Swagger::Endpoint.new(root, endpoint)
            path = endpoint_renderer.path
            h[path] ||= {}
            h[path][endpoint.http_method.to_s.downcase] = endpoint_renderer.swagger
          end
        end
      
        def parameters
          []
        end
      
        def definitions
          definition_data.sort.each_with_object({}) {|(name, definition), h|
            h[name] = definition
          }
        end
      
      
      end
    end
  end
end
