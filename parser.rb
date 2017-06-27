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

def parse_inspec_json(json)
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

myjson = parse_inspec_json(json)

pp myjson['V-73015']['impact']

def find_status_by_vuln(vuln)
  nodes = @norgi.search "[text()*='#{vuln}']"
  node = nodes.first
  puts node.parent.parent.xpath('./STATUS').text
end

def set_status_by_vuln(vuln,status)
  nodes = @norgi.search "[text()*='#{vuln}']"
  node = nodes.first
  puts "I found node: #{node}"
  current_status = node.parent.parent.xpath('./STATUS')
  puts "The node has content: #{node.content}"
  puts "It has the status of: #{current_status}"
  puts node.parent.parent.at('./STATUS').content = "test"
  puts @norgi.to_xml
end

#find_status_by_vuln('V-7284')
#set_status_by_vuln('V-7284','test')
#find_status_by_vuln('V-7284')

#   puts "x: #{x.xpath('./STATUS').text}"
# end

#xml.elements.each('CHECKLIST/STIGS/iSTIG/VULN/STIG_DATA/ATTRIBUTE_DATA') { |element| puts element.text if element.text =~ /^V-.*/ }

  def map_controls(controls)
    controls.each do |x|
      if x['status'].match('passed')
        puts "#{x['id']} should be set to 'Not A Finding'"
      elsif x['status'].match('failed')
        puts "#{x['id']} should be set to 'Finding'"
      elsif x['status'].match('skipped')
        puts "#{x['id']} should be set to 'Not Evaluated'"
      # case where control impact == 0 => NotAppliciable
      else x['status'].match('z')
        puts "#{x['id']} should be set to 'z'"
      end
    end
  end

# puts x = parse_inspec_json(json)
# map_controls(x)
