require_relative 'import_check'

def usage
  puts <<~TXT
    TODO!
  TXT
end


if ARGV.empty?
  usage
else
  ARGV.each do |arg|
    if File.file? arg
      ImportCheck.new(arg).call
    elsif File.directory? arg
      Dir["#{arg}/**/*.rb"].each do |file|
        ImportCheck.new(file).call
      end
    else
      usage
      raise "#{arg} is not a file."
    end
  end
end

