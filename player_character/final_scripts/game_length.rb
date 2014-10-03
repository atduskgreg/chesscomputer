if ARGV.length != 1
	puts "usage: ruby game_length <path/to/player.pgn>"
	exit
end

require 'rubygems'
require 'bundler/setup'
require 'descriptive_statistics'
require 'pgn'
require 'tempfile'
require './helpers'

$logger.progname = "game_length"

$logger.info "game_length BEGIN"


games = PGN.parse(open(ARGV[0]).read)
player_regex = make_player_regex(ARGV[0])

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

	if game.tags["Black"] =~ player_regex
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



# File.open("maurice_loss_lengths.csv", "w"){|f| f << result[:loss_lengths].join(",")}

# we only care want the non-draw games in our total population
pop = []
pop << result[:loss_lengths]
pop << result[:win_lengths]
pop = pop.flatten

$logger.info "Results for #{ARGV[0]} (w/l/d/total #{result[:win_lengths].length}/#{result[:loss_lengths].length}/#{result[:draw_lengths].length}/#{result[:all_lengths].length})"
$logger.info "Average length of win: #{result[:win_lengths].mean}"
$logger.info "Average length of loss: #{result[:loss_lengths].mean}"
$logger.info "Average length of draw: #{result[:draw_lengths].mean}"
$logger.info "Total average length: #{result[:all_lengths].mean}"
$logger.info "Average length w/o draws: #{pop.mean}"


loss_stats = t_test(result[:loss_lengths], pop.mean)
win_stats = t_test(result[:win_lengths], pop.mean)


$logger.info "===RESULT==="
$logger.info "=Losses="
$logger.info "t-stat: #{loss_stats["t"]}"
$logger.info "p-value: #{loss_stats["p"]}"


csv = {"loss stats significant" => false, "win stats significant" => false}

csv["average loss length"] = result[:loss_lengths].mean.round
csv["average loss diff"] = result[:loss_lengths].mean.round - result[:all_lengths].mean.round
csv["average game length"] = result[:all_lengths].mean.round

if loss_stats["p"] < 0.05
	$logger.info "*Losses differ significantly in length from the average game*"
	csv["loss stats significant"] = true
else
	$logger.info "*Losses do not differ significantly in length from the average game*"
end

	


$logger.info "=Wins="
$logger.info "t-stat: #{win_stats["t"]}"
$logger.info "p-value: #{win_stats["p"]}"

csv["average win length"] = result[:win_lengths].mean.round
csv["average win diff"] = result[:win_lengths].mean.round - result[:all_lengths].mean.round
csv["average game length"] = result[:all_lengths].mean.round

if win_stats["p"] < 0.05
	$logger.info "*Wins differ significantly in length from the average game*"
	csv["win stats significant"] = true
else
	$logger.info "*Wins do not differ significantly in length from the average game*"
end

puts to_csv_row(csv)

