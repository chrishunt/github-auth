# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github/auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'github-auth'
  spec.version       = Github::Auth::VERSION
  spec.authors       = ['Chris Hunt']
  spec.email         = ['c@chrishunt.co']
  spec.description   = %q{SSH key management for Github users}
  spec.summary       = %q{SSH key management for Github users}
  spec.homepage      = 'https://github.com/chrishunt/github-auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'cane', '~> 2.6.0'
  spec.add_development_dependency 'cane-hashcheck', '~> 1.2.0'
  spec.add_development_dependency 'coveralls', '~> 0.7.0'
  spec.add_development_dependency 'pry', '~> 0.9.12'
  spec.add_development_dependency 'rake', '~> 10.1.1'
  spec.add_development_dependency 'rspec', '~> 2.14.1'
  spec.add_development_dependency 'sinatra', '~> 1.4.3'
  spec.add_development_dependency 'thin', '~> 1.5.1'

  spec.add_runtime_dependency 'httparty', '~> 0.11.0'
  spec.add_runtime_dependency 'thor', '~> 0.18'
end
