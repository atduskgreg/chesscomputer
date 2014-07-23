require 'csv'

total = 0
counted = 0
CSV.open("elo_outcome.csv", "wb") do |csv|
	csv << ["BlackElo", "WhiteElo", "EloDiff", "Outcome"]

	File.open(ARGV[0]).each do |line|
		begin
			line = line.force_encoding("ISO-8859-1").encode("UTF-8").gsub(/\n/, '')
			row = line.split(/\t/)

	  		blackElo = row[2]
	  		result = row[8]
	  		whiteElo = row[12]

	  			
	  		if blackElo != "?" && whiteElo != "?"
	  			begin
	  			print "#{whiteElo.to_i} v #{blackElo.to_i}\t"


	  			# Result: the result of the game. 
	  			# "1-0" (White won), 
	  			# "0-1" (Black won), 
	  			# "1/2-1/2" (Draw), or "*" (other, e.g., the game is ongoing).
	  			# (via http://en.wikipedia.org/wiki/Portable_Game_Notation)

	  			coded_result = 2
	  			if result == "0-1"
	  				coded_result = 0
	  			elsif result == "1-0"
	  				coded_result = 1
	  			end

	  			csv << [blackElo, whiteElo, whiteElo.to_i-blackElo.to_i, coded_result]
	  			counted = counted + 1
	  			rescue NoMethodError => e
	  				puts "=======NoMethodError======="
	  				puts e.inspect
	  				puts line
	  				puts "=============="
	  			end
	  		end
		  	total = total + 1
	  		puts "#{counted}/#{total}"

	  	rescue CSV::MalformedCSVError
	  		puts "======CSV::MalformedCSVError========"
	  		puts line
	  		puts "=============="
	  	end
	end
end 