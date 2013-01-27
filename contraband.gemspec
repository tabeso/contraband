# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contraband/version'

Gem::Specification.new do |gem|
  gem.name          = 'contraband'
  gem.version       = Contraband::VERSION
  gem.authors       = ['Gabriel Evans']
  gem.email         = ['gabriel@codeconcoction.com']
  gem.description   = %q{Clean data importation from external resources.}
  gem.summary       = %q{Clean data importation from external resources.}
  gem.homepage      = 'https://github.com/tabeso/contraband'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
