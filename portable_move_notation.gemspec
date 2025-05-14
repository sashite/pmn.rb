# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "portable_move_notation"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "A pure Ruby implementation of Portable Move Notation (PMN) for abstract strategy board games."
  spec.description            = "Portable Move Notation (PMN) is a rule-agnostic, JSON-based format for representing moves " \
                                "in abstract strategy board games. This gem provides a consistent Ruby interface for " \
                                "serializing, deserializing, and validating actions across Chess, Shogi, Xiangqi, and " \
                                "other traditional or non-traditional variants, focusing on deterministic state " \
                                "transformations independent of game-specific rules."
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
