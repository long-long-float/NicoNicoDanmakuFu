require 'webrick'

s = WEBrick::HTTPServer.new(
	DocumentRoot: './',
	Port: 8080
)

Signal.trap('INT') do
	s.shutdown
end

s.start