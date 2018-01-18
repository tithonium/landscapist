# LandscAPIst

Landscapist is an API definition tool.

## Why?

Because I hate writing Swagger, but it's a 'widely supported standard', and none of the other options are any better. So I decided to write my own ruby DSL for defining my APIs, with tools to generate Swagger.

## Usage

### Generate a swagger document

bundle exec ./exe/landscapist swagger ~/workspace/myapp/doc/apis/apis.rb

### Generate typescript interfaces

bundle exec ./exe/landscapist typescript ~/workspace/myapp/doc/apis/apis.rb

### Run a webserver with Swagger-UI

bundle exec ./exe/landscapist server ~/workspace/myapp/doc/apis/apis.rb
