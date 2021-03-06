require "landscapist/renderer/tree"
require "landscapist/renderer/swagger"
require "landscapist/renderer/typescript"

module Landscapist
  class Renderer
    
    attr_reader :root, :target
    def initialize(root, target)
      @root = root
      @target = target
    end
    
    def respond_to_missing?(name, include_private = false)
      target.respond_to?(name) || super
    end

    def method_missing(method, *args, &block)
      if target.respond_to?(method)
        target.public_send(method, *args, &block)
      else
        super
      end
    end
  end
end
