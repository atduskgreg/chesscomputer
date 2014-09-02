require 'rubygems'
require 'bundler/setup'
require 'pgn'

PGN.parse(open(ARGV[0]).read)