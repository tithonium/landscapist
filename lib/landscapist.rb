require 'delegate'
require 'rack'
require 'pathname'

require "landscapist/version"
require "landscapist/exceptions"

# require "active_support/inflector"

require "landscapist/definition"
require "landscapist/yard"
require "landscapist/endpoint"
require "landscapist/payload"
require "landscapist/type"
require "landscapist/basic_types"
require "landscapist/renderer"

module Landscapist
  class << self
    def clear
      @yard = nil
    end

    def landscape(name = nil, &block)
      Landscapist::Yard::DSL.new(yard(name)).tap{|y| y.instance_eval(&block) }
    end

    def yard(name = nil)
      (@yards ||= {})[name] ||= Landscapist::Yard.new(name).tap{|y| y.set_path('/') }
    end

    def parse(filename)
      landscape(filename) { include(filename) }
    end
  end
end

# module Kernel
#   def landscape(name = nil, &block)
#     Landscapist.landscape(name, &block)
#   end
# end
