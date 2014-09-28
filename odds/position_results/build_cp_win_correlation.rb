require './models'
require 'csv'

scores = {}

positions = Position.all :checked => true
puts "Analyziing #{positions.length} positions"

positions.each do |pos|
	

	if pos.game.result != Game::DRAW && pos.score && pos.score.abs < 1000

		if(pos.turn == Position::BLACKS_TURN)
			pos.score = pos.score * -1
		end

		puts "#{pos.id} #{pos.turn} #{pos.game.result} #{pos.score}"

		if pos.game.result == Game::WHITE_VICTORY
			whiteWins = 1
		else
			whiteWins = 0
		end

		if scores[pos.score]
			scores[pos.score][:white_wins] = scores[pos.score][:white_wins] + whiteWins
			scores[pos.score][:game_count] = scores[pos.score][:game_count] + 1
		else
			scores[pos.score] = {:white_wins => whiteWins, :game_count => 1}
		end
	
	end
end

puts "Found #{scores.length} different scores"

CSV.open("cp_diff_win_percentage.csv", "wb") do |csv|
	csv << ["CPScore (white perspective)", "WhiteWinPercent"]
	scores.each do |score, result|
		# if result[:game_count] > 50
			percentage = result[:white_wins].to_f/result[:game_count] #result["higherPlayerWins"].to_f / result["gameCount"]
			#losses = result["gameCount"] - result["higherPlayerWins"]
			csv << [score, percentage]#, result["higherPlayerWins"], losses]
		# end
	end
end