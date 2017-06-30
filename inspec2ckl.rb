#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'nokogiri'
require 'optparse'
require 'date'
script_version = '1.1'

options = { ckl_file: nil, json_file: nil, output: nil }

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: inspec2ckl.rb [options]'
  opts.on('-c',
          '--ckl ckl_file',
          'the path to the DISA Checklist file (required)') do |ckl|
            options[:ckl] = ckl
          end
  opts.on('-j',
          '--json json_file',
          'the path to the InSpec JSON results file (required)') do |json|
            options[:json] = json
          end
  opts.on('-o',
          '--output results.ckl',
          'The file name you want for the output file (results.ckl)') do |output|
            options[:output] = output
          end
  opts.on('-m,',
          '--message "mesg"', String,
          'A message to add to the control\'s "comments" section (optional)') do |mesg|
            options[:mesg] = mesg
          end
  opts.on('-V,',
          '--verbose',
          'Show me the data!!! (true|*false)') do |verbose|
            options[:verbose] = verbose
          end
  opts.on('-v',
          '--version',
          'inspec2ckl version') do
    puts 'inspec2ckl: v' + script_version.to_s
    exit
  end
  opts.on('-h',
          '--help',
          'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:ckl].nil?
  print 'Enter the path to the base DISA Checklist file (required): '
  options[:ckl] = gets.chomp
end

if options[:json].nil?
  print 'Enter the path to your InSpec JSON full results file (required): '
  options[:json] = gets.chomp
end

if options[:output].nil?
  puts 'The results will be placed in the file - `results.ckl`: '
  options[:output] = 'results.ckl'
end

json_file = options[:json].to_s
ckl_file = options[:ckl].to_s
results = options[:output].to_s
@comment_mesg = options[:mesg] || 'Automated compliance tests brought to you by the MITRE corporation, CrunchyDB and the InSpec project.'
@verbose = options[:verbose] || false
@count = 0

if @verbose
  puts '=========='
  puts "Parsing the InSpec Results from: #{json_file}"
  puts "Creating a new DISA Checklist file: #{results}"
  puts '-------'
  puts "using #{ckl_file} as a base"
  puts '=========='
end

inspec_json = File.read(json_file)
disa_xml = Nokogiri::XML(File.open(ckl_file))

def find_status_by_vuln(vuln, xml)
  nodes = xml.search "[text()*='#{vuln}']"
  node = nodes.first
  node.parent.parent.xpath('./STATUS').text
end

def set_status_by_vuln(vuln, status, xml, msg = "")
  nodes = xml.search "[text()*='#{vuln}']"
  node = nodes.first
  # @todo add a guard here to make sure we set a status even if we don't have results.
  # an if status = 'bad thing' then status = "Not Reviewed" ??
  node.parent.parent.at('./STATUS').content = status
  if !msg.empty?
    time = Time.now
    content = node.parent.parent.at('./COMMENTS').content
    if content.empty?
      content = "#{time}: #{@comment_mesg}"
    else
      content << "\n#{time}: #{@comment_mesg}"
    end
    node.parent.parent.at('./COMMENTS').content = content
  end
end

def inspec_status_to_clk_status(vuln, json_results)
  status_list = json_results[vuln]['status'].uniq
  result = case
    when status_list.include?('failed') then 'Open'
    when status_list.include?('passed') then 'NotAFinding'
    when status_list.include?('skipped') then 'Not_Reviewed'
    else 'Not_Reviewed' # in case some controls come back with no results
  end
  result = 'Not_Applicable' if json_results[vuln]['impact'] == '0.0'
  puts vuln, status_list, result, json_results[vuln]['impact'], '=============' if @verbose
  result
end

def parse_json(json)
  file = JSON.parse(json)
  controls = file['profiles'][0]['controls']
  data = {}
  controls.each do |control|
    @count += 1
    gid = control['id']
    data[gid] = {}
    data[gid]['impact'] = control['impact'].to_s
    data[gid]['status'] = []
    # @todo:  Figure out usecases for multiple statuses of pass or skip
    if control.key?('results')
      control['results'].each do |result|
        data[gid]['status'].push(result['status'])
      end
    end
  end
  data
end

def update_ckl_file(disa_xml, parsed_json)
  disa_xml.xpath('//CHECKLIST/STIGS/iSTIG/VULN').each do |vul|
    vnumber = vul.xpath('./STIG_DATA/VULN_ATTRIBUTE[text()="Vuln_Num"]/../ATTRIBUTE_DATA').text
    new_status = inspec_status_to_clk_status(vnumber.to_s, parsed_json)
    set_status_by_vuln(vnumber, new_status, disa_xml, @comment_mesg)
  end
end

test_results = parse_json(inspec_json)
update_ckl_file(disa_xml, test_results)
File.write(results, disa_xml.to_xml)
puts "Processed #{@count} controls"
