if ARGV.length < 1
	puts "usage: ruby position_choice path/to/player_games.pgn"
	exit
end

ARGV = ["../../data/players/ASHLEY.PGN"]

require 'pathname'
require './position_analysis'
require 'bundler/setup'
require 'pgn'

STOCKFISH_PATH = Pathname(__FILE__).parent + "bin" + "stockfish"

def make_player_regex(filename)
	parts = filename.split(/\/|\./)
	last_name = parts[parts.length - 2].downcase
	return Regexp.new last_name, Regexp::IGNORECASE
end

player_regex = make_player_regex(ARGV[0])
games = PGN.parse(open(ARGV[0]).read)

pa = PositionAnalysis.new STOCKFISH_PATH.to_s

game = games[0]

pa.compare(game.positions[11].to_fen, game.positions[12].to_fen, :side => :black)

# player = (game.tags["Black"] =~ player_regex) ? :black : :white

# game.positions.each_with_index do |pos, i|
# 	if (pos.player == player) && (i < game.positions.length - 1)

# 	end
# end