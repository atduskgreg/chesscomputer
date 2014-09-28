require './stockfish'
require 'bundler/setup'
require 'pgn'

class Game
	attr_accessor :pgn
	attr_accessor :analysis

	def initialize fen
		@pgn = PGN::Game.new([])
		@pgn.instance_variable_set("@positions", [PGN::FEN.new(fen).to_position])
		

		@analysis = Stockfish.analyze(fen)
	end

	def score
		
	end
end