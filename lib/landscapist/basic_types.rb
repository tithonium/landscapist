require "landscapist/type"

%i[null string integer float date time datetime url boolean enum array].each do |core_type|
  Landscapist::Type.define_core_type(core_type)
end
