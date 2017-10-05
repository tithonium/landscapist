module Landscapist
  class Error < StandardError ; end
  
  class InvalidDefiniton < Error ; end
  
  class MixedReturnType < InvalidDefiniton ; end

end