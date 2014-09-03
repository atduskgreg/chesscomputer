require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'pgn'


get "/" do
	"pgn email receiver"
end

post "/pgn_email" do
	puts params.keys
	puts params["attachments"].keys
	puts params["attachments"]["0"].keys
	pgn = PGN.parse(params["attachments"]["0"][:tempfile].read)
	puts pgn.inspect
end