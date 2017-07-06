require "thor"
require_relative 'inspec2ckl'

class MyCLI < Thor
  desc "inspec2ckl", 'Inspec2ckl translates Inspec results json to Stig Checklist'
  option :json, required: true, aliases: '-j'
  option :cklist, required: true, aliases: '-c'
  option :output, required: true, aliases: '-o'
  option :verbose, type: :boolean, aliases: '-v'
  def inspec2ckl
    Inspec2ckl.new(options[:json], options[:cklist], options[:output], options[:verbose])
  end
  def help
    puts "\nInspec2ckl translates Inspec results json to Stig Checklist\n\n"
    puts "\t-j --json : Path to Inspec results json file"
    puts "\t-c --cklist : Path to Stig Checklist file"
    puts "\t-o --output : Path to output checklist file"
    puts "\t-v --verbose : verbose run"
    puts "\nexample: ./cli.rb inspec2ckl -c checklist.ckl -j results.json -o output.ckl\n\n"
  end
end

MyCLI.start(ARGV)
