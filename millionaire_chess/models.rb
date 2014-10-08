require './stockfish'
require 'bundler/setup'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
# require 'dm-aggregates'
require 'pgn'
require 'csv'
require 'ferret'


DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/millionaire_chess")
DataMapper::Model.raise_on_save_failure = true

class PositionResult
  include DataMapper::Resource
  
  property :id, Serial
  property :fen, Text
  property :cp_score, Integer
  property :bestmove, String

  def self.result_for(pgn_string)
    games = PGN.parse(pgn_string)
    fen = games[0].positions.last.to_fen.to_s

    pr = PositionResult.first :fen => fen

    if !pr
      result = Stockfish.analyze(fen)
      pr = PositionResult.create :fen => result[:fen], :cp_score => result[:score], :bestmove => result[:bestmove]
    end

    return pr
  end

  def analysis
    return Stockfish.result_for({:score => cp_score, :bestmove => bestmove, :fen => fen})

  end

end

class Player
  include DataMapper::Resource
  
  property :id, Serial
  property :elo, Integer
  property :player_name, String

  property :queen_trade_frequency, Integer
  property :queen_trades_significant, Boolean
  property :queen_trade_win_rate, Integer
  property :non_queen_trade_win_rate, Integer
  property :loss_stats_significant, Boolean
  property :win_stats_significant, Boolean
  property :average_loss_length, Integer
  property :average_loss_diff, Integer
  property :average_win_length, Integer
  property :average_win_diff, Integer
  property :average_game_length, Integer

  property :mobility, Float
  property :mobility_signficant, Boolean
  property :king_safety, Float
  property :king_safety_signficant, Boolean
  property :threats, Float
  property :threats_signficant, Boolean
  property :passed_pawns, Float
  property :passed_pawns_signficant,Boolean
  property :space, Float
  property :space_signficant, Boolean

  def self.search player_name
    index = Ferret::Index::Index.new(:default_field => 'content', :path =>"players-index")
    result = index.search(player_name)
    if result.hits.length > 0
      return Player.get index[result.hits[0].doc]['file']
    else
      return nil
    end
  end

  def self.build_index!
    index = Ferret::Index::Index.new(:default_field => 'content', :path =>"players-index")
    Player.all.each do |p|
      puts "#{p.id} #{p.player_name}"
      index.add_document :file => p.id, :content => p.player_name
    end
  end

  def self.load_batch_from_csv path_to_csv
    csv = CSV.parse(open(path_to_csv).read)
    (1..csv.length-1).each do |row|
      p = Player.new
      p.load_from_csv(csv, row)
      puts p.save
    end
  end

  def load_from_csv csv, row=1
    stats = csv[row].collect do |c|
        c.gsub!(/\.\d+%/, "")
        if c == "yes"
          c = true
        end
        if c == "no"
          c = false
        end
        if c == "typical"
          c = 0.0
        end
        c
     end

    stats.each_with_index do |col, i|
      if(["Mobility", "King safety", "Threats", "Passed pawns", "Space"].include?(csv[0][i]))
        col = col.to_f
      end
      self.send("#{csv[0][i].gsub(" ", "_").downcase}=".to_sym, col)
    end
  end

  def compare_to player2
    result = {}
    [:mobility, :king_safety, :space, :threats, :passed_pawns].each do |a|
      result[a] = self.send(a) - player2.send(a)
    end
    result
  end

end

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
  	
    def self.all_events
      Game.all(:fields => [:event], :unique => true, :order => [:event]).collect(&:event)
    end

  	# TODO: store the actual PGN file somewhere in case something goes wrong
  	# or just have them email it to me
  	def self.load_batch options={}
  		pgn = PGN.parse(options[:pgn_string])
  		pgn.each do |game|
  			g = Game.create :pgn => game, :event => options[:event]
  			g.check_sacrifice!
  		end
  	end

  	def result
  		pgn.result
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
  
		  score[:margin_of_victory] = margin_of_victory
		  self.is_sacrifice = sacrifice
		  self.final_material = score
		  self.save
  	end

  	def sacrificed_pieces
  		missing = {"P" => 8, "N" => 2, "R" => 2, "B" => 2, "K" => 1, "Q" => 1,
  				   "p" => 8, "n" => 2, "r" => 2, "b" => 2, "k" => 1, "q" => 1}

  		
  		pgn.positions.last.board.squares.flatten.compact.each do |piece|
  			missing[piece] = missing[piece] - 1
  		end

  		sacrificed_pieces = []
  		if result == Game::WHITE_VICTORY
  			["P", "N", "R", "B", "Q"].each do |p|
  				diff = missing[p] - missing[p.downcase]
  				if diff > 0
  					diff.times{ sacrificed_pieces << p}
  				end
  			end
  		else
  			["p", "n", "r", "b", "q"].each do |p|
  				diff = missing[p] - missing[p.upcase]
  				if diff > 0
  					diff.times{ sacrificed_pieces << p}
  				end
  			end
  		end
  		sacrificed_pieces
  	end

  def find_sacrifice_moves
	 	 npos = pgn.positions.length - 1 
	 	 final_score = Game.score_for_pgn_position(pgn.positions.last)
	 	 gap = (final_score[:white] - final_score[:black]).abs
	   
	 	 num_checked = 0
	   
	 	 moves = []
	   
	 	 move_num = pgn.moves.length - 1
	   
	 	 found = false
	   
	 	 while !found && num_checked < 20
	 	 	moves << pgn.moves[move_num]
	   
	 	 	score = Game.score_for_pgn_position(pgn.positions[npos])
	 	 	gap = (score[:white] - score[:black]).abs
	   
	 	 	if gap < 3 && num_checked > 6 # enforce a minimum number of moves
	 	 		found = true
	 	 	end
	   
	 	 	move_num = move_num - 1
	 	 	npos = npos - 1
	 	 	num_checked = num_checked + 1
	 	 end
	   
	 	 return moves.reverse
	end

	def html_description(options={})
		result = "<span class='playerName'>#{pgn.tags["White"]}</span> (White) v. <span class='playerName'>#{pgn.tags["Black"]}</span> (Black)"
		if options[:event]
			result << "at <span class='gameEvent'>#{pgn.tags["Event"]}</span>"
		end
		if options[:site]
			result << " at <span class='gameSite'>#{pgn.tags["Site"]}</span>"
		end
		if options[:date]
			result << " on <span class='gameDate'>#{pgn.tags["Date"]}</span>"
		end

		result
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

        else # white
          result[:white] = result[:white] + piece_value
        end
      end
    end
	
    return result
  end
end

DataMapper.finalize

