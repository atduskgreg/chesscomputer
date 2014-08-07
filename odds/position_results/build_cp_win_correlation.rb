require './models'
require 'csv'

scores = {}

positions = Position.all :checked => true
puts "Analyziing #{positions.length} positions"

positions.each do |pos|
	if pos.game.result != Game::DRAW

		if pos.score > 0
			higherPlayerWins = (pos.game.result == Game::WHITE_VICTORY) ? 1: 0
		elsif pos.score < 0
			higherPlayerWins = (pos.game.result == Game::BLACK_VICTORY) ? 1: 0
		else # pos.score == 0
			higherPlayerWins = 0
		end

		if scores[pos.score]
			scores[pos.score]["higherPlayerWins"] = scores[pos.score]["higherPlayerWins"] + higherPlayerWins
			scores[pos.score]["gameCount"] = scores[pos.score]["gameCount"] + 1
		else
			scores[pos.score] = {"higherPlayerWins" => higherPlayerWins, "gameCount" => 1}
		end
	
	end
end

puts "Found #{scores.length} different scores"

CSV.open("cp_diff_win_percentage.csv", "wb") do |csv|
	csv << ["CPScore", "HigherPlayerWinPercentage", "HigherPlayerWins","HigherPlayerLosses"]
	scores.each do |score, result|
		# if result["gameCount"] > 50
			percentage = result["higherPlayerWins"].to_f / result["gameCount"]
			losses = result["gameCount"] - result["higherPlayerWins"]
			csv << [score, percentage, result["higherPlayerWins"], losses]
		# end
	end
end