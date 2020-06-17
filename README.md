# Portable Move Notation

A Ruby interface for data serialization in [PMN](https://developer.sashite.com/specs/portable-move-notation) format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'portable_move_notation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install portable_move_notation

## Usage

Working with PMN can be very simple, for example:

```ruby
require 'portable_move_notation'

# Emit a PMN string

some_moves = [
  [52, 36, '♙', nil],
  [12, 28, '♟', nil],
  [53, 37, '♙', nil]
]

PortableMoveNotation.dump(*some_moves) # => "52,36,♙.12,28,♟.53,37,♙"

# Parse a PMN string

PortableMoveNotation.parse('52,36,♙.12,28,♟.53,37,♙') # => [[52, 36, "♙", nil], [12, 28, "♟", nil], [53, 37, "♙", nil]]
```

## Examples

```ruby
# Black castles on king-side

PortableMoveNotation.dump([60, 62, '♔', nil, 63, 61, '♖', nil]) # => "60,62,♔;63,61,♖"
PortableMoveNotation.parse('60,62,♔;63,61,♖') # => [[60, 62, "♔", nil, 63, 61, "♖", nil]]

# Promoting a chess pawn into a knight

PortableMoveNotation.dump([12, 4, '♘', nil]) # => "12,4,♘"
PortableMoveNotation.parse('12,4,♘') # => [[12, 4, "♘", nil]]

# Capturing a rook and promoting a shogi pawn

PortableMoveNotation.dump([33, 24, '+P', 'R']) # => "33,24,+P,R"
PortableMoveNotation.parse('33,24,+P,R') # => [[33, 24, "+P", "R"]]

# Dropping a shogi pawn

PortableMoveNotation.dump([nil, 42, 'P', nil]) # => "*,42,P"
PortableMoveNotation.parse('*,42,P') # => [[nil, 42, "P", nil]]

# Capturing a white chess pawn en passant

PortableMoveNotation.dump([48, 32, '♙', nil], [33, 32, '♟', nil, 32, 40, '♟', nil]) # => "48,32,♙.33,32,♟;32,40,♟"
PortableMoveNotation.parse('48,32,♙.33,32,♟;32,40,♟') # => [[48, 32, "♙", nil], [33, 32, "♟", nil, 32, 40, "♟", nil]]
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

The `portable_move_notation` gem is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
