require './models'

games = Game.all(:result.not => "*")
unloaded = games.select{|g| g.positions.length == 0}

puts "#{unloaded.length}/#{games.length} games with unloaded positions"

unloaded.each_with_index do |game, gix|
	puts "#{gix}/#{unloaded.length}"
	positions = game.pgn.positions
	positions.each_with_index do |position, pix|
		puts "\t#{pix}/#{positions.length}"
		Position.create :game_id => game.id,
						:fen => position.to_fen
	end
end