require 'csv'

Dir.glob("with_non_significant/*.csv").each do |input|
	ns_csv = CSV.parse(open(input).read)

	pr_path = "player_results/" + input.split("/").last
	pr_csv = CSV.parse(open(pr_path).read)


	CSV.open("merged/#{input.split("/").last}", "w") do |output|
		header_row = ns_csv[0]
		body_row = ns_csv[1]


		pr_csv[0].each_with_index do |header, i|
			if !ns_csv[0].include?(header)
				header_row << header
				body_row << pr_csv[1][i]
			end
		end

		output << header_row
		output << body_row
	end
end