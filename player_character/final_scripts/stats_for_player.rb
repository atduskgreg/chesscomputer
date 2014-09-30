if ARGV.length != 1
	puts "usage: ruby stats_for_player <path/to/player.pgn>"
	exit
end

require 'csv'

def parse_script_result r
	lines = r.split("\n")
	[lines[lines.length - 2].split(","), lines.last.split(",")]
end

def player_name path
	parts = path.split(/\/|\./)
	parts[parts.length - 2]
end

header = []
data = []

["queen_trades.rb", "game_length.rb", "position_choice.rb"].each do |script|
	puts "running #{script}"
	script_header, script_data = parse_script_result(`ruby #{script} #{ARGV[0]}`)
	header << script_header
	data << script_data
end

CSV.open("player_results/" + player_name(ARGV[0]) +".csv", "wb") do |csv|
	csv << header.flatten
	csv << data.flatten
end