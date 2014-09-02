if ARGV.length < 2
	puts "usage: ruby queen_trades <\"Player Name\"> path/to/games.pgn"
	exit
end

require 'pgn'
require 'descriptive_statistics'
require 'tempfile'

def t_test(data, pop_mean)
	tmp = Tempfile.new("t_test_temp")
	tmp.write(data.join(","))
	tmp.close
	
	t_result = `python t_test.py #{tmp.path} --population-mean=#{pop_mean}`

	tmp.unlink

	stats = {}
	t_result.split("\n").each{|e| r = e.split(":"); stats[r[0]] = r[1].to_f}
	return stats
end

player = ARGV[0]
games = PGN.parse(open(ARGV[1]).read)

TRADE_MIN_PLY = 4

def piece_is_present?(position, piece)
	pos_fen = position.to_fen.to_s.split(" ")[0]
	pos_fen =~ Regexp.new(piece)
end

def has_white_queen?(position)
	piece_is_present?(position, "q")
end

def has_black_queen?(position)
	piece_is_present?(position, "Q")
end

def find_queen_losses(game)
	result = {:black => false, :white => false}
	game.positions.each_with_index do |position,i|

		if !result[:black] && !has_black_queen?(position)
			result[:black] = i
		end

		if !result[:white] && !has_white_queen?(position)
			result[:white] = i
		end
	end
	return result
end

# this expects a hash like that which results from find_queen_losses()
def gap(g)
	return (g[:black]-g[:white]).abs
end

# this expects a hash like that which results from find_queen_losses()
def check_trade(g)
	return g[:black] && g[:white] && (gap(g) <= TRADE_MIN_PLY)
end

# this expects a hash like that which results from find_queen_losses()
def trade_start(g)
	return g.values.min
end

def percent(f)
	"#{f.round(2) * 100}%"
end

def is_trade?(game)
	losses = find_queen_losses(game)
	return check_trade(losses)
end



WHITE_VICTORY = "1-0"
BLACK_VICTORY = "0-1"
DRAW = "1/2-1/2"

PLAYER_WIN = 1
PLAYER_LOSS = -1
PLAYER_DRAW = 0
def result_for_player(player, game)

	if game.result == DRAW
		return PLAYER_DRAW
	end

	if game.tags["Black"] == player
		if game.result == BLACK_VICTORY
			return PLAYER_WIN
		elsif game.result == WHITE_VICTORY
			return PLAYER_LOSS
		end
	else # playing as white
		if game.result == WHITE_VICTORY
			PLAYER_WIN
		elsif game.result == BLACK_VICTORY
			PLAYER_LOSS
		end
	end
end





trades = []
games.each do |game| 
	losses = find_queen_losses(game)
	if check_trade(losses)
		trades << {:game => game, :losses => losses}
	end
end

puts "Traded queens in #{trades.length}/#{games.length} games (#{percent(trades.length.to_f/games.length)})"

wins = []
losses = []
draws = []

trades.each do |trade|

	case result_for_player(player, trade[:game])
	when PLAYER_WIN
		wins << trade
	when PLAYER_LOSS
		losses << trade
	when PLAYER_DRAW
		draws << trade

	end
end

puts "Won #{wins.length}/#{wins.length + losses.length} (#{percent(wins.length.to_f/(wins.length + losses.length))}) of trades that didn't end in a draw (#{draws.length} draws)"

win_trade_mean = wins.collect{|win| trade_start(win[:losses])}.mean.round(2)
win_length_mean = wins.collect{|win| win[:game].positions.length}.mean.round(2)

loss_trade_mean = losses.collect{|loss| trade_start(loss[:losses])}.mean.round(2)
loss_length_mean = losses.collect{|loss| loss[:game].positions.length}.mean.round(2)

draw_trade_mean = draws.collect{|draw| trade_start(draw[:losses])}.mean.round(2)
draw_length_mean = draws.collect{|draw| draw[:game].positions.length}.mean.round(2)

puts "Won-games: Trade happened at #{win_trade_mean}/#{win_length_mean} ply on average (#{percent(win_trade_mean/win_length_mean)})."
puts "Lost-games: Trade happened at #{loss_trade_mean}/#{loss_length_mean} ply on average (#{percent(loss_trade_mean/loss_length_mean)})."
puts "Drawn-games: Trade happened at #{draw_trade_mean}/#{draw_length_mean} ply on average (#{percent(draw_trade_mean/draw_length_mean)})."

# TODO:
# What does the t-score mean here?
# Normalize this by game length?

wins = wins.collect{|win| trade_start(win[:losses])}
losses = losses.collect{|loss| trade_start(loss[:losses])}

population = wins + losses

puts "Wins:"
puts t_test(wins, population.mean).inspect

puts "Losses:"
puts t_test(losses, population.mean).inspect