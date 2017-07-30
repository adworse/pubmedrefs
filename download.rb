require 'mechanize'

BASELINE = 'https://ftp.ncbi.nlm.nih.gov/pubmed/baseline'
UPDATES = 'https://ftp.ncbi.nlm.nih.gov/pubmed/updatefiles'

`touch parsed.txt`
@parsed = File.read('parsed.txt').split("\n")

def get_links(root)
  puts "Getting links from #{root}"
  agent = Mechanize.new
  page = agent.get(root)  
  page.search('a').map { |l| 
    l[:href]}.select { |l| 
      l =~ /xml.gz$/}.map { |l| 
        root + '/' + l 
  }
end

def get_files(links)
  agent = Mechanize.new
  agent.pluggable_parser.default = Mechanize::Download
  Dir.mkdir('xml') unless Dir.exist?('xml')
  links.each_with_index {|link, num|  
    filename = "xml/#{link[/[^\/]+$/]}"
    next if File.exist?(filename)
    agent.get(link).save(filename)
    print "#{num + 1} of #{links.count} saved\r"
  }
end

links = get_links(BASELINE) + get_links(UPDATES)
brutto = links.count
links = links.delete_if { |link| @parsed.include? link[/medline[^.]+/] }
netto = links.count

abort("All the #{brutto} files are already parsed. Nothing to download") if netto == 0

puts "Downloading #{netto} files out of #{brutto} existent"
get_files(links)
puts "Files downloaded. Run parse.rb"
