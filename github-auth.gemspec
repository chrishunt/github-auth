# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github/auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'github-auth'
  spec.version       = GitHub::Auth::VERSION
  spec.authors       = ['Chris Hunt']
  spec.email         = ['c@chrishunt.co']
  spec.description   = %q{SSH key management for GitHub users}
  spec.summary       = %q{SSH key management for GitHub users}
  spec.homepage      = 'https://github.com/chrishunt/github-auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',        '~> 1.16.4'
  spec.add_development_dependency 'cane',           '~> 3.0.0'
  spec.add_development_dependency 'cane-hashcheck', '~> 1.2.0'
  spec.add_development_dependency 'mute',           '~> 1.1.0'
  spec.add_development_dependency 'pry',            '~> 0.10.4'
  spec.add_development_dependency 'rake',           '~> 11.3.0'
  spec.add_development_dependency 'rspec',          '~> 3.8.0'
  spec.add_development_dependency 'sinatra',        '~> 1.4.8'
  spec.add_development_dependency 'thin',           '~> 1.7.2'

  spec.add_runtime_dependency 'faraday', '~> 0.15.2'
  spec.add_runtime_dependency 'thor',    '~> 0.20.0'
end
