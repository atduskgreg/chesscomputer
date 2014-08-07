require './models'

NUM_POSITIONS = 100
SEARCH_DEPTH = 16

STOCKFISH = "./../../Stockfish-eval/src/stockfish"


def html_board(position)
	result = "<table>"
	position.inspect.split(/\n/).each do |row| 
		result << "<tr>"
		row.split("").each do |square|
			result << "<td>#{square}</td>" 
		end
		result << "</tr>"
	end
	result << "</table>"
	result 
end

results = []

NUM_POSITIONS.times do
	# print "."	
	game = Game.random
	pos = game.pgn.positions.sample
	result = `#{STOCKFISH} position #{pos.to_fen} go depth #{SEARCH_DEPTH}`
	parts = result.split(/\n/).last.split(" ")
	bestmove = parts[1]
	score = parts[3]

	results << {:bestmove => bestmove, :score => score, :position => pos}
end


puts <<-HTMLPAGE
<html>
<head>
<meta http-equiv="Content-Type"
    content="text/html; charset=UTF-8" />
</head>
<body>
	<h1>Stockfish Position Analysis</h1>
	<p><em>Analyzing <b>#{NUM_POSITIONS}</b> positions with a search depth of <b>#{SEARCH_DEPTH} ply</b></em>.</p>
	<div>
	#{results.collect{|r| html_board(r[:position]) +  "<p>" + [r[:position].to_fen, "score: " + r[:score], "bestmove: " + r[:bestmove] + " (" + r[:position].player.to_s + ")"].join("</br>") + "</p>"}.join("\n")}
	</div>
</body>
</html>
HTMLPAGE

