class PositionAnalysis
	def initialize path_to_stockfish
		@stockfish = path_to_stockfish
	end

	def analyze(fen_string)
		stockfish_result = `./#{@stockfish} #{fen_string}`
		lines = stockfish_result.split(/\n/)
		result = {}
		lines[5..16].each do |line|
			term_eval = parse_line(line)
			result[term_eval[:term]] = term_eval[:eval]
		end

		total_eval = parse_line(lines[18])
		result[total_eval[:term]] = total_eval[:eval]
		return result
	end

	def parse_line(line)
		parts = line.split(/\s{2,}|\|/).reject{|i| i.empty?}
		puts parts.inspect
		{:term => parts[0].strip,
		 :eval => {
		 	:white => {:mg => clean(parts[1]),
		 			   :eg => clean(parts[2])},
		 	:black => {:mg => clean(parts[3]),
		 			   :eg => clean(parts[4])},
		 	:total => {:mg => clean(parts[5]),
		 		       :eg => clean(parts[6])}}}
	end

	def clean(r)
		if r =~ /---/
		 	return nil
		else 
			return r.to_f
		end
	end
end