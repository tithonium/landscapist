module Landscapist
  class Renderer
    class Typescript
      class Payload < Renderer
        
        attr_accessor :indent
        def initialize(target, depth = 0, indent = 0)
          super(self, target)
          @depth = depth
          @indent = indent
        end

        def to_s
          to_a.join("\n")
        end

        def to_a
          if target.union?
            [
              "#{_indent}type #{target.name} = #{target.union_members.map(&:name).join(' | ')}",
            ]
          else
            content = []
            content << "#{_indent}interface #{target.name} {"
            @indent += 1
            target.contents.each do |key, spec|
              content << "#{_indent}#{key}: #{_translate_spec(key, spec)}"
            end
            @indent -= 1
            content << "#{_indent}}"
            content
          end
        end
        
        def _indent
          "  " * indent
        end

        def _translate_spec(key, spec)
          if spec.is_a?(Array) && spec.length == 1
            "#{_translate_spec(key, spec.first)}[]"
          elsif spec.is_a?(Array)
            spec.map(&:name).join(' | ')
          elsif spec == Landscapist::Type::CoreType.enum
            target.content_metadata[key].map {|s| _translate_spec(key, s) }.join(' | ')
          elsif spec == Landscapist::Type::CoreType.boolean
           'nullableBoolean'
          elsif spec == Landscapist::Type::CoreType.integer
           'number'
          elsif spec.is_a?(Landscapist::Type::CoreType)
            spec.swagger_overrides&.[](:type) || spec.name
          elsif spec.is_a?(Landscapist::Definition)
            spec.name
          elsif spec.is_a?(String) || spec.is_a?(Symbol)
            "'#{spec}'"
          else
            spec.to_s
          end
        end

      end
    end
  end
end
