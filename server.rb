#!/usr/bin/env /opt/rubies/3.4.1/bin/ruby
require 'json'

$stdin.sync = true
$stdout.sync = true
$stderr.sync = true

$stdin.binmode
$stdout.binmode
$stderr.binmode

def read_request
  headers = $stdin.gets("\r\n\r\n")
  return nil if headers.nil?

  content_length = headers[/Content-Length: (\d+)/i, 1].to_i
  raw_request = $stdin.read(content_length)
  JSON.parse(raw_request, symbolize_names: true)
end

def write_response(response)
  json_response = response.to_json
  $stdout.print "Content-Length: #{json_response.bytesize}"
  $stdout.print "\r\n\r\n"
  $stdout.print json_response
end

while request = read_request

  case request[:method]
  when "initialize"
    write_response(id: request[:id], result: {
      capabilities: {},
    })
    $stderr.puts "Initialize"
  when 'initialized'
    $stderr.puts "Initialized"
  when 'shutdown'
    write_response(id: request[:id], result: nil)
    $stderr.puts "Shutdown"
  when 'exit'
    break
  end
end
