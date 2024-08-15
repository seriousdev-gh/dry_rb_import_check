require 'parser/current'
require_relative 'lib/find_classes'

class ImportCheck
  def initialize(path)
    @path = path
  end

  def call
    root_node = Parser::CurrentRuby.parse(File.read(@path))
    FindClasses.new(root_node, @path).call
  rescue => e
    puts "Error processing file: #{@path}:"
    puts e.message
  end
end
