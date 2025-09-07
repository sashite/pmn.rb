# Pmn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pmn.rb?label=Version\&logo=github)](https://github.com/sashite/pmn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pmn.rb/main)
![Ruby](https://github.com/sashite/pmn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pmn.rb?label=License\&logo=github)](https://github.com/sashite/pmn.rb/raw/main/LICENSE.md)

> **PMN** (Portable Move Notation) implementation for the Ruby language.

## What is PMN?

PMN (Portable Move Notation) is a rule-agnostic, **array-based** format for describing the mechanical decomposition of moves in abstract strategy board games. PMN breaks down complex movements into sequences of atomic actions, revealing the underlying mechanics while remaining completely independent of specific game rules, validation logic, or gameplay concepts.

This gem implements the [PMN Specification v1.0.0](https://sashite.dev/specs/pmn/1.0.0/), providing a small, functional Ruby interface for working with mechanical move decomposition across any board game system.

## Installation

```ruby
# In your Gemfile
gem "sashite-pmn"
```

Or install manually:

```sh
gem install sashite-pmn
```

## Dependencies

PMN builds upon three foundational Sashité specifications:

```ruby
gem "sashite-cell"  # Multi-dimensional coordinate encoding
gem "sashite-hand"  # Reserve location notation
gem "sashite-qpi"   # Qualified Piece Identifier
```

## Usage

### Basic Operations

```ruby
require "sashite/pmn"

# Parse PMN arrays into move objects
move = Sashite::Pmn.parse(["e2", "e4", "C:P"])
move.valid?                                   # => true
move.actions                                  # => [#<Sashite::Pmn::Action ...>]
move.to_a                                     # => ["e2", "e4", "C:P"]

# Validate PMN arrays
Sashite::Pmn.valid?(["e2", "e4", "C:P"])     # => true
Sashite::Pmn.valid?(%w[e2 e4])               # => true (inferred piece)
Sashite::Pmn.valid?(["e2"])                  # => false (incomplete)

# Create moves programmatically
move = Sashite::Pmn.from_actions([
                                   Sashite::Pmn::Action.new("e2", "e4", "C:P")
                                 ])
```

### Action Decomposition

```ruby
# Simple move with explicit piece
move = Sashite::Pmn.parse(["e2", "e4", "C:P"])
action = move.actions.first
action.source                                 # => "e2"
action.destination                            # => "e4"
action.piece                                  # => "C:P"
action.piece_specified?                       # => true

# Move with inferred piece
move = Sashite::Pmn.parse(%w[e2 e4])
action = move.actions.first
action.piece                                  # => nil
action.piece_specified?                       # => false
action.inferred?                              # => true

# Pass moves (source == destination) are allowed
pass = Sashite::Pmn.parse(["e4", "e4", "C:P"])
pass.valid? # => true

# Reserve operations
drop = Sashite::Pmn.parse(["*", "e5", "S:P"]) # Drop from reserve
capture = Sashite::Pmn.parse(["e4", "*"])     # Capture to reserve (inferred piece)
```

### Complex Moves

```ruby
# Multi-action move (castling)
castling = Sashite::Pmn.parse([
                                "e1", "g1", "C:K",
                                "h1", "f1", "C:R"
                              ])
castling.compound?                            # => true
castling.actions.size                         # => 2

# En passant (explicit + inferred variant)
en_passant = Sashite::Pmn.parse([
                                  "e5", "f6", "C:P",
                                  "f5", "*", "c:p"
                                ])
Sashite::Pmn.parse(%w[e5 f6]).valid? # => true (context-dependent)
```

### Action Analysis

```ruby
action = move.actions.first

# Location predicates
action.board_to_board?                        # => true
action.from_reserve?                          # => false
action.to_reserve?                            # => false
action.drop?                                  # => false
action.capture?                               # => false
action.board_move?                            # => true

# Validation predicates
action.valid?                                 # => true
action.piece_valid?                           # => true or false depending on piece
```

### Move Analysis

```ruby
move = Sashite::Pmn.parse([
                            "e1", "g1", "C:K",
                            "h1", "f1", "C:R"
                          ])

# Structure analysis
move.simple?                                  # => false
move.compound?                                # => true
move.size                                     # => 2
move.empty?                                   # => false

# Drop/capture checks
move.has_drops?                               # => false
move.has_captures?                            # => false
move.board_moves.size                         # => 2

# Extract info
move.sources                                  # => ["e1", "h1"]
move.destinations                             # => ["g1", "f1"]
move.pieces                                   # => ["C:K", "C:R"]
move.has_inferred?                            # => false
```

### Error Handling

```ruby
# Invalid action built directly raises action-level errors
begin
  Sashite::Pmn::Action.new("invalid", "e4", "C:P")
rescue Sashite::Pmn::InvalidLocationError => e
  puts e.message
end

begin
  Sashite::Pmn::Action.new("e2", "e4", "InvalidPiece")
rescue Sashite::Pmn::InvalidPieceError => e
  puts e.message
end

# Parsing a move wraps action-level errors as InvalidMoveError
begin
  Sashite::Pmn.parse(["e2"])                  # Incomplete action
rescue Sashite::Pmn::InvalidMoveError => e
  puts e.message                              # => "Invalid PMN array length: 1", etc.
end
```

## API Reference

### Main Module Methods

* `Sashite::Pmn.parse(array)` — Parse a PMN array into a `Move` object.
* `Sashite::Pmn.valid?(array)` — Check if an array is valid PMN notation (non-raising).
* `Sashite::Pmn.from_actions(actions)` — Build a `Move` from `Action` objects.
* `Sashite::Pmn.valid_location?(location)` — Check if a location is valid (CELL or `"*"`).
* `Sashite::Pmn.valid_piece?(piece)` — Check if a piece is valid QPI.

### Move Class

#### Creation

* `Sashite::Pmn::Move.new(*elements)` — Create from PMN elements (variadic).
  *Note*: `Move.new(["e2","e4","C:P"])` is **not** accepted; pass individual arguments.
* `Sashite::Pmn::Move.from_actions(actions)` — Create from `Action` objects.

#### Validation & Data

* `#valid?` — Check overall validity.
* `#actions` — Ordered array of `Action` objects (frozen).
* `#pmn_array` — Original PMN elements (frozen).
* `#to_a` — Copy of the PMN elements.

#### Structure & Queries

* `#size` / `#length` — Number of actions.
* `#empty?` — No actions?
* `#simple?` — Exactly one action?
* `#compound?` — Multiple actions?
* `#first_action` / `#last_action` — Convenience accessors.
* `#has_drops?` / `#has_captures?` — Presence of drops/captures.
* `#board_moves` — Actions that are board-to-board.
* `#sources` / `#destinations` / `#pieces` — Unique lists.
* `#has_inferred?` — Any action with inferred piece?

### Action Class

#### Creation

* `Sashite::Pmn::Action.new(source, destination, piece = nil)`

#### Data & Conversion

* `#source`, `#destination`, `#piece`
* `#to_a` — `["src", "dst"]` or `["src", "dst", "piece"]`
* `#to_h` — `{ source:, destination:, piece: }` (piece omitted if `nil`)

#### Predicates

* `#inferred?`, `#piece_specified?`, `#piece_valid?`
* `#from_reserve?`, `#to_reserve?`
* `#reserve_to_board?` (drop), `#board_to_reserve?` (capture), `#board_to_board?`
* `#drop?` (alias), `#capture?` (alias), `#board_move?`
* `#valid?`

### Exceptions

* `Sashite::Pmn::Error` — Base error class
* `Sashite::Pmn::InvalidMoveError` — Invalid PMN sequence / parsing failure
* `Sashite::Pmn::InvalidActionError` — Invalid atomic action
* `Sashite::Pmn::InvalidLocationError` — Invalid location (not CELL or HAND)
* `Sashite::Pmn::InvalidPieceError` — Invalid piece (not QPI format)

## Format Specification (Summary)

### Structure

PMN moves are flat **arrays** containing action sequences:

```
[<element-1>, <element-2>, <element-3>, <element-4>, <element-5>, <element-6>, ...]
```

### Action Format

Each action consists of 2 or 3 consecutive elements:

```
[<source>, <destination>, <piece>?]
```

* **Source**: CELL coordinate or `"*"` (reserve)
* **Destination**: CELL coordinate or `"*"` (reserve)
* **Piece**: QPI string (optional; may be inferred)

### Array Length Rules

* Minimum: 2 elements (one action with inferred piece)
* Valid lengths: multiple of 3, **or** multiple of 3 plus 2

### Pass & Same-Location Actions

Actions where **source == destination** are allowed, enabling:

* Pass moves (turn-only or rule-driven)
* In-place transformations (e.g., promotions specified with QPI)

## Game Examples

### Western Chess

```ruby
# Pawn move
pawn_move = Sashite::Pmn.parse(["e2", "e4", "C:P"])

# Castling kingside
castling = Sashite::Pmn.parse([
                                "e1", "g1", "C:K",
                                "h1", "f1", "C:R"
                              ])

# En passant
en_passant = Sashite::Pmn.parse([
                                  "e5", "f6", "C:P",
                                  "f5", "*", "c:p"
                                ])

# Promotion
promotion = Sashite::Pmn.parse(["e7", "e8", "C:Q"])
```

### Japanese Shōgi

```ruby
# Drop piece from hand
drop = Sashite::Pmn.parse(["*", "e5", "S:P"])

# Capture and convert
capture = Sashite::Pmn.parse([
                               "a1", "*", "S:L",
                               "b2", "a1", "S:S"
                             ])

# Promotion
promotion = Sashite::Pmn.parse(["h8", "i8", "S:+S"])
```

### Chinese Xiangqi

```ruby
# General move
general_move = Sashite::Pmn.parse(["e1", "e2", "X:G"])

# Cannon capture (jumping)
cannon_capture = Sashite::Pmn.parse([
                                      "b3", "*", "x:s",
                                      "b1", "b9", "X:C"
                                    ])
```

## Advanced Usage

### Move Composition

```ruby
actions = []
actions << Sashite::Pmn::Action.new("e2", "e4", "C:P")
actions << Sashite::Pmn::Action.new("d7", "d5", "c:p")

move = Sashite::Pmn.from_actions(actions)
move.to_a # => ["e2", "e4", "C:P", "d7", "d5", "c:p"]
```

### Integration with Game Engines

```ruby
class GameEngine
  def execute_move(pmn_array)
    move = Sashite::Pmn.parse(pmn_array)

    move.actions.each do |action|
      if action.from_reserve?
        place_piece(action.destination, action.piece)
      elsif action.to_reserve?
        capture_piece(action.source)
      else
        move_piece(action.source, action.destination, action.piece)
      end
    end
  end

  # ...
end
```

## Design Properties

* **Rule-agnostic**: Independent of specific game mechanics
* **Mechanical decomposition**: Breaks complex moves into atomic actions
* **Array-based**: Simple, interoperable structure
* **Sequential execution**: Actions execute in array order
* **Piece inference**: Optional piece specification when context is clear
* **Universal applicability**: Works across board game systems
* **Functional design**: Immutable data structures
* **Dependency integration**: CELL, HAND, and QPI specs

## Mechanical Semantics (Recap)

1. **Source state change**:

   * CELL → becomes empty
   * HAND `"*"` → remove piece from reserve

2. **Destination state change**:

   * CELL → contains final piece
   * HAND `"*"` → add piece to reserve

3. **Piece transformation**: Final state (specified or inferred)

4. **Atomic commitment**: Each action applies atomically

## License

Available as open source under the [MIT License](https://github.com/sashite/pmn.rb/raw/main/LICENSE.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/sashite/pmn.rb](https://github.com/sashite/pmn.rb).

## See Also

* [PMN Specification v1.0.0](https://sashite.dev/specs/pmn/1.0.0/)
* [PMN Examples](https://sashite.dev/specs/pmn/1.0.0/examples/)
* [CELL Specification](https://sashite.dev/specs/cell/)
* [HAND Specification](https://sashite.dev/specs/hand/)
* [QPI Specification](https://sashite.dev/specs/qpi/)

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
