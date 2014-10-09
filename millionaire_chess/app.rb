require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'pgn'
require './models'
require 'json'
require 'open-uri'
# require 'sinatra/cross_origin'
require 'rack/cors'

use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '/position_result', :headers => :any, :methods => [:post]
    # allow.resource '/file/at/*',
    #     :methods =&gt; [:get, :post, :put, :delete],
    #     :headers =&gt; :any,
    #     :max_age =&gt; 0
  end
end

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

	def piece_hash
	  {'k' => "\u{265A}",
       'q' => "\u{265B}",
       'r' => "\u{265C}",
       'b' => "\u{265D}",
       'n' => "\u{265E}",
       'p' => "\u{265F}",
       'K' => "\u{2654}",
       'Q' => "\u{2655}",
       'R' => "\u{2656}",
       'B' => "\u{2657}",
       'N' => "\u{2658}",
       'P' => "\u{2659}"}
	end

end

get "/" do
	redirect "/players"
end

get "/pgn_proxy" do
	content_type :json
	{"pgn" => open("http://gregborenstein.com/assets/chess/games.pgn").read}.to_json
end

get "/players" do
	@players = Player.all
	erb :players
end

get "/player/:player_name" do
	@player = Player.search params[:player_name]
	if !@player
		redirect "/players"
	end
		
	erb :player
end

get "/matchup/:player1/v/:player2" do
	@player1 = Player.search params[:player1]
	@player2 = Player.search params[:player2]

	unless @player1 && @player2
		redirect "/players"
	end

	erb :matchup
end

get "/current_score" do
	content_type :json

	games = PGN.parse(params[:pgn])
    fen = games[0].positions.last.to_fen.to_s
    pr = PositionResult.first :fen => fen

    r = {}
    if pr 
    	r = pr.analysis
    	r["found"] = true 
    else
    	r["found"] = false
    end

    r["boardId"] = params[:boardId]
	r["positionKey"] = params[:positionKey]

    r.to_json

end

post "/stockfish_query" do
	content_type :json
	pr = PositionResult.result_for(params[:pgn])

	r = pr.analysis

	r["boardId"] = params[:boardId]
	r["positionKey"] = params[:positionKey]
	r["bestmove"] = pr.bestmove
	r["score"] = pr.cp_score
	r["fen"] = pr.fen
	r.to_json
end

post "/position_result" do
	# cross_origin
	# headers 'Access-Control-Allow-Origin'  => 'https://your.site.com'

	content_type :json
	r = PositionResult.first_or_create :fen => params[:fen], :cp_score => params[:score], :bestmove => params[:bestmove]
	# r["boardId"] = params[:boardId]
	# r["positionKey"] = params[:positionKey]
	r.to_json
end

get "/summary" do
	@summaries = Game.all_events
	erb :summaries
end

get "/summary/:event" do
	@event = params[:event]
	@sacrifice_games = Game.all :is_sacrifice => true, :event => params[:event]
	@sacrifice_games.sort!{|g| g.final_material[:margin_of_victory].abs}
	erb :summary
end

post "/pgn_email" do
	raise params.inspect
	pgn = PGN.parse(params["attachments"]["0"][:tempfile].read)
	puts pgn.inspect
end