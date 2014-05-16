if ARGV.length < 1
	puts "usage: ruby load_games.rb <path_to_pgn>"
	exit
end

require 'pgn'
require './models.rb'

puts "Opening #{ARGV[0]} to load games"
games = PGN.parse(File.read(ARGV[0]))

games.each_with_index do |game, gi|
	puts "GAME CREATED #{gi+1}/#{games.length}"
	g = Game.new
	g.metadata = game.tags
	g.metadata["result"] = game.result
	g.save

	game.fen_list.each_with_index do |fen, i|
		puts "\tgame #{gi+1}/#{games.length} pos #{i+1}/#{game.fen_list.length}"
		g.positions.create :fen => fen, :position_number => i
	end

end