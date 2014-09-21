if ARGV.length < 1
	puts "usage: ruby position_choice path/to/player_games.pgn"
	exit
end

require 'pathname'
require './position_analysis'
require 'bundler/setup'
require 'pgn'
require 'descriptive_statistics'
require 'yaml'
require 'tempfile'

STOCKFISH_PATH = Pathname(__FILE__).parent + "bin" + "stockfish"

baseline = YAML.load(open(Pathname(__FILE__).parent + "running_choice_average.yml").read)

def make_player_regex(filename)
	parts = filename.split(/\/|\./)
	last_name = parts[parts.length - 2].downcase
	return Regexp.new last_name, Regexp::IGNORECASE
end

def t_test(data, pop_mean)
	tmp = Tempfile.new("t_test_temp")
	tmp.write(data.join(","))
	tmp.close
	
	t_result = `python t_test.py #{tmp.path} --population-mean=#{pop_mean}`

	tmp.unlink

	stats = {}
	t_result.split("\n").each{|e| r = e.split(":"); stats[r[0]] = r[1].to_f}
	return stats
end

player_regex = make_player_regex(ARGV[0])
games = PGN.parse(open(ARGV[0]).read)
player_name = ""
pa = PositionAnalysis.new STOCKFISH_PATH.to_s

terms = ["Material", "Imbalance", "Pawns", "Knights", "Bishops", "Rooks", "Queens", "Mobility", "King safety", "Threats", "Passed pawns", "Space", "Total"]
result = {}
terms.each{|term| result[term] = {"eg" => [], "mg" => []}}

games[0..2].each_with_index do |game,i|
	puts "#{i+1}/#{games.length}"	

	if game.tags["Black"] =~ player_regex
		player = :black
		player_name = game.tags["Black"]
	else
		player = :white
		player_name = game.tags["White"]
	end
	
	
	game.positions.each_with_index do |pos, i|
	 	if (pos.player == player) && (i < game.positions.length - 2) # there's a next move to compare to
			r = pa.compare(game.positions[i].to_fen, game.positions[i+1].to_fen, :side => player)
			terms.each do |term|
				result[term]["mg"] << r[term][:mg]
				result[term]["eg"] << r[term][:eg]
			end
	 	end
	end
end

data = {}

result.each do |term,values|
	puts "#{term} mg values:"
	puts values["mg"].inspect
	puts "#{term} baseline mg mean"
	puts baseline[term]["mg"]

	mg_stats = t_test(values["mg"], baseline[term]["mg"])
	eg_stats = t_test(values["eg"], baseline[term]["eg"])

	data[term] = {}
	data[term]["mg"] = {"mean" => values["mg"].mean, "stats" => mg_stats}
	data[term]["eg"] = {"mean" => values["eg"].mean, "stats" => eg_stats}

	puts term
	puts "mid-game mean: #{values["mg"].mean}"
	puts "end-game mean: #{values["eg"].mean}"
	puts
end

File.open(Pathname(__FILE__).parent + "player_results" + "#{player_name}.yml", "w"){|f| f << YAML.dump(data)}