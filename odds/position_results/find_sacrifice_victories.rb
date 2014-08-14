require './models'

c = Game.count
Game.all.each_with_index do |game, i|
	puts "#{i+1}/#{c}"
	position = game.pgn.positions.last

	score = Game.score_for_pgn_position(position)

	margin_of_victory = score[:white] - score[:black]

	if margin_of_victory.abs > 3


		interesting = false

		if game.result == Game::WHITE_VICTORY && margin_of_victory < 0
			interesting = true
		end

		if game.result == Game::BLACK_VICTORY && margin_of_victory > 0
			interesting = true
		end

		if interesting
			puts "==>found! Game #{game.id}\tMargin: #{margin_of_victory}\tResult:#{game.result}"
			open("sacrifices.csv", "a") do |f|
				f << "#{game.id},#{margin_of_victory},#{game.result},#{position.to_fen}\n"
			end
		end
	end
end