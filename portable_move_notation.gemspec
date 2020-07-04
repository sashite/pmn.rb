# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name         = 'portable_move_notation'
  spec.version      = File.read('VERSION.semver')
  spec.author       = 'Cyril Kato'
  spec.email        = 'contact@cyril.email'
  spec.description  = 'A Ruby interface for data serialization in PMN (Portable Move Notation) format.'
  spec.summary      = 'Data serialization in PMN format.'
  spec.homepage     = 'https://developer.sashite.com/specs/portable-move-notation'
  spec.license      = 'MIT'
  spec.files        = Dir['LICENSE.md', 'README.md', 'lib/**/*']

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/sashite/pmn.rb/issues',
    'documentation_uri' => 'https://rubydoc.info/gems/portable_move_notation/index',
    'source_code_uri' => 'https://github.com/sashite/pmn.rb'
  }

  spec.add_dependency 'sashite-pan', '~> 1.1.0'

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-thread_safety'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
