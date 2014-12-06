require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'pgn'

get "/" do
	"welcome to deep view. <a href='/upload'>upload a file</a>"
end

get "/upload" do
	erb :upload
end

post "/pgn" do
	@pgn = PGN.parse(open(params[:file][:tempfile]).read)
	erb :pgn
end