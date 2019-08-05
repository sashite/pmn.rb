# Portable Move Notation

A Ruby interface for data serialization in PMN format.

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

# Parse a PMN string

PortableMoveNotation.load('52,36,W:P.12,28,w:p.53,37,W:P') # => [[[52, 36, "W:P", nil]], [[12, 28, "w:p", nil]], [[53, 37, "W:P", nil]]]

# Emit some PMN

some_moves = [
  [[52, 36, 'W:P', nil]],
  [[12, 28, 'w:p', nil]],
  [[53, 37, 'W:P', nil]]
]

PortableMoveNotation.dump(*some_moves) # => '52,36,W:P.12,28,w:p.53,37,W:P'
```

### Other examples

#### Castling on kingside

```ruby
PortableMoveNotation.dump(*[[[60, 62, "W:-K", nil], [63, 61, "W:R", nil]]]) # => "60,62,W:-K;63,61,W:R"
PortableMoveNotation.load('60,62,W:-K;63,61,W:R') # => [[[60, 62, "W:-K", nil], [63, 61, "W:R", nil]]]
```

#### Promoting a chess pawn into a knight

```ruby
PortableMoveNotation.dump(*[[[12, 4, "W:P", "W:N"]]]) # => "12,4,W:P,W:N"
PortableMoveNotation.load('12,4,W:P,W:N') # => [[[12, 4, "W:P", "W:N"]]]
```

#### Promoting a shogi pawn

```ruby
PortableMoveNotation.dump(*[[[33, 24, "S:P", "S:+P"]]]) # => "33,24,S:P,S:+P"
PortableMoveNotation.load('33,24,S:P,S:+P') # => [[[33, 24, "S:P", "S:+P"]]]
```

#### Dropping a shogi pawn

```ruby
PortableMoveNotation.dump(*[[[nil, 42, "S:P", nil]]]) # => "*,42,S:P"
PortableMoveNotation.load('*,42,S:P') # => [[[nil, 42, "S:P", nil]]]
```

#### Capturing a white chess pawn en passant

```ruby
PortableMoveNotation.dump(*[[[48, 32, "W:P", nil]], [[33, 32, "w:p", nil], [32, 40, "w:p", nil]]]) # => "48,32,W:P.33,32,w:p;32,40,w:p"
PortableMoveNotation.load('48,32,W:P.33,32,w:p;32,40,w:p') # => [[[48, 32, "W:P", nil]], [[33, 32, "w:p", nil], [32, 40, "w:p", nil]]]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sashite/portable_move_notation.rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PortableMoveNotation project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sashite/portable_move_notation.rb/blob/master/CODE_OF_CONDUCT.md).
