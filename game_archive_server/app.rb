require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/cross_origin'

require 'json'
require './models.rb'

configure do
  enable :cross_origin
end

# get the next game not marked as done
get "/next_game" do
	content_type :json
	(Game.first :done => false).to_json
end

# mark game as complete
post "/game/:id/done" do
	content_type :json
	g = Game.get params[:id]

	if g
		g.done = true
		g.save
		g.to_json
	else 
		status 404
	end
end

# create a boomerang for a particular game
post "/game/:id/boomerangs" do
	content_type :json
	g = Game.get params[:id]

	if g
		b = g.boomerangs.new
		b.moves = params[:moves]
		b.start = params[:start]
		b.scores = params[:scores]
		if b.save
			b.to_json
		else
			status 400
		end
	else 
		status 404
	end
end
