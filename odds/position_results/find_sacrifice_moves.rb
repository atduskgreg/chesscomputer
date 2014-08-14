def find_sacrifice_moves game
	npos = game.pgn.positions.length - 1 
	final_score = Game.score_for_pgn_position(game.pgn.positions.last)
	gap = (final_score[:white] - final_score[:black]).abs

	num_checked = 0

	moves = []

	move_num = game.pgn.moves.length - 1

	found = false

	while !found && num_checked < 20
		moves << game.pgn.moves[move_num]

		score = Game.score_for_pgn_position(game.pgn.positions[npos])
		gap = (score[:white] - score[:black]).abs

		if gap < 3 && num_checked > 6 # enforce a minimum number of moves
			found = true
		end

		move_num = move_num - 1
		npos = npos - 1
		num_checked = num_checked + 1
	end

	return moves.reverse
end