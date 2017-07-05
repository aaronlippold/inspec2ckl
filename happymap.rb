#!/usr/local/bin/ruby

require 'happymapper'
require 'nokogiri'
require 'awesome_print'

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
    has_one :attrib, String, :tag => 'VULN_ATTRIBUTE'
    has_one :data, String, :tag => 'ATTRIBUTE_DATA'
  end

  class Vuln
    include HappyMapper
    tag 'VULN'
    has_many :stig_data, StigData, :tag =>'STIG_DATA'
    element :status, String, :tag => 'STATUS'
    has_one :finding_details, String, :tag => 'FINDING_DETAILS'
    has_one :comments, String, :tag => 'COMMENTS'
    has_one :severity_justification, String, :tag => 'SEVERITY_JUSTIFICATION'
  end

  #@todo missing the iSTIG class
  #@todo missing STIG Class
  # SI_DATA
  # STIG_INFO

  class SI_DATA
    include HappyMapper
    tag 'SI_DATA'

    element :data, String, tag: 'SID_DATA'
    element :name, String, tag: 'SID_NAME'
  end

  class STIG_INFO
    include HappyMapper
    tag 'STIG_INFO'

    has_many :si_data, SI_DATA, tag: 'SI_DATA'
  end

  class ISTIG
    include HappyMapper
    tag 'iSTIG'

    has_one :stig_info, STIG_INFO, tag: 'STIG_INFO'
    has_many :vuln, VULN, tag: 'VULN'
  end

  class Checklist
    include HappyMapper
    tag 'CHECKLIST'
    has_one :asset, Asset, :tag => 'ASSET'
    has_many :vuls, Vuln, :tag => 'VULN'
  end

  @checklist = Checklist.parse(doc.to_s)

  @checklist.vuls.each do |vuln|
    print "#{vuln.stig_data[0].data} has status: "
    print vuln.status
    print "\n"

    puts "vul_id: #{vuln.stig_data[0].data}"
    puts "severity: #{vuln.stig_data[1].data}"
  end

  ap @checklist.vuls

  puts "let's play with the data",'----------'
  puts "let's set the status of the first vulnerability to 'Open'"
  puts "it started as #{@checklist.vuls.first.status}"
  @checklist.vuls.first.status = "Open"
  @checklist.vuls.first.comments = "Generated with Love at the MITRE corp."
  puts "Now, it's is #{@checklist.vuls.first.status}"
  puts "... waiting ... and ..."
  sleep(2)
  puts @checklist.vuls.first.to_xml

  # puts checklist.asset.inspect

  # checklist.vuls.each do |vuln|
  #   vuln.stig_data.each do |el|
  #     puts "#{el.attrib} = #{el.data}"
  #   end
  #   puts vuln.status
  # end
