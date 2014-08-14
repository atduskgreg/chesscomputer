require 'csv'
require './models'
require './find_sacrifice_moves'
require 'erb'

games = []


CSV.foreach("sacrifices.csv") do |row|
	#				f << "#{game.id},#{margin_of_victory},#{game.result},#{position.to_fen}\n"
	game_id = row[0]
	margin = row[1].to_i
	result = row[2]
	fen = row[3]

	g = Game.get game_id.to_i
	moves = find_sacrifice_moves(g)

	games << {:game_id => game_id, :position => g.pgn.positions.last, :result => result, :fen => fen, :margin => margin, :moves => moves}
end

games = games.sort_by{|g| g[:margin].abs}.reverse

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

template = <<-TEMPLATE
<html>
<head>
<meta http-equiv="Content-Type"
    content="text/html; charset=UTF-8" />
	<link rel="stylesheet" href="style.css" type="text/css" media="screen">
	<script src="script.js"></script>
</head>
<body>
<h1>Detected Sacrifices</h1>
<% games.each do |game| %>
	<div class="game">
	<h2>Game <%= game[:game_id] %></h2>
	<%= html_board(game[:position]) %>
	<p>Result: <%= game[:result] %><br />
	Margin: <%= game[:margin] %><br />
	<%= game[:fen] %>
	</p>
	<p>Move log (<em>final <%= game[:moves].length %> ply</em>):</p>
	<ul>
		<% game[:moves].each_with_index do |move,i| %>
			<% if i.even? %>
				<% if game[:moves][i+1] %>
					<li><%= move %> <%= game[:moves][i+1] %></li>
				<% else %>
					<li><%= move %></li>
				<% end %>
			<% end %>
		<% end %>
	</ul>

	</div>
<% end %>
</body>

</html>
TEMPLATE

puts ERB.new(template).result
