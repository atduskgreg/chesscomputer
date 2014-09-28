require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'pgn'
require './models'

helpers do
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

end

get "/" do
	# fake games for testing
	fens = ["r4rk1/2qnbp1p/p1b1p1p1/1p1p2P1/3P4/P2BP2Q/1BPN1P1P/R3K2R w KQ - 0 15", "r4rk1/2q1bp1p/4p1P1/pn1p2P1/1p1P1PQ1/P2PPK2/3N4/R1B4R b - - 0 23", "rnbq1rk1/pp2ppbp/5np1/3p4/2PP4/2NB1N1P/PP3PP1/R1BQK2R w KQ - 0 8", "3r1bk1/p2q1p1p/4p1p1/Q2n4/3P4/1R5P/P3NPP1/2B3K1 b - - 4 23", "8/8/P1k5/5K1p/5pP1/8/6P1/8 b - - 0 56", "r2qrbk1/1bp2p1p/1p1p1np1/pP2n3/2PN4/2N1P3/PBQ1BPPP/2R1R1K1 b - - 2 15", "r1bqk2r/pp1nb1pp/2pp1n2/4pp2/2P5/1QNP2PN/PP2PPBP/R1B1K2R w KQkq - 2 7", "rnbq1r1k/ppp3pp/3p1n2/4pp2/1PP5/2QPP1P1/P4PBP/R1B1K1NR b KQ - 0 8", "8/8/1Bp1k3/7p/1p1PK3/1P3pPP/3b1P2/8 w - - 2 50", "2R3k1/3r1p1p/p3pp2/Pb6/5N1P/8/5PP1/6K1 b - - 2 31", "8/5Nk1/p5Pp/Pb2p2P/5p2/5P2/3K4/8 w - - 0 48", "r2q1rk1/ppp1bppp/2n1bn2/3pp3/8/2PP1NP1/PP1NPPBP/R1BQ1RK1 w - - 7 7", "r2q1rk1/1ppbbppp/2n2n2/p3p1N1/2Pp4/P2P2P1/1P1NPPBP/R1BQ1RK1 w - - 2 10", "r2bq1r1/2p1k1p1/1pn1Np1p/p3pP2/2Pp2P1/P2P2R1/1P1BP1QP/R5K1 b - - 5 23", "r5r1/2pq1kp1/1pn1N3/p3pPp1/2Pp4/P2P2R1/1P2P1Q1/R5K1 w - - 0 28", "r5r1/2pq1k2/1pn1N1R1/p3pP2/2Pp4/P2P4/1P2P1Q1/R5K1 b - - 0 29", "rnbqkbnr/pppppppp/8/8/8/6P1/PPPPPP1P/RNBQKBNR b KQkq - 0 0", "rn1qk2r/pbp1bppp/1p2pn2/3p4/8/1P1P1NP1/P1PNPPBP/R1BQ1RK1 b kq - 0 6", "1q2rrk1/pb1nbppp/1pn1p3/2p1P3/2Pp4/1P1P1NP1/P3QPBP/R1B1RNK1 w - - 4 15", "3q1rk1/1p3pbn/bB1n2p1/p2N2P1/P1P1N1Q1/1P6/6B1/4R1K1 b - - 4 30", "rnbqkb1r/4pp1p/p1p2np1/1p1P4/8/1Q3NP1/PP1PPPBP/RNB1K2R b KQkq - 1 6"]

	@games = fens.collect{|fen| Game.new(fen)}
	erb :index
end

get "/player/:player_id" do
	erb :player
end

post "/pgn_email" do
	pgn = PGN.parse(params["attachments"]["0"][:tempfile].read)
	puts pgn.inspect
end