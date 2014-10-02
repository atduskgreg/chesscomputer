require 'csv'
require './helpers'


# Find biggest and smallest values for calibration
biggest = 0
smallest = 10

ARGV.each do |f|
	input = CSV.parse(open(f).read)
	pc_cols = [9,11,13,15,17]
	pc_cols.each do |i|
		val = input[1][i].to_f
		if val > biggest
			biggest = val
		end

		if val < smallest
			smallest = val
		end
	end
end

puts "biggest: #{biggest}"
puts "smallest: #{smallest}"

CSV.open("player_results.csv", "a") do |output|
	ARGV.each do |f|
		input = CSV.parse(open(f).read)
		pc_cols = [9,11,13,15,17]
		input[1].each_with_index do |col,i|
			row = []
			if pc_cols.include? i
				puts col.to_f
				row << normalize_player_stat(col.to_f, {:max => biggest, :min => smallest})
			else
				row << col
			end
		end
		output << row
	end
end


