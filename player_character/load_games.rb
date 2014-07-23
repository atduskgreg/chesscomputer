if ARGV.length < 1
	puts "usage: ruby load_games.rb <path_to_pgn>"
	exit
end

# https://github.com/capicue/pgn
require 'pgn'

puts "Opening #{ARGV[0]} to load games"
games = PGN.parse(File.read(ARGV[0]))

games.each do |game|
	game.tags #metadata
	game.result #result
	game.position.each do |position|
		position.board
		position.player
	end
end