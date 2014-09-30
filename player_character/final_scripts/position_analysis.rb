class PositionAnalysis
	attr_accessor :raw

	def initialize path_to_stockfish
		@stockfish = path_to_stockfish
	end

	def compare(fen1, fen2, options={})
		side = options[:side]

		pos1 = analyze(fen1)
		pos2 = analyze(fen2)
		result = {}
		pos1.each do |term, term_results|
			result[term] = {}

			term_results.each do |k,v|
				if pos1[term][side][:mg] && pos2[term][side][:mg]
					result[term][:mg] = pos2[term][side][:mg] - pos1[term][side][:mg]
				else 
					result[term][:mg] = 0
				end
				if pos1[term][side][:eg] && pos2[term][side][:eg]
					result[term][:eg] = pos2[term][side][:eg] - pos1[term][side][:eg]
				else 
					result[term][:eg] = 0
				end
			end
		end
		return result
	end

	def analyze(fen_string)
		@raw = `./#{@stockfish} #{fen_string}`
		lines = @raw.split(/\n/)
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
		parts = line.split(/\s|\|/).reject{|i| i.empty?}
		# if the term is two-words put it back together
		if parts.length == 8
			parts[1] = parts[0] + " " + parts[1]
			parts.shift
		end
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