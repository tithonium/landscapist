module Landscapist
  class Renderer
    class Typescript
      class Type < Renderer
        
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
          if target.base_type == :enum
            [
              "#{_indent}type #{target.name} = #{target.values.map{|spec| "'#{spec}'" }.join(' | ')}",
            ]
          else
            [
              "#{_indent}type #{target.name} = #{target.base_type}#{" // format: /#{target.format}/" if target.format}",
            ]
          end
        end
        
        def _indent
          "  " * indent
        end

      end
    end
  end
end
