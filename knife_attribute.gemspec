# -*- encoding: utf-8 -*-
require File.expand_path('../lib/knife_attribute/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'knife_attribute'
  gem.version       = Knife::Attribute::VERSION
  gem.date          = '2016-12-11'
  gem.summary       = 'A knife plugin for comparing environment attributes'
  gem.description   = 'A knife plugin for comparing environment attributes'
  gem.authors       = ['Chris Sullivan']
  gem.email         = ['']
  gem.homepage      = ''

  gem.files         = Dir['{lib}/**/*', 'README*', 'LICENSE*']
  gem.require_paths = ['lib']
  gem.license       = 'MIT'
end
