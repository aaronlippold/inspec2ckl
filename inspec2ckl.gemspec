# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inspec2ckl/version'

Gem::Specification.new do |spec|
  spec.name          = 'inspec2ckl'
  spec.version       = InspecCKL::VERSION
  spec.authors       = ['Aaron Lippold']
  spec.email         = ['lippold@gmail.com']
  spec.authors       = ['Rony Xaiver']
  spec.email         = ['rx294@gmail.com']
  spec.summary       = 'Infrastructure and compliance testing parser and converter'
  spec.description   = 'InSpec2CKL takes the full-json output of an InSpec security profile run and convertes it into a DISA Checklist (.ckl) file..'
  spec.homepage      = 'https://github.com/aaronlippold/inspec2ckl'
  spec.license       = 'Apache-2.0'

  spec.files = %w{
    README.md LICENSE inspec2ckl.gemspec
    Gemfile .rubocop.yml
  } + Dir.glob(
    '{bin,data,lib}/**/*', File::FNM_DOTMATCH
  ).reject { |f| File.directory?(f) }

  spec.executables   = %w{ inspec2ckl }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'nokogiri-happymapper', '~> 0'
  spec.add_dependency 'happymapper', '~> 0'
  spec.add_dependency 'nokogiri', '~> 1.8.1'
  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'json', '>= 1.8', '< 3.0'
  spec.add_dependency 'pry', '~> 0'
end
