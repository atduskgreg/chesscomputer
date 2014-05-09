require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/chess_archive_server")

class Game
  include DataMapper::Resource
  
  property :id, Serial
  property :done, Boolean, :default => false
  timestamps :at

  has n, :boomerangs

  def to_json
  	json_hash.to_json
  end

  def json_hash
  	{"done" => done, "game_id" => id, "created_at" => created_at, "updated_at" => updated_at}
  end

end

class Boomerang
  include DataMapper::Resource
  
  property :id, Serial
  property :moves, Object
  property :start, Text
  property :scores, Object
  timestamps :at

  belongs_to :game

  def to_json
  	{"boomerang_id" => id, "game" => game.json_hash, "moves" => moves, 
  	 "start" => start, "scores" => scores, "created_at" => created_at, "update_at" => updated_at}.to_json
  end
end

DataMapper.finalize