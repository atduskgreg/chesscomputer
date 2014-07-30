if ARGV.length < 2
	puts "usage: ruby load_games.rb <path_to_pgn> <source>"
	exit
end

# https://github.com/capicue/pgn
require 'pgn'
require './models'

puts "Opening #{ARGV[0]} to load games"
source = ARGV[1]
puts "Source is: #{ARGV[1]}"

f = File.read(ARGV[0])

# Individual games can be badly formed so we need
# to manually split the file into many games so
# we can rescue individual crashes in PGN's parser
game_segments = f.split(/\n\n\n/)
unparseable = 0

game_segments.each_with_index do |segment, i|
	begin
		games = PGN.parse(segment)
		raise unless games.length == 1

		puts "#{i}/#{game_segments.length} #{games[0].result}"

		Game.create :result => games[0].result, 
					:pgn_string => segment,
					:source => source

	rescue Whittle::Error
		unparseable = unparseable + 1
		puts "========Whittle::UnconsumedInputError======="
		puts "#{i} ||| #{segment}"
		puts "============================================"
	end
end

puts "#{unparseable} unparseable games"