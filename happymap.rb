#!/usr/local/bin/ruby

require 'happymapper'
require 'nokogiri'

# see: https://github.com/dam5s/happymapper

  doc = File.open("data/postgres_checklist.ckl") { |f| Nokogiri::XML(f) }

  class Asset
    include HappyMapper
    tag 'ASSET'
    element :role, String, :tag => 'ROLE'
    element :type, String, :tag => 'ASSET_TYPE'
    element :host_name, String, :tag => 'HOST_NAME'
    element :host_ip, String, :tag => 'HOST_IP'
    element :host_mac, String, :tag => 'HOST_MAC'
    element :host_guid, String, :tag => 'HOST_GUID'
    element :host_fqdn, String, :tag => 'HOST_FQDN'
    element :tech_area, String, :tag => 'TECH_AREA'
    element :target_key, String, :tag => 'TARGET_KEY'
    element :web_or_database, String, :tag => 'WEB_OR_DATABASE'
    element :web_db_site, String, :tag => 'WEB_DB_SITE'
    element :web_db_instance, String, :tag => 'WEB_DB_INSTANCE'
  end

  class StigData
    include HappyMapper
    tag 'STIG_DATA'
    element :attrib, String, :tag => 'VULN_ATTRIBUTE'
    element :data, String, :tag => 'ATTRIBUTE_DATA'
  end

  class Vuln
    include HappyMapper
    tag 'VULN'
    has_many :stig_data, StigData, :tag =>'STIG_DATA'
    has_one :status, String, :tag => 'STATUS'
    has_one :finding_details, String, :tag => 'FINDING_DETAILS'
    has_one :comments, String, :tag => 'COMMENTS'
    has_one :severity_justification, String, :tag => 'SEVERITY_JUSTIFICATION'
  end

  #@todo missing the iSTIG class

  class Checklist
    include HappyMapper
    tag 'CHECKLIST'
    has_one :asset, Asset, :tag => 'ASSET'
    has_many :vuls, Vuln, :tag => 'VULN'
  end

  checklist = Checklist.parse(doc.to_s)

  print checklist

  checklist.vuls.each do |vuln|
    print vuln.stig_data.first.data
    print " has status: "
    print vuln.status
    print "\n"
  end
  #print checklist.to_xml

  # puts checklist.asset.inspect

  # checklist.vuls.each do |vuln|
  #   vuln.stig_data.each do |el|
  #     puts "#{el.attrib} = #{el.data}"
  #   end
  #   puts vuln.status
  # end
