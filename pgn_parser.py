# get pgn here: https://github.com/renatopp/pgnparser
# download and install locally with easy_install

import pgn
import sys

if(len(sys.argv) < 2 ):
	print("usage: python pgn_parser.py <path/to/file.pgn>")
	exit()

pgn_text = open(sys.argv[1]).read()
games = pgn.loads(pgn_text)

print("PGN parsed successfully")
print("{0} games found".format(len(games)))