if ARGV.length < 1
	puts "usage: ruby position_choice path/to/player_games.pgn"
	exit
end

require 'pathname'
require './position_analysis'
require 'bundler/setup'
require 'pgn'
require 'descriptive_statistics'


STOCKFISH_PATH = Pathname(__FILE__).parent + "bin" + "stockfish"

def make_player_regex(filename)
	parts = filename.split(/\/|\./)
	last_name = parts[parts.length - 2].downcase
	return Regexp.new last_name, Regexp::IGNORECASE
end

player_regex = make_player_regex(ARGV[0])
games = PGN.parse(open(ARGV[0]).read)

pa = PositionAnalysis.new STOCKFISH_PATH.to_s



terms = ["Material", "Imbalance", "Pawns", "Knights", "Bishops", "Rooks", "Queens", "Mobility", "King safety", "Threats", "Passed pawns", "Space", "Total"]
result = {}
terms.each{|term| result[term] = {:eg => [], :mg => []}}


games[0..50].each_with_index do |game,i|
puts i	
	player = (game.tags["Black"] =~ player_regex) ? :black : :white
	
	game.positions.each_with_index do |pos, i|
	 	if (pos.player == player) && (i < game.positions.length - 2) # there's a next move to compare to
			r = pa.compare(game.positions[i].to_fen, game.positions[i+1].to_fen, :side => player)
			terms.each do |term|
				result[term][:mg] << r[term][:mg]
				result[term][:eg] << r[term][:eg]
			end
	 	end
	end

end

result.each do |term,values|

	puts term
	puts "mid-game mean: #{values[:mg].mean}"
	puts "end-game mean: #{values[:eg].mean}"

	# puts
	# puts "mid-game values:"
	# puts values[:mg].inspect
	# puts
	# puts "end-game values"
	# puts values[:eg].inspect
	# puts
	# puts
	puts
end