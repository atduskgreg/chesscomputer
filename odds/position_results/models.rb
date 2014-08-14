require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-aggregates'
require 'json'
require 'pgn'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/position_results")

class Game
  WHITE_VICTORY = "1-0"
  BLACK_VICTORY = "0-1"
  DRAW = "1/2-1/2"
  UNKNOWN = "*"

  include DataMapper::Resource
  
  property :id, Serial
  property :result, String
  property :pgn_string, Text
  property :source, String
  property :positions_loaded, Boolean, :default => false
  timestamps :at

  has n, :positions

  def pgn
    @pgn ||= PGN.parse(pgn_string)[0]
  end

  def self.score_for_pgn_position(position)
    result = {:black => 0, :white => 0}

    values = {"p" => 1, "b" => 3, "n" => 3, "r" => 5, "q" => 9}

    position.board.squares.flatten.each do |square|
      if square && values.keys.include?(square.downcase)
        piece_value = values[square.downcase]

        if square == square.downcase # black in FEN
          result[:black] = result[:black] + piece_value
        else # white
          result[:white] = result[:white] + piece_value
        end
      end
    end

    return result
  end

  def self.random
    get(1+rand(count))
  end

  def load_positions!
    positions = pgn.positions
    positions.each_with_index do |position, pix|
      puts "\t#{pix+1}/#{positions.length}"
      Position.create :game_id => self.id, :fen => position.to_fen
    end
  end
end

class Position
  include DataMapper::Resource

  WHITES_TURN = "w"
  BLACKS_TURN = "b"
  
  property :id, Serial
  property :checked, Boolean, :default => false
  property :fen, Text
  property :score, Integer
  property :bestmove, String
  timestamps :at

  belongs_to :game

  def self.random
    get(1+rand(count))
  end

  def self.next
    first(:offset => rand(Position.count), :checked => false)
  end

  def turn
    fen.split(" ")[1]
  end
end

DataMapper.finalize