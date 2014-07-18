require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/cross_origin'

require 'json'
require './models.rb'

configure do
  enable :cross_origin
  set :protection, :except => [:json_csrf]
end

get "/" do
	@checked = Position.all :checked => true
	@boomerangs = @checked.select{|p| p.is_boomerang && p.cp_difference < -100 && (p.peak_score > p.normalized_scores.first)}
	@count = Position.count
	erb :index
end

# get the next game not marked as done
get "/next_position" do
	content_type :json
	(Position.first :checked => false).to_json
end


# update a boomerang with the result
post "/positions/:id" do
	content_type :json
	p = Position.get params[:id]

	if p
		puts params.inspect
		p.checked = true
		p.is_boomerang = params[:is_boomerang]
		p.moves = params[:moves]
		p.scores = params[:scores]
		p.depth = params[:depth]
		if p.save
			p.to_json
		else
			status 400
		end
	else 
		status 404
	end
end
