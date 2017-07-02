#!/usr/bin/env ruby
require 'roxml'

class CHECKLIST
  include ROXML
  xml_accessor :type, from: 'ASSET_TYPE', in: 'ASSET'
  xml_accessor :status, from: 'status', in: 'ASSET/STIGS/iSTIG'
end

lib = CHECKLIST.from_xml(File.read('data/postgres_checklist.ckl'))
