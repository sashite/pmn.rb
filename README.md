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

PMN expresses **state‑changing actions** using a simple, deterministic array format without embedding game rules. Whether you are writing a Chess engine, a Shogi server, or a hybrid variant, PMN gives you a compact, game‑neutral core that travels well across languages and databases.

Each action is represented as a 4-element array: `[source_square, destination_square, piece_name, captured_piece]`.

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

Create a simple pawn move (e2 to e4):

```ruby
require "portable_move_notation"

# Create an action using the array format: [source, destination, piece, captured]
action = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
move = PortableMoveNotation::Move.new(action)

puts move.to_json
# Output: [["e2","e4","P",null]]
```

Parse it back:

```ruby
restored = PortableMoveNotation::Move.from_json(move.to_json)
restored.actions.first.dst_square # => "e4"
```

---

## Advanced Examples

### Chess · Kingside Castling

```ruby
require "portable_move_notation"

# Two separate actions for castling
king_move = PortableMoveNotation::Action.new("e1", "g1", "K", nil)
rook_move = PortableMoveNotation::Action.new("h1", "f1", "R", nil)

castling = PortableMoveNotation::Move.new(king_move, rook_move)
puts castling.to_json
# Output: [["e1","g1","K",null],["h1","f1","R",null]]
```

### Shogi · Drop from Hand

```ruby
# Drop a pawn onto square 27 (source is nil for drops)
drop = PortableMoveNotation::Action.new(nil, "27", "p", nil)
move = PortableMoveNotation::Move.new(drop)

puts move.to_json
# Output: [[null,"27","p",null]]
```

### Chess · En Passant Capture

```ruby
# En passant involves removing the captured pawn from its square
capture_move = PortableMoveNotation::Action.new("d4", "e3", "p", nil)
remove_pawn = PortableMoveNotation::Action.new("e4", "e4", nil, "P")

en_passant = PortableMoveNotation::Move.new(capture_move, remove_pawn)
puts en_passant.to_json
# Output: [["d4","e3","p",null],["e4","e4",null,"P"]]
```

### Shogi · Promotion with Capture

```ruby
# Bishop captures a promoted pawn and promotes itself
promote_capture = PortableMoveNotation::Action.new("36", "27", "+B", "P")
move = PortableMoveNotation::Move.new(promote_capture)

puts move.to_json
# Output: [["36","27","+B","P"]]
```

---

## Core Concepts

### Action Format

Each action is a 4-element array representing:

1. **Source square** (`String` or `nil`) - Where the piece comes from (`nil` for drops)
2. **Destination square** (`String`) - Where the piece ends up (required)
3. **Piece name** (`String`) - What sits on the destination after the action
4. **Captured piece** (`String` or `nil`) - What enters the mover's reserve

### Semantic Side Effects

Every action produces deterministic changes:

- **Board Removal**: Source square becomes empty (if not `nil`)
- **Board Placement**: Destination square contains the piece
- **Hand Addition**: Captured piece enters the mover's reserve (if not `nil`)
- **Hand Removal**: For drops (`source` is `nil`), remove piece from hand

---

## Validation

The library validates PMN structure but **not game legality**:

```ruby
require "portable_move_notation"
require "json"

# Valid PMN structure
pmn_data = [["e2", "e4", "P", nil]]
puts PortableMoveNotation::Move.valid?(pmn_data) # => true

# Parse and validate
move = PortableMoveNotation::Move.from_pmn(pmn_data)
puts move.actions.size # => 1
```

Individual action validation:

```ruby
# Check array format compliance
action_array = ["e2", "e4", "P", nil]
puts PortableMoveNotation::Action.valid?(action_array) # => true
```

---

## Piece Notation

PMN is agnostic to piece notation systems. This implementation supports any UTF-8 string for piece identifiers:

- **Traditional**: `"K"`, `"Q"`, `"R"`, `"B"`, `"N"`, `"P"`
- **Descriptive**: `"WhiteKing"`, `"BlackQueen"`
- **Shogi**: `"p"`, `"+P"`, `"B'"`
- **Custom**: `"MagicDragon_powered"`, `"42"`

---

## JSON Schema Compliance

All output conforms to the official PMN JSON Schema:

- **Schema URL**: [`https://sashite.dev/schemas/pmn/1.0.0/schema.json`](https://sashite.dev/schemas/pmn/1.0.0/schema.json)
- **Format**: Array of 4-element arrays
- **Types**: `[string|null, string, string, string|null]`

---

## Implementation Notes

### Performance

- Actions are immutable (frozen) after creation
- Moves are lightweight containers for action arrays
- JSON serialization follows the official schema exactly

### Thread Safety

All objects are immutable after construction, making them thread-safe by design.

### Error Handling

- `ArgumentError` for malformed data during construction
- `JSON::ParserError` for invalid JSON input
- `KeyError` for missing required elements

---

## Related Specifications

- [Portable Move Notation (PMN)](https://sashite.dev/documents/pmn/1.0.0/) — This specification
- [Piece Name Notation (PNN)](https://sashite.dev/documents/pnn/1.0.0/) — Piece identifier format
- [General Actor Notation (GAN)](https://sashite.dev/documents/gan/1.0.0/) — Game-qualified pieces
- [Forsyth‑Edwards Enhanced Notation (FEEN)](https://sashite.dev/documents/feen/1.0.0/) — Static positions

---

## License

The [gem](https://rubygems.org/gems/portable_move_notation) is released under the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
