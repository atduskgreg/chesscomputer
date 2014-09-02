require 'pgn'

class PGNLoader

	def self.parse(string, verbose=false)
		# Individual games can be badly formed so we need
		# to manually split the file into many games so
		# we can rescue individual crashes in PGN's parser
		game_segments = self.to_utf8(string).split(/\n\n\n/)
		unparseable = 0
		
		games = []

		game_segments.each_with_index do |segment, i|
			begin
				game = PGN.parse(segment)
				raise "Found file segment lacking game:\n#{segment}" unless games.length == 1
		
				games << game
			
			rescue Whittle::Error
				unparseable = unparseable + 1
				if verbose
					puts "========Whittle::UnconsumedInputError======="
					puts "#{i} ||| #{segment}"
					puts "============================================"
				end
			end
		end
		if verbose
			puts "#{unparseable}/#{game_segments.length} were unparseable."
		end

		games
	end

	# helper to force the string into clean UTF-8 so we can run regex on it
	def self.to_utf8(str)
	  str = str.force_encoding("UTF-8")
	  return str if str.valid_encoding?
	  str = str.force_encoding("BINARY")
	  str.encode("UTF-8", invalid: :replace, undef: :replace)
	end
end