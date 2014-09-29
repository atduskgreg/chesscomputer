require 'logger'

$logger = Logger.new File.new("players.log", "a")
$logger.formatter = proc do |severity, time, progname, msg|
	"#{severity} [#{time.strftime('%Y-%m-%d %H:%M')}] #{progname}: #{msg}\n"
end

# HERE
# code for sub-scripts to use to package up their results
# as a partial CSV row so that some parent script can gather them together