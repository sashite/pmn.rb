# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "portable_move_notation"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "PMN (Portable Move Notation) support for the Ruby language."
  spec.description            = "A Ruby interface for serialization and deserialization of moves in PMN format. " \
                                "PMN is a rule-agnostic JSON-based format for representing moves in abstract strategy " \
                                "board games, providing a consistent representation system for game actions across " \
                                "both traditional and non-traditional board games."
  spec.homepage               = "https://github.com/sashite/pmn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pmn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pmn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pmn.rb",
    "source_code_uri"       => "https://github.com/sashite/pmn.rb",
    "specification_uri"     => "https://sashite.dev/documents/pmn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
