require './models'
require 'csv'

games = Game.all :limit => 200


game_moves = games.collect{|g| {:gid => g.id, :moves => g.pgn.moves.join(" ")}}
game_moves = game_moves.reject{|m| m[:moves].empty?}
game_moves = game_moves.sort_by{|g| g[:moves]}

def longset_common_prefix(s1, s2)
	s1.each_char.with_index do |c, i|
    	return s1[0...i] if c != s2[i]
  	end
end

def num_ply_in_string(s)
	s.rstrip.lstrip.split(" ").length
end

results = []

game_moves.each_with_index do |game, i|

	if i < game_moves.length-1

		currGame = game
		nextGame = game_moves[i+1]

		result = {:game1 => currGame[:gid], :game2 => nextGame[:gid]}
		prefix = longset_common_prefix(currGame[:moves], nextGame[:moves])
		common_ply = num_ply_in_string(prefix)

		result[:moves] = prefix
		result[:ply] = common_ply

		results << result
	end

end

results = results.sort_by{|r| r[:ply]}.reverse

puts "#{results.first[:ply]} #{results.first[:moves]}"
puts "#{results.last[:ply]} #{results.last[:moves]}"

CSV.open("identical_beginnings_demo.csv", "wb") do |csv|
	csv << ["ply in common", "game1_id", "game2_id", "moves"]
	results.each do |r|
		csv << [r[:ply], r[:game1], r[:game2], r[:moves]]
	end
end


