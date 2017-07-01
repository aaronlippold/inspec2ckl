require 'thor'

module InspecCKL
  class CLI < Thor

    default_task :inspec2ckl_help

    desc "example FILE", "parse and create a DISA checklist file"
    method_option :delete, :aliases => "-d", :desc => "Delete the file after parsing it"
    method_options %w( say_hi -h ) => :boolean, :desc => "Say Hi"
    def example(file)
      puts "You supplied the file: #{file}"
      delete_file = options[:delete]
      if delete_file
        puts "You specified that you would like to delete #{file}"
      elsif options[:say_hi]
        puts "Hi!"
      else
        puts "You do not want to delete #{file}"
      end
    end

    desc "validate FILE", "validate the InSpec JSON or DISA checklist file"
    def validate(file)
      puts "#{file} seems to be good"
    end

    map %w[--version -v] => :print_version
    desc "--version, -v", "print's inspec2ckl version"
    def print_version
      puts "#{InspecCKL::VERSION}"
    end

    desc "help", "help"
    def inspec2ckl_help
      help
    end

  end
end
