require 'pathname'
require 'fileutils'

module Landscapist
  class Viewer
    class Swagger
      def initialize(file)
        @templates = Hash[*IO.read(__FILE__).split("__END__").last.split(/\n==========(\S+)\n/)[1..-1]]
        @base = Pathname.new(__dir__.sub(%r{/lib.*},''))
        @file = file
      end

      def call(env)

        case env['PATH_INFO']
        when '/'
          html = @templates['index.html']
          ['200', {'Content-Type' => 'text/html'}, [html]]
        when '/viewer.css'
          ['200', {'Content-Type' => 'text/css'}, [@templates['viewer.css']]]
        when '/swagger.yml'
          # Landscapist.clear
          ['200', {'Content-Type' => "text/yaml", 'Access-Control-Allow-Origin' => '*'}, [Landscapist.parse(@file).swagger]]
        else
          filepath = Pathname.new(@base + env['PATH_INFO'][1..-1])
          if filepath.exist?
            ['200', {'Content-Type' => "text/#{filepath.extname.to_s[1..-1]}"}, [filepath.read]]
          else
            ['404', {'Content-Type' => 'text/html'}, ['Not Found']]
          end
        end

      end

    end
  end
end



__END__
==========viewer.css
html
{
  box-sizing: border-box;
  overflow: -moz-scrollbars-vertical;
  overflow-y: scroll;
}
*,
*:before,
*:after
{
  box-sizing: inherit;
}

body {
  margin:0;
  background: #fafafa;
}
#doclist {
  font-size: 20px;
  font-family: monospace;
  margin-left: 3em;
}
#doclist li a {
  text-decoration: none;
}
==========index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>????</title>
  <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,700|Source+Code+Pro:300,600|Titillium+Web:400,600,700" rel="stylesheet">
  <link rel="stylesheet" type="text/css" href="/vendor/swagger-ui/dist/swagger-ui.css" >
  <link rel="stylesheet" type="text/css" href="/viewer.css" >
</head>

<body>

<div id="swagger-ui"></div>

<script src="/vendor/swagger-ui/dist/swagger-ui-bundle.js"> </script>
<script src="/vendor/swagger-ui/dist/swagger-ui-standalone-preset.js"> </script>
<script>
window.onload = function() {

  // Build a system
  const ui = SwaggerUIBundle({
    url: "/swagger.yml",
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout",
    validatorUrl: null
  })

  window.ui = ui
}
</script>
</body>

</html>
