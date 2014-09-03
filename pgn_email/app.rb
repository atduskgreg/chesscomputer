require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'pgn'


get "/" do
	"pgn email receiver"
end

post "/pgn_email" do
	pgn = PGN.parse(params["attachments"]["0"][:tempfile].read)
	puts pgn.inspect
end