require "landscapist/renderer/typescript/type"
require "landscapist/renderer/typescript/payload"
require "active_support/inflector"

module Landscapist
  class Renderer
    class Typescript
      
      def initialize(yard)
        @yard = yard
      end
      def to_s
        Landscapist::Renderer::Typescript::Yard.new(@yard).to_s
      end
      
      
      class Yard < Renderer
        
        attr_accessor :indent
        def initialize(target, depth = 0, indent = 0, declared = false)
          super(self, target)
          @depth = depth
          @indent = indent
          @declared = declared
        end
      
        def to_s
          to_a.join("\n")
        end
      
        def to_a
          content = []
          unless target.name.empty?
            line = [
              _indent,
              @declared ? nil : 'declare ',
              "namespace #{ActiveSupport::Inflector.underscore(target.name)} {",
            ].compact.join
            content << line
            content << '' if (target.types.length + target.payloads.length) >  0
            @indent += 1
            @declared = true
          end
          content += ["#{_indent}type nullableBoolean = boolean | null", ''] if @depth == 0
          target.types.each do |type|
            result = Landscapist::Renderer::Typescript::Type.new(type, @depth + 1, indent).to_a
            content = content + result + [''] if result.length > 0
          end
          target.payloads.each do |type|
            result = Landscapist::Renderer::Typescript::Payload.new(type, @depth + 1, indent).to_a
            content = content + result + [''] if result.length > 0
          end
          target.yards.each do |yard|
            result = Landscapist::Renderer::Typescript::Yard.new(yard, @depth + 1, indent, @declared).to_a
            content = content + result + [''] if result.length > 0
          end
          unless target.name.empty?
            @indent -= 1
            content << "#{_indent}}"
          end
          content
        end
        
        def _indent
          "  " * indent
        end
      
      end
    end
  end
end
