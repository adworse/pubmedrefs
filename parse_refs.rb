Encoding.default_external = Encoding::UTF_8
require 'ox'
require 'parallel'

MULTICORE = 12 # Set according to your system's number of CPU cores

class Handler < Ox::Sax
  attr_accessor :csv

  def start_element(name)
    @current_node = name
    case name
    when :PubmedArticle
      @article = {refs: []}
      @csv ||= []
    end
  end
  
  def text(value)
    case @current_node
    when :PMID
      @pmid = value.to_i
      @article[:id] ||= @pmid
    else
      return
    end
  end

  def attr(name, value)
    @is_cites = (name == :RefType && value == "Cites")
    @csv << "#{@pmid},#{@article[:id]}\n" if @is_cites && @pmid != @article[:id]
  end

  def end_element(name)
    case name
    when :PubmedArticle
      @csv[@article[:id]] = @article[:refs] unless @article[:refs] == []
    else
      return
    end
  end

end


def xml_to_csv(filename)
  handler = Handler.new
  `gunzip xml/#{filename}.xml.gz`
  file = File.open("xml/#{filename}.xml")
  Ox.sax_parse(handler, file)
  File.write("csv/#{filename}.csv", handler.csv.join)
  if File.exist?("csv/#{filename}.csv")
    File.open('parsed.txt', 'a') { |f| f.write "#{filename}\n" } 
    File.delete("xml/#{filename}.xml")
  end
end

def bulk_wrapper(filename)
  xml_to_csv filename
  count = Dir["csv/*"].count
  print "#{count} of #{@filenames.count} parsed       \r"
end

@filenames = Dir["xml/*"].map {|path| path[/medline.+\d\d\d\d/]}
abort("Nothinq to parse") if @filenames == []
Dir.mkdir('csv') unless Dir.exist?('csv')
Parallel.each(@filenames, in_processes: MULTICORE) { |filename|
  bulk_wrapper(filename)
}

parsed = File.read('parsed.txt').split("\n").sort.uniq
File.write('parsed.txt', parsed.join("\n"))
puts "#{@filenames.count} files parsed"

puts "joining edge list"
`cat csv/*.csv | sort | uniq > edge_list.csv`

puts 'Loading edge list'
file = File.open("edge_list.csv")
references = Hash.new{ |h, k| h[k] = [] }
file.each_line { |line| 
  key, value = line.chomp.split(",").map(&:to_i)
  references[key] << value
}

puts 'Composing adjacency list'
adjacency_list = []
references.each { |vertex, edges| adjacency_list << [vertex, edges*',']*',' }
File.write('adjacency_list.csv', adjacency_list*"\n")

`rm -rf csv`