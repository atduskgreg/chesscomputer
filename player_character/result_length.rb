if ARGV.length != 2
	puts "usage: ruby result_length <\"Player Name\"> <path/to/player.pgn>"
	exit
end


# require './pgn_loader'
require 'descriptive_statistics'
# require 'rubygems'
require 'pgn'
# require 'bundler/setup'
require 'tempfile'

def t_test_lengths(lengths, pop_mean)
	tmp = Tempfile.new("loss_csv")
	tmp.write(lengths.join(","))
	tmp.close
	
	t_result = `python t_test.py #{tmp.path} --population-mean=#{pop_mean}`

	tmp.unlink

	stats = {}
	t_result.split("\n").each{|e| r = e.split(":"); stats[r[0]] = r[1].to_f}
	return stats
end

player = ARGV[0]
games = PGN.parse(open(ARGV[1]).read)

# result types
WHITE_VICTORY = "1-0"
BLACK_VICTORY = "0-1"
DRAW = "1/2-1/2"
result = {:win_lengths => [], :loss_lengths => [], :all_lengths => [], :draw_lengths => []}


games.each do |game|

	result[:all_lengths] << game.moves.length

	if game.result == DRAW
		result[:draw_lengths] << game.moves.length
	end

	if game.tags["Black"] == player
		if game.result == BLACK_VICTORY
			result[:win_lengths] << game.moves.length
		elsif game.result == WHITE_VICTORY
			result[:loss_lengths] << game.moves.length
		end
	else # playing as white
		if game.result == WHITE_VICTORY
			result[:win_lengths] << game.moves.length
		elsif game.result == BLACK_VICTORY
			result[:loss_lengths] << game.moves.length
		end
	end
end



File.open("maurice_loss_lengths.csv", "w"){|f| f << result[:loss_lengths].join(",")}

# we only care want the non-draw games in our total population
pop = []
pop << result[:loss_lengths]
pop << result[:win_lengths]
pop = pop.flatten

puts "Results for #{ARGV[0]} (w/l/d/total #{result[:win_lengths].length}/#{result[:loss_lengths].length}/#{result[:draw_lengths].length}/#{result[:all_lengths].length})"
puts "Average length of win: #{result[:win_lengths].mean}"
puts "Average length of loss: #{result[:loss_lengths].mean}"
puts "Average length of draw: #{result[:draw_lengths].mean}"
puts "Total average length: #{result[:all_lengths].mean}"
puts "Average length w/o draws: #{pop.mean}"

puts


loss_stats = t_test_lengths(result[:loss_lengths], pop.mean)
win_stats = t_test_lengths(result[:win_lengths], pop.mean)


puts "===RESULT==="
puts "=Losses="
puts "t-stat: #{loss_stats["t"]}"
puts "p-value: #{loss_stats["p"]}"

if loss_stats["p"] < 0.05
	puts "*Losses differ significantly in length from the average game*"
else
	puts "*Losses do not differ significantly in length from the average game*"
end
puts
puts "=Wins="
puts "t-stat: #{win_stats["t"]}"
puts "p-value: #{win_stats["p"]}"

if win_stats["p"] < 0.05
	puts "*Wins differ significantly in length from the average game*"
else
	puts "*Wins do not differ significantly in length from the average game*"
end


