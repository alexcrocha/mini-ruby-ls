#!/usr/bin/env /opt/rubies/3.4.1/bin/ruby

require 'json'
require 'prism'

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

class Document
 attr_reader :source

 def initialize(source)
   @source = source
   @parse_result = Prism.parse(source)
 end

 def source=(source)
    @source = source
    @parse_result = Prism.parse(source)
 end

 def ast
   @parse_result.value
 end
end

class Indexer < Prism::Visitor
  def initialize(index)
    @index = index
  end

  def visit_class_node(node)
    name = node.constant_path.slice
    @index[name] = "Found #{name}"

    super
  end
end

store = {}

# Currently stores `Name => "Found #{Name}"`. In the Ruby LSP, index is a proper object and the data is saved with
# specialized entries that hold information about each declaration
index = {}

while request = read_request
  case request[:method]
  when "initialize"
    write_response(
      id: request[:id],
      result: {
        capabilities: {
          textDocumentSync: {
            openClose: true,
            change: 1
          }
        }
      }
    )
  when "initialized"
    $stderr.puts "Indexing files..."

    Dir
      .glob("**/*.rb")
      .each do |file|
        parsed_file = Prism.parse_file(file)
        ast = parsed_file.value
        indexer = Indexer.new(index)
        indexer.visit(ast)
      end

    $stderr.puts index.inspect
  when "textDocument/didOpen"
    uri = request[:params][:textDocument][:uri]
    content = Document.new(request[:params][:textDocument][:text])
    store[uri] = content
  when "textDocument/didClose"
    uri = request[:params][:textDocument][:uri]
    store.delete(uri)
  when "textDocument/didChange"
    uri = request[:params][:textDocument][:uri]
    request[:params][:contentChanges].each do |content|
      store[uri].source = content[:text]
    end
  when "shutdown"
    write_response(id: request[:id], result: nil)
  when "exit"
    break
  end
end
