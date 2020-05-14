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

PortableMoveNotation.load('52,36,C:P.12,28,c:p.53,37,C:P') # => [[[52, 36, 'C:P', nil]], [[12, 28, 'c:p', nil]], [[53, 37, 'C:P', nil]]]

# Emit some PMN

some_moves = [
  [[52, 36, 'C:P', nil]],
  [[12, 28, 'c:p', nil]],
  [[53, 37, 'C:P', nil]]
]

PortableMoveNotation.dump(*some_moves) # => '52,36,C:P.12,28,c:p.53,37,C:P'
```

### Other examples

#### Castling on kingside

```ruby
PortableMoveNotation.load('60,62,C:-K;63,61,C:R') # => [[[60, 62, 'C:-K', nil], [63, 61, 'C:R', nil]]]
PortableMoveNotation.dump(*[[[60, 62, 'C:-K', nil], [63, 61, 'C:R', nil]]]) # => '60,62,C:-K;63,61,C:R'
```

#### Promoting a chess pawn into a knight

```ruby
PortableMoveNotation.load('12,4,C:P,C:N') # => [[[12, 4, 'C:P', 'C:N']]]
PortableMoveNotation.dump(*[[[12, 4, 'C:P', 'C:N']]]) # => '12,4,C:P,C:N'
```

#### Promoting a shogi pawn

```ruby
PortableMoveNotation.load('33,24,S:P,S:+P') # => [[[33, 24, 'S:P', 'S:+P']]]
PortableMoveNotation.dump(*[[[33, 24, 'S:P', 'S:+P']]]) # => '33,24,S:P,S:+P'
```

#### Dropping a shogi pawn

```ruby
PortableMoveNotation.load('*,42,S:P') # => [[[nil, 42, 'S:P', nil]]]
PortableMoveNotation.dump(*[[[nil, 42, 'S:P', nil]]]) # => '*,42,S:P'
```

#### Capturing a white chess pawn en passant

```ruby
PortableMoveNotation.load('48,32,C:P.33,32,c:p;32,40,c:p') # => [[[48, 32, 'C:P', nil]], [[33, 32, 'c:p', nil], [32, 40, 'c:p', nil]]]
PortableMoveNotation.dump(*[[[48, 32, 'C:P', nil]], [[33, 32, 'c:p', nil], [32, 40, 'c:p', nil]]]) # => '48,32,C:P.33,32,c:p;32,40,c:p'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sashite/portable_move_notation.rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PortableMoveNotation project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sashite/portable_move_notation.rb/blob/master/CODE_OF_CONDUCT.md).

## About Sashite

The `portable_move_notation` gem is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
