#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'nokogiri'
require 'optparse'
script_version = '1.0'

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
          '--message "mesg"',
          'A message to add to the control\'s "comments" section (optional)') do |mesg|
            options[:mesg] = mesg
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
puts @comment_mesg = options[:mesg].to_s || 'Automated compliance tests brought to you by the MITRE corp, CrunchyDB and the InSpec Project.'

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
    content = node.parent.parent.at('./COMMENTS').content
    if content.empty?
      content = @comment_msg
    else
      content << "\n\n . @comment_msg"
    end
    node.parent.parent.at('./COMMENTS').content = content
  end
end

# @todo add a case when we don't have a 'results array' => 'Not Reviewed'
# @todo add a 'Automated Tests brought to you by MITRE, CrunchyDB and InSpec' to the control comments.

def inspec_status_to_clk_status(vuln, json_results)
  case json_results[vuln]['status']
  when 'passed'
    result = 'NotAFinding'
  when 'failed'
    result = 'Open'
  when 'skipped'
    result = 'Not_Reviewed'
  end
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
    data[gid]['impact'] = control['impact'].to_s
    data[gid]['status'] = control.key?('results') ? control['results'][0]['status'] : 'nil'
    # @todo:  Figure out usecases for multiple statuses of pass or skip
  end
  data
end

def update_ckl_file(disa_xml, parsed_json)
  disa_xml.xpath('//CHECKLIST/STIGS/iSTIG/VULN').each do |vul|
    vnumber = vul.xpath('./STIG_DATA/VULN_ATTRIBUTE[text()="Vuln_Num"]/../ATTRIBUTE_DATA').text
    new_status = inspec_status_to_clk_status(vnumber.to_s, parsed_json)
    set_status_by_vuln(vnumber, new_status, disa_xml, @comment_mesg.to_s)
  end
end

test_results = parse_json(inspec_json)
update_ckl_file(disa_xml, test_results)
File.write(results, disa_xml.to_xml)
