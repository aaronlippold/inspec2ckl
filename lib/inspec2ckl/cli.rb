#!/usr/bin/env ruby
# encoding: utf-8
# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu

require "thor"
require 'nokogiri'
require_relative 'version'
require_relative 'inspec2ckl'

# DTD_PATH = "checklist.dtd"

class MyCLI < Thor
  desc 'exec', 'Inspec2ckl translates Inspec results json to Stig Checklist'
  option :json, required: true, aliases: '-j'
  option :cklist, required: true, aliases: '-c'
  option :output, required: true, aliases: '-o'
  option :verbose, type: :boolean, aliases: '-V'
  def exec
    Inspec2ckl.new(options[:json], options[:cklist], options[:output], options[:verbose])
  end

  # desc 'validate', 'A small parser to take the JSON full output of an InSpec profile results and update the DISA Checklist file.'
  # option :json, aliases: '-j'
  # option :cklist, aliases: '-c'
  # def validate
  #   if !options[:json].nil?
  #     # @todo complete json validation code
  #     puts schema = Inspec::Schema.json('exec-json')
  #     inspec_json = File.read(options[:json])
  #     # puts inspec_json
  #     puts JSON::Validator.validate(schema, inspec_json.to_s)
  #   end
  #   if !options[:cklist].nil?
  #     # @todo complete xml validation code
  #     xml = File.read(options[:cklist])
  #     # puts xml
  #     options = Nokogiri::XML::ParseOptions::DTDVALID
  #     puts options
  #     doc = Nokogiri::XML::Document.parse(xml, nil, nil, options)
  #     puts doc.external_subset.validate(doc)
  #   end
  # end

  map %w{--help -h} => :help
  desc 'help', 'Help for using Inspec2ckl'
  def help
    puts "\nInspec2ckl translates Inspec results json to Stig Checklist\n\n"
    puts "\t-j --json : Path to Inspec results json file"
    puts "\t-c --cklist : Path to Stig Checklist file"
    puts "\t-o --output : Path to output checklist file"
    puts "\t-V --verbose : verbose run"
    puts "\nexample: ./inspec2ckl exec -c checklist.ckl -j results.json -o output.ckl\n\n"
  end

  map %w{--version -v} => :print_version
  desc '--version, -v', "print's inspec2ckl version"
  def print_version
    puts InspecCKL::VERSION
  end
end

MyCLI.start(ARGV)
