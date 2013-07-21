ENV["RACK_ENV"] ||= "development"

require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

ENV['APP_ROOT'] ||= File.expand_path('../..', __FILE__)


# Add the lib folder to the load path
$LOAD_PATH.unshift File.join(ENV['APP_ROOT'], 'lib')


# Require initializers
Dir[ENV['APP_ROOT'] + '/config/initializers/*.rb'].each do |file|
  require file
end


# Require libraries
Dir[ENV['APP_ROOT'] + '/lib/**/*.rb'].each do |file|
	require file
end


Encoding.default_external = 'utf-8'

if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'
  require 'debugger'
end