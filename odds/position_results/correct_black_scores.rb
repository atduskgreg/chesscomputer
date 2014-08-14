require './models'

pos = Position.all :checked => true


pos.each_with_index do |p, i|
	puts "#{i+1}/#{pos}"

	if(p.turn == Position::BLACKS_TURN)
		p.score = p.score * -1
		p.save
	end
end