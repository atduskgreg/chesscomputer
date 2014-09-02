require 'rubygems'
require 'bundler/setup'

PGN.parse(open(ARGV[0]).read)