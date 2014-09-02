if ARGV.length < 1
	puts "usage: ruby queen_trades path/to/player_games.pgn"
	exit
end

require 'rubygems'
require 'bundler/setup'
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

def chisquare(observed, expected)
	tmp = Tempfile.new("chisquare_tmp")
	data = observed.join(",") + "\n" + expected.join(",")
	
	tmp.write(data)
	tmp.close
	
	t_result = `python chi_squared.py #{tmp.path}`

	tmp.unlink

	stats = {}
	t_result.split("\n").each{|e| r = e.split(":"); stats[r[0]] = r[1].to_f}
	return stats
end

def make_player_regex(filename)
	parts = filename.split(/\/|\./)
	last_name = parts[parts.length - 2].downcase
	return Regexp.new last_name, Regexp::IGNORECASE
end

player_regex = make_player_regex(ARGV[0])
games = PGN.parse(open(ARGV[0]).read)

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
def result_for_player(regex, game)

	if game.result == DRAW
		return PLAYER_DRAW
	end

	if game.tags["Black"] =~ regex
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

no_trades = []

games.each do |game| 
	losses = find_queen_losses(game)
	if check_trade(losses)
		trades << {:game => game, :losses => losses}
	else
		no_trades << {:game => game, :losses => losses}
	end
end

puts
puts "### Player #{ARGV[0].split("/").last}"
puts
puts "* Traded queens in #{trades.length}/#{games.length} games (#{percent(trades.length.to_f/games.length)})"

wins = []
losses = []
draws = []

trades.each do |trade|

	case result_for_player(player_regex, trade[:game])
	when PLAYER_WIN
		wins << trade
	when PLAYER_LOSS
		losses << trade
	when PLAYER_DRAW
		draws << trade

	end
end

n_wins = []
n_losses = []
n_draws = []

no_trades.each do |game|
	case result_for_player(player_regex, game[:game])
	when PLAYER_WIN
		n_wins << game
	when PLAYER_LOSS
		n_losses << game
	when PLAYER_DRAW
		n_draws << game
	end
end

puts
puts "#### Record after trade analysis"
puts

trade_percent = percent(wins.length.to_f/(wins.length + losses.length))
non_trade_percent = percent(n_wins.length.to_f/(n_wins.length + n_losses.length))

puts "* **Trade record**  #{wins.length}/#{wins.length + losses.length} (#{trade_percent}) (#{draws.length} draws)"
puts "* **Non-trade record** #{n_wins.length}/#{n_wins.length + n_losses.length} (#{non_trade_percent}) (#{n_draws.length} draws)"
puts "* **#{trade_percent > non_trade_percent ? "Higher" : "Lower"}** win percentage after queen trade."

# We're asking if the outcomes of queen trade games are signficantly different
# than non-queen trade games:
observed = [wins.length, losses.length]
expected = [n_wins.length, n_losses.length]

chi_result = chisquare(observed,expected)
puts "* chi-squared: #{chi_result["chi"]}"
puts "* p-score: #{chi_result["p"]}"

if chi_result["p"] <= 0.05
	puts "* **RESULT IS SIGNIFICANT**"
end

win_trade_mean = wins.collect{|win| trade_start(win[:losses])}.mean.round(2)
win_length_mean = wins.collect{|win| win[:game].positions.length}.mean.round(2)

loss_trade_mean = losses.collect{|loss| trade_start(loss[:losses])}.mean.round(2)
loss_length_mean = losses.collect{|loss| loss[:game].positions.length}.mean.round(2)

draw_trade_mean = draws.collect{|draw| trade_start(draw[:losses])}.mean.round(2)
draw_length_mean = draws.collect{|draw| draw[:game].positions.length}.mean.round(2)

puts
puts "#### Length-analysis"
puts
puts "* Won-games: Trade happened at #{win_trade_mean}/#{win_length_mean} ply on average (#{percent(win_trade_mean/win_length_mean)})."
puts "* Lost-games: Trade happened at #{loss_trade_mean}/#{loss_length_mean} ply on average (#{percent(loss_trade_mean/loss_length_mean)})."
puts "* Drawn-games: Trade happened at #{draw_trade_mean}/#{draw_length_mean} ply on average (#{percent(draw_trade_mean/draw_length_mean)})."


wins = wins.collect{|win| trade_start(win[:losses])/win[:game].positions.length.to_f}
losses = losses.collect{|loss| trade_start(loss[:losses])/loss[:game].positions.length.to_f}

# draws = draws.collect{|draw| trade_start(draw[:losses])/draw[:game].positions.length.to_f}

population = wins + losses

r =  t_test(wins, population.mean)
puts "* Wins: t-score: #{r["t"]} p-value: #{r["p"]}"

if r["p"] <= 0.05
	puts "* **WIN RESULT IS SIGNICANT**"
end

r =  t_test(losses, population.mean)
puts "* Losses: t-score: #{r["t"]} p-value: #{r["p"]}"
if r["p"] <= 0.05
	puts "* **LOSS RESULT IS SIGNICANT**"
end

# puts "Draws:"
# r = t_test(draws, (wins+losses+draws).mean)
# puts "t-score: #{r["t"]}\np-value: #{r["p"]}"


