require 'logger'
require 'tempfile'

# PLAYER_STAT_MAX = 0.007
# PLAYER_STAT_MIN = -0.007

$logger = Logger.new File.new("players.log", "a")
$logger.formatter = proc do |severity, time, progname, msg|
	"#{severity} [#{time.strftime('%Y-%m-%d %H:%M')}] #{progname}: #{msg}\n"
end

def to_csv_row h
	result = h.keys.collect(&:to_s).join(",")
	result << "\n" << h.values.join(",")
	result
end

def make_player_regex(filename)
	parts = filename.split(/\/|\./)
	last_name = parts[parts.length - 2].downcase.split("_")[0]
	return Regexp.new last_name, Regexp::IGNORECASE
end


def t_test(lengths, pop_mean)
	tmp = Tempfile.new("t_test_tmp")
	tmp.write(lengths.join(","))
	tmp.close
	
	t_result = `python t_test.py #{tmp.path} --population-mean=#{pop_mean}`

	tmp.unlink

	stats = {}
	t_result.split("\n").each{|e| r = e.split(":"); stats[r[0]] = r[1].to_f}
	return stats
end

def normalize_player_stat stat, options={}
	percent = stat/(options[:max] - options[:min])
	(percent*100).round
end