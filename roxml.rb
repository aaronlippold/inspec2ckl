#!/usr/bin/env ruby
require 'roxml'

# see: https://github.com/Empact/roxml

class CHECKLIST
  include ROXML
  xml_accessor :type, from: 'ASSET_TYPE', in: 'ASSET'
  xml_accessor :status, from: 'status', in: 'ASSET/STIGS/iSTIG'
  xml_accessor :id, from: 'ATTRIBUTE_DATA', in: 'ASSET/STIGS/iSTIG/VULN/STIG_DATA'
end

lib = CHECKLIST.from_xml(File.read('data/postgres_checklist.ckl'))

puts lib.type
puts lib.status
puts lib.id
