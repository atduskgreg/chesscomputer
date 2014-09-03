require 'rubygems'
require 'bundler/setup'
require 'sinatra'


get "/" do
	"pgn email receiver"
end

post "/pgn_email" do
	puts params.inspect
end