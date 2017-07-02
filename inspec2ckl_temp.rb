#!/usr/local/bin/ruby
require 'rubygems'
require 'json'
require 'nokogiri'
require 'optparse'
require 'date'
# require 'pry'

script_version = '1.1'

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
          '--message "mesg"', String,
          'A message to add to the control\'s "comments" section (optional)') do |mesg|
            options[:mesg] = mesg
          end
  opts.on('-V,',
          '--verbose',
          'Show me the data!!! (true|*false)') do |verbose|
            options[:verbose] = verbose
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
end

json_file = options[:json].to_s
ckl_file = options[:ckl].to_s
results = options[:output].to_s
@comment_mesg = options[:mesg] || 'Automated compliance tests brought to you by the MITRE corporation, CrunchyDB and the InSpec project.'
@verbose = options[:verbose] || false
@count = 0

if @verbose
  puts '=========='
  puts "Parsing the InSpec Results from: #{json_file}"
  puts "Creating a new DISA Checklist file: #{results}"
  puts '-------'
  puts "using #{ckl_file} as a base"
  puts '=========='
end
#
# inspec_json = File.read(json_file)
# disa_xml = Nokogiri::XML(File.open(ckl_file))
#
# def find_status_by_vuln(vuln, xml)
#   nodes = xml.search "[text()*='#{vuln}']"
#   node = nodes.first
#   node.parent.parent.xpath('./STATUS').text
# end
#
# def set_status_by_vuln(vuln, status, xml, msg = "")
#   nodes = xml.search "[text()*='#{vuln}']"
#   node = nodes.first
  # @todo add a guard here to make sure we set a status even if we don't have results.
#   # an if status = 'bad thing' then status = "Not Reviewed" ??
#   node.parent.parent.at('./STATUS').content = status
#   if !msg.empty?
#     time = Time.now
#     content = node.parent.parent.at('./COMMENTS').content
#     if content.empty?
#       content = "#{time}: #{@comment_mesg}"
#     else
#       content << "\n#{time}: #{@comment_mesg}"
#     end
#     node.parent.parent.at('./COMMENTS').content = content
#   end
# end
#
# def inspec_status_to_clk_status(vuln, json_results)
#   status_list = json_results[vuln]['status'].uniq
#   puts status_list
#   result = case
#     when status_list.include?('failed') then 'Open'
#     when status_list.include?('passed') then 'NotAFinding'
#     when status_list.include?('skipped') then 'Not_Reviewed'
#     # else 'Not_Reviewed' # in case some controls come back with no results
#   end
#   result = 'Not_Applicable' if json_results[vuln]['impact'] == '0.0'
#   puts vuln, status_list, result, json_results[vuln]['impact'], '=============' if @verbose
#   result
# end
#
# def parse_json(json)
#   file = JSON.parse(json)
#   controls = file['profiles'][1]['controls']
#   data = {}
#   controls.each do |control|
#     @count += 1
#     gid = control['id']
#     data[gid] = {}
#     data[gid]['impact'] = control['impact'].to_s
#     data[gid]['status'] = []
#     data[gid]['message'] = []
#     puts control['id']
#     require 'pry'; binding.pry;
#     # @todo:  Figure out usecases for multiple statuses of pass or skip
#     if control.key?('results')
#       control['results'].each do |result|
#         data[gid]['status'].push(result['status'])
#         data[gid]['message'].push('passed') if result['status'] == 'passed'
#         data[gid]['message'].push(result['skip_message']) if result['status'] == 'skipped'
#         data[gid]['message'].push(result['message']) if result['status'] == 'failed'
#       end
#     end
#   end
#   data
# end
#
# def update_ckl_file(disa_xml, parsed_json)
#   disa_xml.xpath('//CHECKLIST/STIGS/iSTIG/VULN').each do |vul|
#     vnumber = vul.xpath('./STIG_DATA/VULN_ATTRIBUTE[text()="Vuln_Num"]/../ATTRIBUTE_DATA').text
#     new_status = inspec_status_to_clk_status(vnumber.to_s, parsed_json)
#     set_status_by_vuln(vnumber, new_status, disa_xml, @comment_mesg)
#   end
# end
#
# test_results = parse_json(inspec_json)
# update_ckl_file(disa_xml, test_results)
# File.write(results, disa_xml.to_xml)
# puts "Processed #{@count} controls"
#
#



#
class Inspec2ckl
  def initialize(xml_file, json_file, output_file)
    inspec_json = File.read(json_file)
    disa_xml = Nokogiri::XML(File.open(xml_file))
    @data = parse_json(inspec_json)
    @parsed_xml = parse_xml(disa_xml)
    puts set_Vuln_Num('V-73001')
    # update_ckl_file
    # File.write(output_file, disa_xml.to_xml)
        require 'pry'; binding.pry;

    puts "Processed #{@data.keys.count} controls"
  end

  def clk_status(control)
    status_list = control[:status].uniq
    puts status_list if @verbose
    result = 'Open' if status_list.include?('failed')
    result = 'NotAFinding' if status_list.include?('passed')
    result = 'Not_Reviewed' if status_list.include?('skipped')
    result = 'Not_Applicable' if control[:impact].to_f.zero?
    if @verbose
      puts vuln, status_list, result, json_results[vuln]['impact'], '============='
    end
    result
  end

  def clk_finding_details(control)
    control_clk_status = get_STATUS(control[:control_id])
    result = case control_clk_status
    when 'Open'
      then "One or more of the automated tests failed or was inconvlusive for the control \n\n #{control[:message]}"
    when 'NotAFinding'
      then "All Automated tests passed for the control"
    when 'Not_Reviewed'
      then "Automated test skipped due to known accepted condition in the control : \n\n#{control[:message]}"
    when 'Not_Applicable'
      then "Justification: \n\n #{control[:message]}"
    end
  end

  def update_ckl_file
    @data.keys.each do | control_id |
      # puts control_id
      # puts clk_status(@data[control_id])
      set_STATUS(control_id, clk_status(@data[control_id]))
      set_COMMENTS(control_id,"#{get_COMMENTS(control_id)}\n#{Time.now}: #{@comment_mesg}")
      set_FINDING_DETAILS(control_id, clk_finding_details(control))
    end
  end

  %w[set_STATUS set_FINDING_DETAILS set_COMMENTS set_SEVERITY_OVERRIDE set_SEVERITY_JUSTIFICATION].each do |attribute|
    define_method(attribute.to_sym) do |vuln_id, data|
      # puts attribute
      @parsed_xml[vuln_id.to_sym].at(attribute.to_s[4..-1]).content = data
    end
  end

  %w[set_Vuln_Num set_Severity set_Group_Title set_Rule_ID set_Rule_Ver set_Rule_Title set_Vuln_Discuss set_IA_Controls set_Check_Content set_False_Positives set_False_Negatives set_Documentable set_Mitigations set_Potential_Impact set_Third_Party_Tools set_Mitigation_Control set_Responsibility set_Security_Override_Guidance set_Check_Content_Ref set_Class set_STIGRef set_TargetKey set_CCI_REF set_CCI_REF].each do |attribute|
    define_method(attribute.to_sym) do |vuln_id,data|
      @parsed_xml[vuln_id.to_sym].at("[text()=#{attribute.to_s[4..-1]}]").parent.at('ATTRIBUTE_DATA').content = data
    end
  end

  %w[get_STATUS get_FINDING_DETAILS get_COMMENTS get_SEVERITY_OVERRIDE get_SEVERITY_JUSTIFICATION].each do |attribute|
    define_method(attribute.to_sym) do |vuln_id|
      @parsed_xml[vuln_id.to_sym].at(attribute.to_s[4..-1]).content
    end
  end

  %w[get_Vuln_Num get_Severity get_Group_Title get_Rule_ID get_Rule_Ver get_Rule_Title get_Vuln_Discuss get_IA_Controls get_Check_Content get_False_Positives get_False_Negatives get_Documentable get_Mitigations get_Potential_Impact get_Third_Party_Tools get_Mitigation_Control get_Responsibility get_Security_Override_Guidance get_Check_Content_Ref get_Class get_STIGRef get_TargetKey get_CCI_REF get_CCI_REF].each do |attribute|
    define_method(attribute.to_sym) do |vuln_id|
      @parsed_xml[vuln_id.to_sym].at("[text()=#{attribute.to_s[4..-1]}]").parent.at('ATTRIBUTE_DATA').content
    end
  end

  def parse_xml(disa_xml)
    @parsed_xml = {}
    nodes = disa_xml.xpath("//CHECKLIST//STIGS//iSTIG//VULN")
    nodes.each do |node|
      vuln_id = node.at("[text()='Vuln_Num']").parent.at('ATTRIBUTE_DATA').content.to_sym
      puts "||||||||||#{vuln_id}"
      @parsed_xml[vuln_id] = node
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
      puts control['id']
      if control.key?('results')
        control['results'].each do |result|
          data[c_id][:status].push(result['status'])
          # data[c_id][:message].push('passed') if result['status'] == 'passed'
          data[c_id][:message].push(result['skip_message']) if result['status'] == 'skipped'
          data[c_id][:message].push(result['message']) if result['status'] == 'failed'
        end
      end
      if data[c_id][:impact].to_f == 0
        data[c_id][:message] = control['desc']
      end
    end
    puts data[:status]
    data
  end
end

test = Inspec2ckl.new(ckl_file, json_file, results)
