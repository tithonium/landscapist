require "landscapist/type"

{
  null:     nil,
  string:   {},
  integer:  {},
  float:    {},
  date:     {type: 'string', format: 'date'},
  time:     {type: 'string', format: 'date-time'},
  datetime: {type: 'string', format: 'date-time'},
  url:      {type: 'string', format: 'url'},
  boolean:  {},
  enum:     {type: 'string'},
  tzname:   {type: 'string', format: 'iana-timezone'},
}.each do |core_type, swagger_overrides|
  Landscapist::Type.define_core_type(core_type, swagger_overrides)
end
