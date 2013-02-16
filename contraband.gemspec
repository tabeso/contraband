# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contraband/version'

Gem::Specification.new do |gem|
  gem.name          = 'contraband'
  gem.version       = Contraband::VERSION
  gem.authors       = ['Gabriel Evans']
  gem.email         = ['gabe@tabeso.com']
  gem.description   = %q{Clean data importation from external resources.}
  gem.summary       = %q{Clean data importation from external resources.}
  gem.license       = 'MIT'
  gem.homepage      = 'https://github.com/tabeso/contraband'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'activemodel', '>= 3.0', '< 3.3'
  gem.add_dependency 'hashie', '>= 1.0', '< 1.3'

  gem.add_development_dependency 'active_attr', '~> 0.7'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'pry'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'

  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-bundler'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'guard-yard'
  gem.add_development_dependency 'rb-fsevent'
  gem.add_development_dependency 'rb-inotify'
  gem.add_development_dependency 'growl'
  gem.add_development_dependency 'terminal-notifier-guard'
end