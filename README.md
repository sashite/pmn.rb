# Pmn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pmn.rb?label=Version&logo=github)](https://github.com/sashite/pmn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pmn.rb/main)
![Ruby](https://github.com/sashite/pmn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pmn.rb?label=License&logo=github)](https://github.com/sashite/pmn.rb/raw/main/LICENSE.md)

> **PMN** (Portable Move Notation) support for the Ruby language.

## What is PMN?

PMN (Portable Move Notation) is a rule-agnostic JSON-based format for representing moves in abstract strategy board games. It provides a consistent representation system for game actions across both traditional and non-traditional board games, supporting arbitrary dimensions and hybrid configurations while maintaining neutrality toward game-specific rules.

This gem implements the [PMN Specification v1.0.0](https://sashite.dev/documents/pmn/1.0.0/), providing a Ruby interface for:
- Serializing game actions to PMN format
- Parsing PMN data into structured Ruby objects
- Validating PMN data according to the specification

## Installation

Add this line to your application's Gemfile:

```ruby
gem "portable_move_notation"
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install portable_move_notation
```

## PMN Format

A PMN record consists of an array of one or more action items, where each action item is a JSON object with precisely defined fields:

```json
[
  {
    "src_square": <source-coordinate-or-null>,
    "dst_square": <destination-coordinate>,
    "piece_name": <piece-identifier>,
    "piece_hand": <captured-piece-identifier-or-null>
  },
  ...
]
```

## Basic Usage

### Working with PMN Actions

Create individual actions representing piece movement:

```ruby
require "portable_move_notation"

# Create an action representing a chess pawn moving from e2 (52) to e4 (36)
pawn_move = PortableMoveNotation::Action.new(
  src_square: 52,
  dst_square: 36,
  piece_name: "P",
  piece_hand: nil
)

# Generate the PMN representation
pawn_move.to_h
# => {"src_square"=>52, "dst_square"=>36, "piece_name"=>"P", "piece_hand"=>nil}
```

### Working with PMN Moves

Create compound moves consisting of multiple actions:

```ruby
require "portable_move_notation"
require "json"

# Create actions for a kingside castle in chess:
king_action = PortableMoveNotation::Action.new(
  src_square: 60,
  dst_square: 62,
  piece_name: "K",
  piece_hand: nil
)

rook_action = PortableMoveNotation::Action.new(
  src_square: 63,
  dst_square: 61,
  piece_name: "R",
  piece_hand: nil
)

# Create a complete move (notice the splat operator for multiple actions)
castling_move = PortableMoveNotation::Move.new(king_action, rook_action)

# Generate JSON representation
json_string = castling_move.to_json
puts json_string
# => [{"src_square":60,"dst_square":62,"piece_name":"K","piece_hand":null},{"src_square":63,"dst_square":61,"piece_name":"R","piece_hand":null}]
```

### Parsing PMN Data

Parse PMN data from JSON:

```ruby
require "portable_move_notation"

# Parse a PMN string (representing a shogi pawn promotion)
pmn_string = '[{"src_square":27,"dst_square":18,"piece_name":"+P","piece_hand":null}]'
move = PortableMoveNotation::Move.from_json(pmn_string)

# Access components of the move
puts move.actions.first.piece_name  # => +P
puts move.actions.first.src_square  # => 27
puts move.actions.first.dst_square  # => 18
```

### Validation

Validate PMN data for conformance to the specification:

```ruby
require "portable_move_notation"
require "json"

# Valid PMN data
valid_data = JSON.parse('[{"dst_square":27,"piece_name":"p"}]')
PortableMoveNotation::Move.valid?(valid_data) # => true

# Invalid PMN data (missing required field)
invalid_data = JSON.parse('[{"src_square":27}]')
PortableMoveNotation::Move.valid?(invalid_data) # => false
```

## Examples of Common Chess and Shogi Actions

### Chess: Pawn Move

A white pawn moves from e2 (52) to e4 (36):

```ruby
action = PortableMoveNotation::Action.new(
  src_square: 52,
  dst_square: 36,
  piece_name: "P",
  piece_hand: nil
)

move = PortableMoveNotation::Move.new(action)
move.to_json
# => [{"src_square":52,"dst_square":36,"piece_name":"P","piece_hand":null}]
```

### Chess: Castling Kingside

White castles kingside:

```ruby
king_action = PortableMoveNotation::Action.new(
  src_square: 60,
  dst_square: 62,
  piece_name: "K",
  piece_hand: nil
)

rook_action = PortableMoveNotation::Action.new(
  src_square: 63,
  dst_square: 61,
  piece_name: "R",
  piece_hand: nil
)

castling_move = PortableMoveNotation::Move.new(king_action, rook_action)
castling_move.to_json
# => [{"src_square":60,"dst_square":62,"piece_name":"K","piece_hand":null},{"src_square":63,"dst_square":61,"piece_name":"R","piece_hand":null}]
```

### Shogi: Dropping a Pawn

A pawn is dropped onto square 27 from the player's hand:

```ruby
action = PortableMoveNotation::Action.new(
  src_square: nil,
  dst_square: 27,
  piece_name: "p",
  piece_hand: nil
)

move = PortableMoveNotation::Move.new(action)
move.to_json
# => [{"src_square":null,"dst_square":27,"piece_name":"p","piece_hand":null}]
```

### Shogi: Piece Capture and Promotion

A bishop (B) captures a promoted pawn (+p) at square 27 and becomes available for dropping:

```ruby
action = PortableMoveNotation::Action.new(
  src_square: 36,
  dst_square: 27,
  piece_name: "B",
  piece_hand: "P"
)

move = PortableMoveNotation::Move.new(action)
move.to_json
# => [{"src_square":36,"dst_square":27,"piece_name":"B","piece_hand":"P"}]
```

### Chess: En Passant Capture

After white plays a double pawn move from e2 (52) to e4 (36), black captures en passant:

```ruby
# First create the initial pawn move
initial_move = PortableMoveNotation::Action.new(
  src_square: 52,
  dst_square: 36,
  piece_name: "P",
  piece_hand: nil
)

# Then create the en passant capture (represented as two actions)
capture_action1 = PortableMoveNotation::Action.new(
  src_square: 35,
  dst_square: 36,
  piece_name: "p",
  piece_hand: nil
)

capture_action2 = PortableMoveNotation::Action.new(
  src_square: 36,
  dst_square: 44,
  piece_name: "p",
  piece_hand: null
)

en_passant_move = PortableMoveNotation::Move.new(capture_action1, capture_action2)
en_passant_move.to_json
# => [{"src_square":35,"dst_square":36,"piece_name":"p","piece_hand":null},{"src_square":36,"dst_square":44,"piece_name":"p","piece_hand":null}]
```

## Properties of PMN

* **Rule-agnostic**: PMN does not encode game-specific legality, validity, or conditions.
* **Arbitrary-dimensional**: PMN supports arbitrary board configurations through a unified coordinate system.
* **Game-neutral**: PMN provides a common structure applicable to all abstract strategy games with piece movement.
* **Hybrid-supporting**: PMN facilitates hybrid or cross-game scenarios where multiple game types coexist.
* **Deterministic**: PMN is designed for deterministic representation of all possible state transitions in piece-placement games.

## Related Specifications

PMN is part of a family of specifications for representing abstract strategy board games:

- [Piece Name Notation (PNN)](https://sashite.dev/documents/pnn/1.0.0/) - Defines the format for representing individual pieces.
- [Forsyth-Edwards Enhanced Notation (FEEN)](https://sashite.dev/documents/feen/1.0.0/) - Defines the format for representing board positions.

## Documentation

- [Official PMN Specification](https://sashite.dev/documents/pmn/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/pmn.rb/main)

## License

The [gem](https://rubygems.org/gems/portable_move_notation) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
