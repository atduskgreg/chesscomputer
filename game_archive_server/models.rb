require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/chess_archive_server")

class Game
  include DataMapper::Resource
  
  property :id, Serial
  property :done, Boolean, :default => false
  property :metadata, Object
  timestamps :at

  has n, :positions

  def to_json
  	json_hash.to_json
  end

  def json_hash
  	{"done" => done, "game_id" => id, "created_at" => created_at, "updated_at" => updated_at}
  end
end

class Position
  include DataMapper::Resource
  
  property :id, Serial
  property :checked, Boolean, :default => false
  property :position_number, Integer
  property :is_boomerang, Boolean
  property :fen, Text
  property :moves, Object
  property :scores, Object
  property :depth, Integer
  property :etc, Object
  timestamps :at

  belongs_to :game

  def to_json
  	{"position_id" => id, "is_boomerang" => is_boomerang, "game" => game.json_hash, "moves" => moves, 
  	 "fen" => fen, "scores" => scores, "depth" => depth, "created_at" => created_at, "update_at" => updated_at}.to_json
  end
end

DataMapper.finalize