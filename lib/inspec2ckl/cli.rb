require "thor"
require_relative 'inspec2ckl'

class MyCLI < Thor
  desc "inspec2ckl", "say hello to NAME"
  option :json, required: true, aliases: '-j'
  option :cklist, required: true, aliases: '-c'
  option :output, required: true, aliases: '-o'
  option :verbose, type: :boolean, aliases: '-v'
  def inspec2ckl()
    Inspec2ckl.new(options[:json], options[:cklist], options[:output],options[:verbose])
  end
end

MyCLI.start(ARGV)
