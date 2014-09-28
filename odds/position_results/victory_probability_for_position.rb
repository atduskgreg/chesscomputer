SEARCH_DEPTH = 16
STOCKFISH = "./../../Stockfish-eval/src/stockfish"
FIT_PARAMS = [ 1.85973432,  0.00698631] # from plot_cp_diff_percentages.py

if ARGV.length < 1
	puts "usage ruby victory_probability_for_position.rb <fen-string>"
	puts "\tRequires a fen string for a position to evaluate."
	exit
end

fen = ARGV[0]

def sigmoid(x, x0, k)
	1.0 / (1 + Math.exp(-k*(x-x0)))
end

def predict(score)
	sigmoid(score, FIT_PARAMS[0], FIT_PARAMS[1])
end

def turn(fen)
  fen.split(" ")[1]
end

result = `#{STOCKFISH} position #{fen} go depth #{SEARCH_DEPTH}`
parts = result.split(/\n/).last.split(" ")
bestmove = parts[1]
score = parts[3].to_i

# transform to white's perspective if necessary
if turn(fen) == "b"
	score = score * -1
end

puts predict(score)