# frozen_string_literal: true

require_relative "../../lib/portable_move_notation"

# Tests for PortableMoveNotation::Action following PMN v1.0.0 array format

puts "Testing PortableMoveNotation::Action (PMN v1.0.0 format)..."

# Test basic Action instantiation with array arguments
action = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
raise "Expected Action instance" unless action.is_a?(PortableMoveNotation::Action)
raise "Expected src_square to be 'e2', got #{action.src_square}" unless action.src_square == "e2"
raise "Expected dst_square to be 'e4', got #{action.dst_square}" unless action.dst_square == "e4"
raise "Expected piece_name to be 'P', got #{action.piece_name}" unless action.piece_name == "P"
raise "Expected captured_piece to be nil, got #{action.captured_piece}" unless action.captured_piece.nil?
raise "Expected action to be frozen" unless action.frozen?

# Test array representation (PMN v1.0.0 format)
expected_array = ["e2", "e4", "P", nil]
actual_array = action.to_a
raise "Expected #{expected_array}, got #{actual_array}" unless actual_array == expected_array

# Test piece drop (nil src_square)
drop_action = PortableMoveNotation::Action.new(nil, "27", "p", nil)
raise "Expected src_square to be nil, got #{drop_action.src_square}" unless drop_action.src_square.nil?
raise "Expected dst_square to be '27', got #{drop_action.dst_square}" unless drop_action.dst_square == "27"
raise "Expected piece_name to be 'p', got #{drop_action.piece_name}" unless drop_action.piece_name == "p"

expected_drop_array = [nil, "27", "p", nil]
actual_drop_array = drop_action.to_a
raise "Expected #{expected_drop_array}, got #{actual_drop_array}" unless actual_drop_array == expected_drop_array

# Test piece capture with piece becoming available for dropping
capture_action = PortableMoveNotation::Action.new("33", "24", "B", "P")
unless capture_action.captured_piece == "P"
  raise "Expected captured_piece to be 'P', got #{capture_action.captured_piece}"
end

expected_capture_array = %w[33 24 B P]
actual_capture_array = capture_action.to_a
unless actual_capture_array == expected_capture_array
  raise "Expected #{expected_capture_array}, got #{actual_capture_array}"
end

# Test promoted piece
promote_action = PortableMoveNotation::Action.new("27", "18", "+P", nil)
raise "Expected piece_name to be '+P', got #{promote_action.piece_name}" unless promote_action.piece_name == "+P"

# Test from_array class method
array_data = ["e2", "e4", "P", nil]
action_from_array = PortableMoveNotation::Action.from_array(array_data)
raise "Expected Action instance" unless action_from_array.is_a?(PortableMoveNotation::Action)
raise "Expected arrays to match" unless action_from_array.to_a == array_data

# Test valid? class method with valid array data
valid_array = ["e2", "e4", "P", nil]
result = PortableMoveNotation::Action.valid?(valid_array)
raise "Expected true for valid array, got #{result}" unless result == true

# Test valid? with drop action
valid_drop_array = [nil, "27", "p", nil]
result = PortableMoveNotation::Action.valid?(valid_drop_array)
raise "Expected true for valid drop array, got #{result}" unless result == true

# Test valid? class method with invalid array data
invalid_array = %w[e2 e4] # Missing piece_name and captured_piece
result = PortableMoveNotation::Action.valid?(invalid_array)
raise "Expected false for invalid array, got #{result}" unless result == false

# Test valid? class method with non-array input
result = PortableMoveNotation::Action.valid?("not an array")
raise "Expected false for non-array input, got #{result}" unless result == false

# Test valid? with wrong array size
wrong_size_array = %w[e2 e4 P] # Only 3 elements
result = PortableMoveNotation::Action.valid?(wrong_size_array)
raise "Expected false for wrong size array, got #{result}" unless result == false

# Test valid? with invalid types
invalid_type_array = ["e2", 42, "P", nil] # dst_square is not a string
result = PortableMoveNotation::Action.valid?(invalid_type_array)
raise "Expected false for invalid type array, got #{result}" unless result == false

# Test valid? with empty strings
empty_string_array = ["e2", "", "P", nil] # Empty dst_square
result = PortableMoveNotation::Action.valid?(empty_string_array)
raise "Expected false for empty string array, got #{result}" unless result == false

# Test validation errors - invalid src_square (empty string)
begin
  PortableMoveNotation::Action.new("", "e4", "P", nil)
  raise "Expected ArgumentError for empty src_square, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Square must be a non-empty string")
end

# Test validation errors - invalid src_square (non-string)
begin
  PortableMoveNotation::Action.new(42, "e4", "P", nil)
  raise "Expected ArgumentError for non-string src_square, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Square must be a non-empty string")
end

# Test validation errors - invalid dst_square (empty string)
begin
  PortableMoveNotation::Action.new("e2", "", "P", nil)
  raise "Expected ArgumentError for empty dst_square, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Square must be a non-empty string")
end

# Test validation errors - invalid piece_name (empty string)
begin
  PortableMoveNotation::Action.new("e2", "e4", "", nil)
  raise "Expected ArgumentError for empty piece_name, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece name must be a non-empty string")
end

# Test validation errors - invalid piece_name (non-string)
begin
  PortableMoveNotation::Action.new("e2", "e4", 123, nil)
  raise "Expected ArgumentError for non-string piece_name, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece name must be a non-empty string")
end

# Test validation errors - invalid captured_piece (empty string)
begin
  PortableMoveNotation::Action.new("e2", "e4", "P", "")
  raise "Expected ArgumentError for empty captured_piece, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Captured piece must be a non-empty string")
end

# Test validation errors - invalid captured_piece (non-string)
begin
  PortableMoveNotation::Action.new("e2", "e4", "P", 456)
  raise "Expected ArgumentError for non-string captured_piece, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Captured piece must be a non-empty string")
end

# Test from_array with invalid input
begin
  PortableMoveNotation::Action.from_array("not an array")
  raise "Expected ArgumentError for non-array input, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Expected 4-element array")
end

# Test from_array with wrong size
begin
  PortableMoveNotation::Action.from_array(%w[e2 e4])
  raise "Expected ArgumentError for wrong size array, but none was raised"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Expected 4-element array")
end

# Test equality and comparison
action1 = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
action2 = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
action3 = PortableMoveNotation::Action.new("e2", "e4", "Q", nil)

raise "Expected equal actions to be equal" unless action1 == action2
raise "Expected different actions to be unequal" if action1 == action3
raise "Expected equal actions to have same hash" unless action1.hash == action2.hash

# Test string representations
action = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
raise "Expected inspect to contain array" unless action.inspect.include?('["e2", "e4", "P", nil]')
raise "Expected to_s to show array" unless action.to_s == '["e2", "e4", "P", nil]'

# Test with various piece notations (PMN v1.0.0 allows any non-empty string)
unicode_action = PortableMoveNotation::Action.new("e2", "e4", "♔", nil)
raise "Expected unicode piece name to work" unless unicode_action.piece_name == "♔"

descriptive_action = PortableMoveNotation::Action.new("e2", "e4", "WhiteKing", nil)
raise "Expected descriptive piece name to work" unless descriptive_action.piece_name == "WhiteKing"

numeric_action = PortableMoveNotation::Action.new("e2", "e4", "42", nil)
raise "Expected numeric piece name to work" unless numeric_action.piece_name == "42"

custom_action = PortableMoveNotation::Action.new("e2", "e4", "MagicDragon_powered", nil)
raise "Expected custom piece name to work" unless custom_action.piece_name == "MagicDragon_powered"

# Test shogi-style pieces
shogi_action = PortableMoveNotation::Action.new("27", "18", "+P", nil)
raise "Expected shogi promoted piece to work" unless shogi_action.piece_name == "+P"

shogi_capture = PortableMoveNotation::Action.new("36", "27", "B", "P")
raise "Expected shogi capture to work" unless shogi_capture.captured_piece == "P"

puts "All Action tests passed!"
