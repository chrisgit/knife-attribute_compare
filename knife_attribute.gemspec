# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife_attribute/version'

Gem::Specification.new do |spec|
  spec.name          = 'knife_attribute'
  spec.version       = Knife::Attribute::VERSION
  spec.authors       = ['Chris Sullivan']
  spec.email         = ['email-blocked']
  spec.date          = '2016-12-11'

  spec.summary       = 'Compare Chef Node, Role and Environment Attributes'
  spec.description   = 'A knife plugin for comparing attributes'
  spec.homepage      = 'https://github.com/chrisgit/knife-attribute_compare'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib}/**/*', 'README*', 'LICENSE*']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.2'
  
end
