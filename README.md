# Pmn.rb

[![Gem Version](https://img.shields.io/gem/v/portable_move_notation.svg?logo=rubygems)](https://rubygems.org/gems/portable_move_notation)
[![GitHub Version](https://img.shields.io/github/v/tag/sashite/pmn.rb?label=GitHub\&logo=github)](https://github.com/sashite/pmn.rb/tags)
[![Build](https://github.com/sashite/pmn.rb/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/sashite/pmn.rb/actions/workflows/main.yml)
[![Codecov](https://img.shields.io/codecov/c/github/sashite/pmn.rb?logo=codecov)](https://codecov.io/gh/sashite/pmn.rb)
[![YARD Docs](https://img.shields.io/badge/YARD-Documentation-blue.svg?logo=ruby)](https://rubydoc.info/github/sashite/pmn.rb/main)
[![License](https://img.shields.io/github/license/sashite/pmn.rb?label=License)](https://github.com/sashite/pmn.rb/raw/main/LICENSE.md)

> Parse, validate and emit [PMN v1.0.0](https://sashite.dev/documents/pmn/1.0.0/) — the rule‑agnostic *Portable Move Notation* — in pure Ruby.

---

## Why PMN?

PMN expresses **state‑changing actions** without embedding game rules. Whether you are writing a Chess engine, a Shogi server, or a hybrid variant, PMN gives you a deterministic, game‑neutral core that travels well across languages and databases.

---

## Installation

Add to your **Gemfile**:

```ruby
# Gemfile
gem "portable_move_notation"
```

then:

```bash
bundle install
```

Or grab it directly:

```bash
gem install portable_move_notation
```

Require it in your code:

```ruby
require "portable_move_notation" # provides the PortableMoveNotation namespace
```

---

## Quick Start

Dump a single action (dropping a Shogi pawn on square 27):

```ruby
require "portable_move_notation"

move = PortableMoveNotation::Move.new(
  PortableMoveNotation::Action.new(
    src_square: nil,
    dst_square: 27,
    piece_name: "p",
    piece_hand: nil
  )
)

puts move.to_json
# Output: A JSON array with the move data
```

Parse it back:

```ruby
restored = PortableMoveNotation::Move.from_json(move.to_json)
puts restored.actions.first.dst_square # => 27
```

---

## Advanced Examples

### Chess · Kingside Castling

```ruby
require "portable_move_notation"

king = PortableMoveNotation::Action.new(
  src_square: 60, dst_square: 62, piece_name: "K", piece_hand: nil
)
rook = PortableMoveNotation::Action.new(
  src_square: 63, dst_square: 61, piece_name: "R", piece_hand: nil
)

puts PortableMoveNotation::Move.new(king, rook).to_json
# Output: A JSON array containing both king and rook move data
```

---

## Validation

`PortableMoveNotation::Move.valid?(data)` checks **shape compliance** against the spec — not game legality:

```ruby
require "portable_move_notation"
require "json"

# Parse a simple JSON move with a pawn at square 27
data = JSON.parse('[{ "dst_square" => 27, "piece_name" => "p" }]')
puts PortableMoveNotation::Move.valid?(data) # => true
```

You can also validate single actions:

```ruby
# Check if an individual action is valid
action_data = { "dst_square" => 12, "piece_name" => "P" }
puts PortableMoveNotation::Action.valid?(action_data) # => true
```

---

## License

The [gem](https://rubygems.org/gems/portable_move_notation) is released under the [MIT License](https://opensource.org/licenses/MIT).

---

## About Sashité

*Celebrating the beauty of Chinese, Japanese, and Western chess cultures.*
Find more projects & research at **[sashite.com](https://sashite.com/)**.
