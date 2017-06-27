#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require 'nokogiri'

  # filename = 'exam.xml'
  # xml = File.read(filename)
  # doc = Nokogiri::XML(xml)
  # # ... make changes to doc ...
  # File.write(filename, doc.to_xml)

  #  cat file2.json | jq '.profiles[].controls[] | "\(.impact) \(.tags.gid)"'

json = File.read('file2.json')
@norgi = Nokogiri::XML(File.open('test.ckl'))

# @norgi.xpath('//CHECKLIST/STIGS/iSTIG/VULN').each do |vul|
#   vnumber = vul.xpath('./STIG_DATA/VULN_ATTRIBUTE[text()="Vuln_Num"]/../ATTRIBUTE_DATA').text
#   status = vul.xpath('./STATUS').text
#   puts "#{vnumber}: is #{status}"
# end

def find_status_by_vuln(vuln)
  nodes = @norgi.search "[text()*='#{vuln}']"
  node = nodes.first
  puts node.parent.parent.xpath('./STATUS').text
end

def set_status_by_vuln(vuln,status)
  nodes = @norgi.search "[text()*='#{vuln}']"
  node = nodes.first
  current_status = node.parent.parent.xpath('./STATUS')
  node.parent.parent.at('./STATUS').content = status
end

def inspec_status_to_clk_status(vuln, json_results)
  puts 'Not A Finding' if json_results[vuln]['status'] == 'passed'
  puts 'Finding' if json_results[vuln]['status'] == 'failed'
  puts 'Not Evaluated(nil)' if json_results[vuln]['status'] == 'nil'
  puts 'Not Evaluated' if json_results[vuln]['status'] == 'skipped'
  puts 'Not Applicable' if json_results[vuln]['imapct'] == '0'
end

def parse_json(json)
  file = JSON.parse(json)
  controls = file['profiles'][0]['controls']
  data = {}
  controls.each do |control|
    gid = control['tags']['gid']
    data[gid] = {}
    data[gid]['impact'] = control['impact']
    data[gid]['status'] = control.key?('results') ? control['results'][0]['status'] : 'nil'
  end
  data
end

test_results = parse_json(json)

test_results.keys.each do |vuln|
  inspec_status_to_clk_status(vuln, test_results)
end

# puts x = parse_inspec_json(json)
# map_controls(x)
