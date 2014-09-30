if ARGV.length != 1
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
require './helpers'


$logger.progname = "position_choice"
$logger.info "position_choice BEGIN"

STOCKFISH_PATH = Pathname(__FILE__).parent.parent + "bin" + "stockfish"
baseline = YAML.load(open(Pathname(__FILE__).parent + "position_choice_average.yml").read)


player_regex = make_player_regex(ARGV[0])
games = PGN.parse(open(ARGV[0]).read)
$logger.info "#{games.length} games"

player_name = ""
pa = PositionAnalysis.new STOCKFISH_PATH.to_s

terms = ["Material", "Imbalance", "Pawns", "Knights", "Bishops", "Rooks", "Queens", "Mobility", "King safety", "Threats", "Passed pawns", "Space", "Total"]
result = {}
terms.each{|term| result[term] = {"eg" => [], "mg" => []}}

games.each_with_index do |game,i|
	$logger.info "#{i+1}/#{games.length}"
	if game.tags["Black"] =~ player_regex
		player = :black
		player_name = game.tags["Black"]
	else
		player = :white
		player_name = game.tags["White"]
	end
	
	game.positions.each_with_index do |pos, i|
	 	if (pos.player == player) && (i < game.positions.length - 2) # there's a next move to compare to
	 		begin
				r = pa.compare(game.positions[i].to_fen, game.positions[i+1].to_fen, :side => player)
				terms.each do |term|
					result[term]["mg"] << r[term][:mg]
					result[term]["eg"] << r[term][:eg]
				end
			rescue Exception => e
				$logger.warn "Exception: #{e.inspect}"
				$logger.warn "\tposition: #{i}"# game: #{game.inspect}"
			end
	 	end
	end
end

data = {}

result.each do |term,values|
	$logger.info "#{term} mg values:"
	$logger.info values["mg"].inspect
	$logger.info "#{term} baseline mg mean"
	$logger.info baseline[term]["mg"]

	mg_stats = t_test(values["mg"], baseline[term]["mg"])
	eg_stats = t_test(values["eg"], baseline[term]["eg"])

	data[term] = {}
	data[term]["mg"] = {"mean" => values["mg"].mean, "stats" => mg_stats}
	data[term]["eg"] = {"mean" => values["eg"].mean, "stats" => eg_stats}

	$logger.info term
	$logger.info "mid-game mean: #{values["mg"].mean}"
	$logger.info "end-game mean: #{values["eg"].mean}"
end

important_terms = ["Mobility", "King safety", "Threats", "Passed pawns", "Space"]


csv = {}
important_terms.each do |t| 
	csv[t] = data[t]["mg"]["mean"]
	csv[t + " signficant"] = data[t]["mg"]["stats"]["p"] < 0.05 ? "yes" : "no"
end


puts to_csv_row(csv)

