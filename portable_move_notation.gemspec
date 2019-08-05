# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'portable_move_notation'
  spec.version       = File.read('VERSION.semver')
  spec.authors       = ['Cyril Kato']
  spec.email         = ['contact@cyril.email']
  spec.description   = 'A Ruby interface for data serialization in PMN format.'
  spec.summary       = 'Data serialization in PMN format.'
  spec.homepage      = 'https://github.com/sashite/portable_move_notation.rb'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rubocop', '~> 0.72'
  spec.add_development_dependency 'rubocop-performance', '~> 1.4'
  spec.add_development_dependency 'simplecov', '~> 0.17'
  spec.add_development_dependency 'yard', '~> 0.9'
end
