require './config/environment'
require 'app'

run Rack::URLMap.new \
  "/"       => Smoothie::Application.new
