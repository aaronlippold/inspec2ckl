#!/usr/local/bin/ruby

require 'happymapper'
require 'nokogiri'
require 'awesome_print'
require 'inspec'

# see: https://github.com/dam5s/happymapper

class Asset
  include HappyMapper
  tag 'ASSET'
  element :role, String, tag: 'ROLE'
  element :type, String, tag: 'ASSET_TYPE'
  element :host_name, String, tag: 'HOST_NAME'
  element :host_ip, String, tag: 'HOST_IP'
  element :host_mac, String, tag: 'HOST_MAC'
  element :host_guid, String, tag: 'HOST_GUID'
  element :host_fqdn, String, tag: 'HOST_FQDN'
  element :tech_area, String, tag: 'TECH_AREA'
  element :target_key, String, tag: 'TARGET_KEY'
  element :web_or_database, String, tag: 'WEB_OR_DATABASE'
  element :web_db_site, String, tag: 'WEB_DB_SITE'
  element :web_db_instance, String, tag: 'WEB_DB_INSTANCE'
end

class SI_DATA
  include HappyMapper
  tag 'SI_DATA'
  element :name, String, tag: 'SID_NAME'
  element :data, String, tag: 'SID_DATA'
end

class StigInfo
  include HappyMapper
  tag 'STIG_INFO'
  has_many :si_data, SI_DATA, tag: 'SI_DATA'
end

class StigData
    include HappyMapper
    tag 'STIG_DATA'
    has_one :attrib, String, tag: 'VULN_ATTRIBUTE'
    has_one :data, String, tag: 'ATTRIBUTE_DATA'
end

class Vuln
  include HappyMapper
  tag 'VULN'
  has_many :stig_data, StigData, tag:'STIG_DATA'
  has_one :status, String, tag: 'STATUS'
  has_one :finding_details, String, tag: 'FINDING_DETAILS'
  has_one :comments, String, tag: 'COMMENTS'
  has_one :severity_override, String, tag: 'SEVERITY_OVERRIDE'
  has_one :severity_justification, String, tag: 'SEVERITY_JUSTIFICATION'
end

class IStig
  include HappyMapper
  tag 'iSTIG'
  has_one :stig_info, StigInfo, tag: 'STIG_INFO'
  has_many :vuln, Vuln, tag: 'VULN'
end

class Stigs
  include HappyMapper
  tag 'STIGS'
  has_one :istig, IStig, tag: 'iSTIG'
end

class Checklist
  include HappyMapper
  tag 'CHECKLIST'
  has_one :asset, Asset, tag: 'ASSET'
  has_one :stig, Stigs, tag: 'STIGS'

  def where(attrib, data)
    stig.istig.vuln.each do |vuln|
      if vuln.stig_data.any? { |element| element.attrib == attrib && element.data == data}
        # @todo Handle multiple objects that match the condition
        return vuln
      end
    end
  end

end

class Inspec2ckl < Checklist
  def initialize()
    doc = File.open("data/postgres_checklist.ckl") { |f| Nokogiri::XML(f) }
    inspec_json = File.read('nga.json')
    @data = parse_json(inspec_json)
    @checklist = Checklist.new
    @checklist = Checklist.parse(doc.to_s)
    ap @checklist.where('Vuln_Num','V-72841').status
    update_ckl_file

    File.write('nga6.ckl', @checklist.to_xml)
    puts "Processed #{@data.keys.count} controls"
  end

  def clk_status(control)
    status_list = control[:status].uniq
    puts status_list if @verbose
    if status_list.include?('failed')
      result = 'Open'
    elsif status_list.include?('passed')
      result = 'NotAFinding'
    elsif status_list.include?('skipped')
      result = 'Not_Reviewed'
    elsif control[:impact].to_f.zero?
      result = 'Not_Applicable'
    else
      result = 'Not_Tested'
    end
    if @verbose
      puts vuln, status_list, result, json_results[vuln]['impact'], '============='
    end
    result
  end

  def clk_finding_details(control)
    control_clk_status = @checklist.where('Vuln_Num',control[:control_id]).status
    result = "One or more of the automated tests failed or was inconvlusive for the control \n\n #{control[:message]}" if control_clk_status == 'Open'
    result = 'All Automated tests passed for the control' if control_clk_status == 'NotAFinding'
    result = "Automated test skipped due to known accepted condition in the control : \n\n#{control[:message]}" if control_clk_status == 'Not_Reviewed'
    result = "Justification: \n\n #{control[:message]}" if control_clk_status == 'Not_Applicable'
    result = 'No test available for this control' if control_clk_status == 'Not_Tested'
    result
  end

  def update_ckl_file
    @data.keys.each do | control_id |
      vuln = @checklist.where('Vuln_Num',control_id.to_s)
      vuln.status = clk_status(@data[control_id])
      vuln.comments << "\n#{Time.now}: Automated compliance tests brought to you by the MITRE corporation, CrunchyDB and the InSpec project."
      vuln.finding_details << clk_finding_details(@data[control_id])

      if @verbose
        puts control_id
        puts @checklist.where('Vuln_Num',control_id.to_s).status
        puts @checklist.where('Vuln_Num',control_id.to_s).finding_details
        puts '====================================='
      end
    end
  end

  def parse_json(json)
    file = JSON.parse(json)
    controls = file['profiles'].last['controls']
    data = {}
    controls.each do |control|
      c_id = control['id'].to_sym
      data[c_id] = {}
      data[c_id][:control_id] = control['id']
      data[c_id][:impact] = control['impact'].to_s
      data[c_id][:status] = []
      data[c_id][:message] = []
      if control.key?('results')
        control['results'].each do |result|
          data[c_id][:status].push(result['status'])
          data[c_id][:message].push(result['skip_message']) if result['status'] == 'skipped'
          data[c_id][:message].push(result['message']) if result['status'] == 'failed'
        end
      end
      if data[c_id][:impact].to_f == 0
        data[c_id][:message] = control['desc']
      end
    end
    data
  end
end

Inspec2ckl.new
