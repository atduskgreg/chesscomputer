require 'bundler/setup'

require './position_models'
require './position_analysis'
require './graceful_quit'
require 'pgn'
require 'descriptive_statistics'
require 'pathname'


STOCKFISH_PATH = Pathname(__FILE__).parent + "bin" + "stockfish"
pa = PositionAnalysis.new STOCKFISH_PATH.to_s
terms = ["Material", "Imbalance", "Pawns", "Knights", "Bishops", "Rooks", "Queens", "Mobility", "King safety", "Threats", "Passed pawns", "Space", "Total"]

# load up previous results from a file
result = YAML.load(open("running_choice_average.yml").read)
game_ids = open("averaged_games.csv").read.split("\n").collect{|l| l.to_i}

GracefulQuit.enable

while true do
	g = Game.first :offset => rand(Game.count)
	puts "processing #{g.id}"

	if g && !game_ids.include?(g.id)
		game = PGN.parse(g.pgn_string).first


		# pick a side
		player = rand > 0.5 ? :white : :black
	
		game.positions.each_with_index do |pos, i|
		 	if (pos.player == player) && (i < game.positions.length - 2) # there's a next move to compare to
		 		puts "\t#{i}"

		 		result["choice_count"] = result["choice_count"] + 1


				r = pa.compare(game.positions[i].to_fen, game.positions[i+1].to_fen, :side => player)
				terms.each do |term|
					result[term]["mg"] = result[term]["mg"] + (r[term][:mg] - result[term]["mg"])/result["choice_count"].to_f
					result[term]["eg"] = result[term]["eg"] + (r[term][:eg] - result[term]["eg"])/result["choice_count"].to_f
				end


		 	end
		end
		
		puts "Saving running_choice_average.yml"
		File.open("running_choice_average.yml", "w"){|f| f << YAML.dump(result) }
		game_ids << g.id
		File.open("averaged_games.csv","a"){|f| f << "\n#{g.id}"}


		# serialize result and choice count out to a file
		
	end
end

GracefulQuit.check("Finished position. Quitting.")

