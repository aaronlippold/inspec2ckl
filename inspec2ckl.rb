#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require 'nokogiri'
require 'optparse'

# filename = 'exam.xml'
# xml = File.read(filename)
# doc = Nokogiri::XML(xml)
# # ... make changes to doc ...
# File.write(filename, doc.to_xml)
#  cat file2.json | jq '.profiles[].controls[] | "\(.impact) \(.tags.gid)"'

script_version = '1.0'

options = { ckl_file: nil, json_file: nil, output: nil }

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: inspec2ckl.rb [options]'
  opts.on('-c',
          '--ckl ckl_file',
          'the path to the DISA Checklist file') do |ckl|
    options[:ckl] = ckl
  end
  opts.on('-j',
          '--json json_file',
          'the path to the InSpec JSON results file') do |json|
    options[:json] = json
  end
  opts.on('-o',
          '--output results.ckl',
          'The file name you want for the output file (results.ckl)') do |output|
    options[:output] = output
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
else
  puts "The results will be placed in the file - `#{options[:output]}`: "
end

puts json_file = options[:json].to_s
puts ckl_file = options[:ckl].to_s
puts results = options[:output].to_s

inspec_json = File.read(json_file)
disa_xml = Nokogiri::XML(File.open(ckl_file))

def find_status_by_vuln(vuln,xml)
  nodes = xml.search "[text()*='#{vuln}']"
  node = nodes.first
  node.parent.parent.xpath('./STATUS').text
end

def set_status_by_vuln(vuln,status,xml)
  nodes = xml.search "[text()*='#{vuln}']"
  node = nodes.first
  node.parent.parent.at('./STATUS').content = status
end

def inspec_status_to_clk_status(vuln, json_results)
  result = nil
  result = 'NotAFinding' if json_results[vuln]['status'] == 'passed'
  result = 'Open' if json_results[vuln]['status'] == 'failed'
  result = 'Not_Reviewed' if json_results[vuln]['status'] == 'nil'
  result = 'Not_Reviewed' if json_results[vuln]['status'] == 'skipped'
  result = 'Not_Applicable' if json_results[vuln]['imapct'] == '0'
  result
end

def parse_json(json)
  file = JSON.parse(json)
  controls = file['profiles'][0]['controls']
  data = {}
  controls.each do |control|
    gid = control['id']
    data[gid] = {}
    data[gid]['impact'] = "#{control['impact']}"
    data[gid]['status'] = control.key?('results') ? control['results'][0]['status'] : 'nil'
  end
  data
end

def update_ckl_file(disa_xml, parsed_json)
  disa_xml.xpath('//CHECKLIST/STIGS/iSTIG/VULN').each do |vul|
    vnumber = vul.xpath('./STIG_DATA/VULN_ATTRIBUTE[text()="Vuln_Num"]/../ATTRIBUTE_DATA').text
    new_status = inspec_status_to_clk_status(vnumber.to_s, parsed_json)
    set_status_by_vuln(vnumber, new_status,disa_xml)
  end
end

test_results = parse_json(inspec_json)
update_ckl_file(disa_xml, test_results)
File.write(results, disa_xml.to_xml)
