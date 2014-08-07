if ARGV.length < 1
	puts "usage ruby analyze_positions.rb <source-identifier>"
	puts "\tRequires a source identifier like 'chessgames.com-2014.pgn' for partitioning."
	exit
end

require './models'
require './graceful_quit'
source = ARGV[0]

SEARCH_DEPTH = 16
STOCKFISH = "./../../Stockfish-eval/src/stockfish"

GracefulQuit.enable
while true do
	g = Game.first :offset => rand(Game.count), :source => source
	if g
		puts "Game #{g.id}: loaded? #{g.positions_loaded}"
		if !g.positions_loaded
			puts "\tloading positions"
			g.load_positions!
			g.positions_loaded = true
			g.save
			puts "\t#{g.positions.count} positions loaded"
		end

		pos = g.positions.next
		if pos
			puts "Searching position: #{pos.fen}"
			result = `#{STOCKFISH} position #{pos.fen} go depth #{SEARCH_DEPTH}`
			parts = result.split(/\n/).last.split(" ")
			bestmove = parts[1]
			score = parts[3]

			puts "bestmove: #{bestmove} score: #{score}"
			pos.bestmove = bestmove
			pos.score = score
			pos.checked = true
			pos.save
		end
	end
	GracefulQuit.check("Finished position. Quitting.")
end