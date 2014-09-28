class Stockfish
	SEARCH_DEPTH = 16
	STOCKFISH_PATH = (ENV['RACK_ENV'] == "production") ? "./bin/stockfish-heroku"  : "./bin/stockfish"
	FIT_PARAMS = [ 1.85973432,  0.00698631] # from plot_cp_diff_percentages.py
	
	BLACKS_TURN = "b"
	WHITES_TURN = "w"

	def self.analyze(fen)
		result = `#{STOCKFISH_PATH} position #{fen} go depth #{SEARCH_DEPTH}`
		parts = result.split(/\n/).last.split(" ")
		bestmove = parts[1]
		score = parts[3].to_i
	
		# transform to white's perspective if necessary
		if turn(fen) == BLACKS_TURN
			score = score * -1
		end
	
		white_victory_odds = predict(score)

		{:white_victory_odds => white_victory_odds, :best_move => bestmove, :best_move_cp_score => score}
	end

	
	def self.sigmoid(x, x0, k)
		1.0 / (1 + Math.exp(-k*(x-x0)))
	end
	
	def self.predict(score)
		sigmoid(score, Stockfish::FIT_PARAMS[0], Stockfish::FIT_PARAMS[1])
	end
	
	def self.turn(fen)
	  fen.split(" ")[1]
	end
end