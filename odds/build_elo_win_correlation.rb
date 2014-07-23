require 'csv'

diffs = {}

CSV.foreach(ARGV[0]) do |row|
	#BlackElo,WhiteElo,EloDiff,Outcome
	blackElo = row[0].to_i
	whiteElo = row[1].to_i
	eloDiff = row[2].to_i.abs
	outcome = row[3].to_i

	puts "blackElo: #{blackElo}\twhiteElo: #{whiteElo}\teloDiff: #{eloDiff}\toutcome: #{outcome}"

# us - PGN
# 1  - "1-0" (White won), 
# 0  - "0-1" (Black won), 
# 2  - "1/2-1/2" (Draw), or "*" (other, e.g., the game is ongoing).
	
	if outcome != 2

		if whiteElo > blackElo
			higherPlayerWins = (outcome == 1) ? 1 : 0
		elsif blackElo > whiteElo
			higherPlayerWins = (outcome == 0) ? 1 : 0
		else
			higherPlayerWins = 0
		end
	
		if diffs[eloDiff]
			diffs[eloDiff]["HigherPlayerWins"] = diffs[eloDiff]["HigherPlayerWins"] + higherPlayerWins
			diffs[eloDiff]["gameCount"] = diffs[eloDiff]["gameCount"] + 1
		else
			diffs[eloDiff] = {"HigherPlayerWins" => higherPlayerWins, "gameCount" => 1}
		end
	end
end

CSV.open("elo_diff_win_percentage.csv", "wb") do |csv|
	csv << ["EloDifference", "HigherPlayerWinPercentage", "HigherPlayerWins","HigherPlayerLosses"]
	diffs.each do |eloDiff, result|
		if result["gameCount"] > 50
			percentage = result["HigherPlayerWins"].to_f / result["gameCount"]
			losses = result["gameCount"] - result["HigherPlayerWins"]
			csv << [eloDiff, percentage, result["HigherPlayerWins"], losses]
		end
	end
end