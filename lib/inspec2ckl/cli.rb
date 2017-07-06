#!/usr/bin/env ruby
# encoding: utf-8
# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu

require "thor"
require 'nokogiri'
require "json-schema"
require_relative 'inspec2ckl'


class MyCLI < Thor
  default_task :help

  desc "exec", 'Inspec2ckl translates Inspec results json to Stig Checklist'
  option :json, required: true, aliases: '-j'
  option :cklist, required: true, aliases: '-c'
  option :output, required: true, aliases: '-o'
  option :verbose, type: :boolean, aliases: '-v'
  def exec
    Inspec2ckl.new(options[:json], options[:cklist], options[:output], options[:verbose])
  end

  desc "validate", 'Inspec2ckl translates Inspec results json to Stig Checklist'
  option :json, aliases: '-j'
  option :cklist, aliases: '-c'
  def validate
    if !options[:json].nil?
      #@todo add json validation code
    end
    if !options[:cklist].nil?
      #@todo add xml validation code
    end
  end

  desc "help", "Help for using Inspec2ckl"
  def help
    puts "\nInspec2ckl translates Inspec results json to Stig Checklist\n\n"
    puts "\t-j --json : Path to Inspec results json file"
    puts "\t-c --cklist : Path to Stig Checklist file"
    puts "\t-o --output : Path to output checklist file"
    puts "\t-v --verbose : verbose run"
    puts "\nexample: ./inspec2ckl exec -c checklist.ckl -j results.json -o output.ckl\n\n"
  end
end

MyCLI.start(ARGV)
