#!/usr/bin/env ruby

while headers = $stdin.gets("\r\n\r\n")
  content_length = headers[/Content-Length: (.*)/].to_i
  raw_request = $stdin.read(content_length)
end
