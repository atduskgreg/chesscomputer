require './stockfish'
require 'bundler/setup'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
# require 'dm-aggregates'
require 'pgn'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/millionaire_chess")


class Game
  	WHITE_VICTORY = "1-0"
  	BLACK_VICTORY = "0-1"
  	DRAW = "1/2-1/2"
  	UNKNOWN = "*"

	include DataMapper::Resource
  
  	property :id, Serial
  	property :pgn, Object
  	property :event, String
  	property :final_material, Object
  	property :is_sacrifice, Boolean
  	timestamps :at
  	
  	# TODO: store the actual PGN file somewhere in case something goes wrong
  	# or just have them email it to me
  	def self.load_batch options={}
  		pgn = PGN.parse(options[:pgn_string])
  		pgn.each do |game|
  			g = Game.create :pgn => game, :event => options[:event]
  			g.check_sacrifice!
  		end
  	end

  	def check_sacrifice!
  		position = pgn.positions.last
  		score = Game.score_for_pgn_position(position)
  		margin_of_victory = score[:white] - score[:black]
  		sacrifice = false

  		if margin_of_victory.abs > 3
			if pgn.result == Game::WHITE_VICTORY && margin_of_victory < 0
				sacrifice = true
			end
			if pgn.result == Game::BLACK_VICTORY && margin_of_victory > 0
				sacrifice = true
			end
		end

		self.is_sacrifice = sacrifice
		self.final_material = score
		self.save
  	end


	def description
  	  "#{pgn.tags["White"]} (White) v. #{pgn.tags["Black"]} (Black) at #{pgn.tags["Event"]}, #{pgn.tags["Site"]}, #{pgn.tags["Date"]}"
  	end

  	def self.score_for_pgn_position(position)
  	  result = {:black => 0, :white => 0, :black_missing => [], :white_missing => []}
	
  	  values = {"p" => 1, "b" => 3, "n" => 3, "r" => 5, "q" => 9}
	
  	  position.board.squares.flatten.each do |square|
  	    if square && values.keys.include?(square.downcase)
  	      piece_value = values[square.downcase]
	
  	      if square == square.downcase # black in FEN
  	        result[:black] = result[:black] + piece_value
  	        result[:black_missing] << square
  	      else # white
  	        result[:white] = result[:white] + piece_value
  	        result[:white_missing] << square
  	      end
  	    end
  	  end
	
  	  return result
  	end
end

DataMapper.finalize

class Player
	attr_accessor :elo
end