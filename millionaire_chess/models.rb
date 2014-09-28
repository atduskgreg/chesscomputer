require './stockfish'
require 'bundler/setup'
require 'pgn'

class Game
	attr_accessor :pgn, :analysis, :white, :black

	def initialize fen
		@pgn = PGN::Game.new([])
		@pgn.instance_variable_set("@positions", [PGN::FEN.new(fen).to_position])
		@analysis = Stockfish.analyze(fen)

		white = Player.new
		white.elo = 2750 + 2750 + rand(-150..150)

		black = Player.new
		black.elo = 2750 + 2750 + rand(-150..150)

	end

	def score
		{:white => (@analysis[:white_victory_odds]*100).round,
		 :black => ((1 - @analysis[:white_victory_odds])*100).round}
	end
end

class Player
	attr_accessor :elo
end