require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'pgn'

helpers do
	def html_board(position)
		result = "<table>"
		position.inspect.split(/\n/).each do |row| 
			result << "<tr>"
			row.split("").each do |square|
				result << "<td>#{square}</td>" 
			end
			result << "</tr>"
		end
		result << "</table>"
		result 
	end

end

get "/" do
	# fake games for testing
	@games = (0..20).collect{ PGN::Game.new([])}
	erb :index
end

post "/pgn_email" do
	pgn = PGN.parse(params["attachments"]["0"][:tempfile].read)
	puts pgn.inspect
end