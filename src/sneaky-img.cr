VERSION = "0.1.0"
require "http/server"
require "./svg"

server = HTTP::Server.new do |context|
  # puts context.request.inspect

  if ip = context.request.headers["X-Real-IP"]? # When using a reverse proxy that guarantees this field.
    context.request.remote_address = Socket::IPAddress.new(ip, 0)
  end

  client_ip = context.request.remote_address.to_s.split(':')[0]
  accept_lang = context.request.headers["Accept-Language"]  # TODO: remove the quality value
  user_agent = context.request.headers["User-Agent"]

  browser = ""
  if sec_ch_ua = context.request.headers["sec-ch-ua"]?
    regex_matches = sec_ch_ua.scan(/"(.+?)";v="(.+?)"/)

    if /.*?Not.+?A.+?Brand.*?/i.match(regex_matches[0][1])
      browser = regex_matches[1][1] + " " + regex_matches[1][2]
    else
      browser = regex_matches[0][1] + " " + regex_matches[0][2]
    end
  else
    browser = user_agent.split(' ').last.gsub('/', ' ')
  end

  platform_arr = /\((.+?)\)/.match(user_agent).as(Regex::MatchData)[1].split("; ")
  platform = platform_arr[0] + ", " + platform_arr[1]

  client_data = {
    "Your IP": client_ip,
    "Browser": browser,
    "Platform": platform,
    "Languages": accept_lang,
  }

  puts client_data

  context.response.content_type = "image/svg+xml"
  context.response.print gen_svg(client_data)
end

address = server.bind_tcp "0.0.0.0", 8001
puts "Listening on http://#{address}"
server.listen
