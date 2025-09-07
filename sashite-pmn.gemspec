# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-pmn"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "PMN (Portable Move Notation) implementation for Ruby with functional decomposition"

  spec.description = <<~DESC
    PMN (Portable Move Notation) provides a rule-agnostic, JSON-based format for describing
    the mechanical decomposition of moves in abstract strategy board games. This gem implements
    the PMN Specification v1.0.0 with a functional Ruby interface, breaking down complex movements
    into sequences of atomic actions while remaining completely independent of specific game rules.
    PMN reveals the underlying mechanics of any board game move through sequential action
    decomposition, supporting both explicit and inferred piece specifications. Built on CELL
    (coordinate encoding), HAND (reserve notation), and QPI (piece identification) specifications,
    it enables universal move representation across chess variants, shōgi, xiangqi, and any
    abstract strategy game. Perfect for game engines, move validators, and board game analysis tools.
  DESC

  spec.homepage               = "https://github.com/sashite/pmn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  # Runtime dependencies on foundational specifications
  spec.add_dependency "sashite-cell", "~> 2.0"
  spec.add_dependency "sashite-hand", "~> 1.0"
  spec.add_dependency "sashite-qpi", "~> 1.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pmn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pmn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pmn.rb",
    "source_code_uri"       => "https://github.com/sashite/pmn.rb",
    "specification_uri"     => "https://sashite.dev/specs/pmn/1.0.0/",
    "wiki_uri"              => "https://sashite.dev/specs/pmn/1.0.0/examples/",
    "funding_uri"           => "https://github.com/sponsors/sashite",
    "rubygems_mfa_required" => "true"
  }
end
