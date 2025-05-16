# frozen_string_literal: true

require_relative "../../lib/portable_move_notation"

# Simple tests for PortableMoveNotation::Action

puts "Testing PortableMoveNotation::Action..."

# Test basic Action instantiation
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P",
  piece_hand: nil
)
raise "Expected Action instance" unless action.is_a?(PortableMoveNotation::Action)
raise "Expected src_square to be 'e2', got #{action.src_square}" unless action.src_square == "e2"
raise "Expected dst_square to be 'e4', got #{action.dst_square}" unless action.dst_square == "e4"
raise "Expected piece_name to be 'P', got #{action.piece_name}" unless action.piece_name == "P"
raise "Expected piece_hand to be nil, got #{action.piece_hand}" unless action.piece_hand.nil?
raise "Expected action to be frozen" unless action.frozen?

# Test piece drop (null src_square)
drop_action = PortableMoveNotation::Action.new(
  src_square: nil,
  dst_square: "27",
  piece_name: "p",
  piece_hand: nil
)
raise "Expected src_square to be nil, got #{drop_action.src_square}" unless drop_action.src_square.nil?
raise "Expected dst_square to be '27', got #{drop_action.dst_square}" unless drop_action.dst_square == "27"
raise "Expected piece_name to be 'p', got #{drop_action.piece_name}" unless drop_action.piece_name == "p"

# Test piece capture with piece becoming available for dropping
capture_action = PortableMoveNotation::Action.new(
  src_square: "33",
  dst_square: "24",
  piece_name: "B",
  piece_hand: "P"
)
raise "Expected piece_hand to be 'P', got #{capture_action.piece_hand}" unless capture_action.piece_hand == "P"

# Test promoted piece
promote_action = PortableMoveNotation::Action.new(
  src_square: "27",
  dst_square: "18",
  piece_name: "+P",
  piece_hand: nil
)
raise "Expected piece_name to be '+P', got #{promote_action.piece_name}" unless promote_action.piece_name == "+P"

# Test validation errors - invalid src_square (empty string)
begin
  PortableMoveNotation::Action.new(
    src_square: "",
    dst_square: "e4",
    piece_name: "P"
  )
  raise "Expected ArgumentError for empty src_square, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Square must be a non-empty string")
end

# Test validation errors - invalid src_square (non-string)
begin
  PortableMoveNotation::Action.new(
    src_square: 42,
    dst_square: "e4",
    piece_name: "P"
  )
  raise "Expected ArgumentError for non-string src_square, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Square must be a non-empty string")
end

# Test validation errors - missing dst_square
begin
  PortableMoveNotation::Action.new(
    src_square: "e2",
    piece_name: "P"
  )
  raise "Expected ArgumentError for missing dst_square, but none was raised"
rescue ArgumentError
  # This is the expected error
end

# Test validation errors - invalid dst_square (empty string)
begin
  PortableMoveNotation::Action.new(
    src_square: "e2",
    dst_square: "",
    piece_name: "P"
  )
  raise "Expected ArgumentError for empty dst_square, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Square must be a non-empty string")
end

# Test validation errors - missing piece_name
begin
  PortableMoveNotation::Action.new(
    src_square: "e2",
    dst_square: "e4"
  )
  raise "Expected ArgumentError for missing piece_name, but none was raised"
rescue ArgumentError
  # This is the expected error
end

# Test validation errors - invalid piece_name format
begin
  PortableMoveNotation::Action.new(
    src_square: "e2",
    dst_square: "e4",
    piece_name: "PP" # Invalid: two letters
  )
  raise "Expected ArgumentError for invalid piece_name, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece_name format")
end

# Test validation errors - invalid piece_hand format
begin
  PortableMoveNotation::Action.new(
    src_square: "e2",
    dst_square: "e4",
    piece_name: "P",
    piece_hand: "+P" # Invalid: should be just 'P' without modifier
  )
  raise "Expected ArgumentError for invalid piece_hand, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece_hand format")
end

# Test valid? class method with valid data
valid_data = {
  "src_square" => "e2",
  "dst_square" => "e4",
  "piece_name" => "P",
  "piece_hand" => nil
}
result = PortableMoveNotation::Action.valid?(valid_data)
raise "Expected true for valid data, got #{result}" unless result == true

# Test valid? class method with invalid data (missing required field)
invalid_data = {
  "src_square" => "e2"
  # Missing dst_square and piece_name
}
result = PortableMoveNotation::Action.valid?(invalid_data)
raise "Expected false for invalid data, got #{result}" unless result == false

# Test valid? class method with non-hash input
result = PortableMoveNotation::Action.valid?("not a hash")
raise "Expected false for non-hash input, got #{result}" unless result == false

# Test from_params class method
params = {
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P",
  piece_hand: nil
}
action = PortableMoveNotation::Action.from_params(**params)
raise "Expected Action instance" unless action.is_a?(PortableMoveNotation::Action)
raise "Expected src_square to be 'e2', got #{action.src_square}" unless action.src_square == "e2"
raise "Expected dst_square to be 'e4', got #{action.dst_square}" unless action.dst_square == "e4"
raise "Expected piece_name to be 'P', got #{action.piece_name}" unless action.piece_name == "P"
raise "Expected piece_hand to be nil, got #{action.piece_hand}" unless action.piece_hand.nil?

# Test from_params with missing required parameter
begin
  PortableMoveNotation::Action.from_params(src_square: "e2") # Missing dst_square and piece_name
  raise "Expected KeyError, but none was raised"
rescue KeyError
  # This is the expected error
end

# Test to_params method
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P",
  piece_hand: "R"
)
params = action.to_params
expected = {
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P",
  piece_hand: "R"
}
raise "Expected #{expected}, got #{params}" unless params == expected

# Test to_params with nil values (should be excluded)
action = PortableMoveNotation::Action.new(
  src_square: nil,
  dst_square: "e4",
  piece_name: "P",
  piece_hand: nil
)
params = action.to_params
expected = {
  dst_square: "e4",
  piece_name: "P"
}
raise "Expected #{expected}, got #{params}" unless params == expected

# Test to_h method
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P",
  piece_hand: nil
)
hash = action.to_h
expected = {
  "src_square" => "e2",
  "dst_square" => "e4",
  "piece_name" => "P",
  "piece_hand" => nil
}
raise "Expected #{expected}, got #{hash}" unless hash == expected

# Test with various valid piece_name formats
# Basic piece
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P"
)
raise "Expected piece_name 'P', got #{action.piece_name}" unless action.piece_name == "P"

# Piece with prefix
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "+P"
)
raise "Expected piece_name '+P', got #{action.piece_name}" unless action.piece_name == "+P"

# Piece with suffix
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P'"
)
raise "Expected piece_name 'P'', got #{action.piece_name}" unless action.piece_name == "P'"

# Piece with both prefix and suffix
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "+P'"
)
raise "Expected piece_name '+P'', got #{action.piece_name}" unless action.piece_name == "+P'"

# Lowercase piece
action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "p"
)
raise "Expected piece_name 'p', got #{action.piece_name}" unless action.piece_name == "p"

# Test invalid suffix (old format)
begin
  PortableMoveNotation::Action.new(
    src_square: "e2",
    dst_square: "e4",
    piece_name: "P=" # No longer valid
  )
  raise "Expected ArgumentError for invalid suffix, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece_name format")
end

puts "All tests passed!"
