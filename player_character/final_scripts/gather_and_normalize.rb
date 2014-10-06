require 'csv'
require './helpers'


# Find biggest and smallest values for calibration
biggest = 0
smallest = 10

ARGV.each do |f|
	input = CSV.parse(open(f).read)
	pc_cols = []

	input[0].each_with_index do |col,i|
		if ["Mobility", "King safety" "Threats", "Passed pawns", "Space"].include?(col)
			pc_cols << i
		end
	end


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

smallest = -0.006
biggest = 0.006
puts
puts "seting bounds to #{smallest} to #{biggest}"

CSV.open("player_results_merged.csv", "a") do |output|
	ARGV.each_with_index do |f,i|
		input = CSV.parse(open(f).read)
		if i == 0
			output << input[0]
		end

		row = []
		input[1].each_with_index do |col,i|
			if ["Mobility", "King safety" "Threats", "Passed pawns", "Space"].include?(input[0][i])
				puts col.to_f
				row << normalize_player_stat(col.to_f, {:max => biggest, :min => smallest})
			else
				row << col
			end
		end
		output << row
	end
end


