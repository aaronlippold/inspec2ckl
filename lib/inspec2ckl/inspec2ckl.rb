#!/usr/local/bin/ruby
# encoding: utf-8
# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu

require 'happymapper'
require 'nokogiri'
require 'json'
require_relative 'StigChecklist'

class Inspec2ckl < Checklist
  def initialize(json, cklist, output, verbose)
    @verbose = verbose
    inspec_json = File.read(json)
    @data = parse_json(inspec_json)
    doc = File.open(cklist) { |f| Nokogiri::XML(f) }
    @checklist = Checklist.new
    @checklist = Checklist.parse(doc.to_s)
    update_ckl_file
    File.write(output, @checklist.to_xml)
    puts "\nProcessed #{@data.keys.count} controls"
  end

  def clk_status(control)
    puts 'Full Status list: ' + control[:status].join(', ') if @verbose
    status_list = control[:status].uniq
    if status_list.include?('failed')
      result = 'Open'
    elsif status_list.include?('passed')
      result = 'NotAFinding'
    elsif status_list.include?('skipped')
      result = 'Not_Reviewed'
    else
      result = 'Not_Tested'
    end
    if control[:impact].to_f.zero?
      result = 'Not_Applicable'
    end
    result
  end

  def clk_finding_details(control)
    control_clk_status = @checklist.where('Vuln_Num',control[:control_id]).status
    result = "One or more of the automated tests failed or was inconclusive for the control \n\n #{control[:message]}" if control_clk_status == 'Open'
    result = 'All Automated tests passed for the control' if control_clk_status == 'NotAFinding'
    result = "Automated test skipped due to known accepted condition in the control : \n\n#{control[:message]}" if control_clk_status == 'Not_Reviewed'
    result = "Justification: \n #{control[:message].split.join(' ')}" if control_clk_status == 'Not_Applicable'
    result = 'No test available for this control' if control_clk_status == 'Not_Tested'
    result
  end

  def update_ckl_file
    @data.keys.each do | control_id |
      print '.'
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
