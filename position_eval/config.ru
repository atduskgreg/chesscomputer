require 'rubygems'
require 'rack/contrib'
require './app'
use Rack::JSONP
run Sinatra::Application