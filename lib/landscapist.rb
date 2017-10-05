require 'delegate'

require "landscapist/version"
require "landscapist/exceptions"

require "active_support/inflector"

require "landscapist/definition"
require "landscapist/yard"
require "landscapist/endpoint"
require "landscapist/payload"
require "landscapist/type"
require "landscapist/basic_types"
require "landscapist/renderer"

module Landscapist
  def self.landscape(&block)
    Landscapist::Yard::DSL.new(yard).instance_eval(&block)
  end
  
  def self.yard
    @yard ||= Landscapist::Yard.new(nil).tap{|y| y.set_path('/') }
  end
end

module Kernel
  def landscape(&block)
    Landscapist.landscape(&block)
  end
end
