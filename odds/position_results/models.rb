require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
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
  timestamps :at

  has n, :positions


  def pgn
    @pgn ||= PGN.parse(pgn_string)[0]
  end
end

class Position
  include DataMapper::Resource
  
  property :id, Serial
  property :checked, Boolean, :default => false
  property :fen, Text
  property :score, Integer
  timestamps :at

  belongs_to :game

end

DataMapper.finalize