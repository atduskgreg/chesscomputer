require 'csv'
require './models'
require 'erb'



matches = []
CSV.foreach("identical_beginnings_demo.csv") do |row|
	ply = row[0] 
	g1 = row[1].to_i
	g2 = row[2].to_i
	moves=  row[3]

	matches << {:ply => ply, :game1 => Game.get(g1), :game2 => Game.get(g2), :moves => moves}
end

template = <<-TEMPLATE
<html>
<head>
<meta http-equiv="Content-Type"
    content="text/html; charset=UTF-8" />

	<style>
		.all-moves{
			font-size: 10px;
			color: #aaa;
		}

		body {
			max-width: 800px;
		}

		.pair {
			border-bottom: 1px solid #aaa;
		}

		.identical-moves {
			background-color: #000;
			color: #fff;
		}
		.description {
			text-align: center;
		}
	</style>
</head>
<body>
<h1>Games with Identical Beginnings</h1>
<% matches.each do |match| %>
	<div class="pair">
		<h2>Game <%= match[:game1].id %> and <%= match[:game2].id %>: <%= match[:ply] %> ply identical</p>
</h2>
		<p class="description"><%= match[:game1].description %><br />
		<em>and</em><br />
		<%= match[:game2].description %></p>
		<p class="identical-moves"><%= match[:moves] %></p>
		<p><b>Game <%= match[:game1].id %> (<%= match[:game1].pgn.moves.length %> ply)</b>: <span class='all-moves'><%=  match[:game1].pgn.moves.join(" ") %></span></p>
		<p><b>Game <%= match[:game2].id %> (<%= match[:game2].pgn.moves.length %> ply)</b>: <span class='all-moves'><%=  match[:game2].pgn.moves.join(" ") %></span></p>
	</div>
<% end %>
</body>

</html>
TEMPLATE

puts ERB.new(template).result
