# frozen_string_literal: true

require "json"
require_relative "../../lib/portable_move_notation"

# Tests for PortableMoveNotation::Move following PMN v1.0.0 array format

puts "Testing PortableMoveNotation::Move (PMN v1.0.0 format)..."

# Setup basic test actions
pawn_action = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
king_action = PortableMoveNotation::Action.new("e1", "g1", "K", nil)
rook_action = PortableMoveNotation::Action.new("h1", "f1", "R", nil)
drop_action = PortableMoveNotation::Action.new(nil, "27", "p", nil)

# Valid PMN v1.0.0 array format
valid_pmn_array = [
  ["e2", "e4", "P", nil]
]

invalid_pmn_array = [
  ["e2"] # Missing required elements
]

valid_json_string = '[["e2","e4","P",null]]'

# Test initializing with a single action
move = PortableMoveNotation::Move.new(pawn_action)
raise "Expected Move instance" unless move.is_a?(PortableMoveNotation::Move)
raise "Expected 1 action, got #{move.actions.size}" unless move.actions.size == 1
raise "Expected action to match" unless move.actions.first == pawn_action
raise "Expected move to be frozen" unless move.frozen?
raise "Expected actions array to be frozen" unless move.actions.frozen?

# Test move array representation (PMN v1.0.0 format)
expected_move_array = [["e2", "e4", "P", nil]]
actual_move_array = move.to_pmn
raise "Expected #{expected_move_array}, got #{actual_move_array}" unless actual_move_array == expected_move_array

# Test initializing with multiple actions
move = PortableMoveNotation::Move.new(king_action, rook_action)
raise "Expected 2 actions, got #{move.actions.size}" unless move.actions.size == 2
raise "Expected first action to be king_action" unless move.actions.first == king_action
raise "Expected second action to be rook_action" unless move.actions.last == rook_action

expected_castle_array = [["e1", "g1", "K", nil], ["h1", "f1", "R", nil]]
actual_castle_array = move.to_pmn
unless actual_castle_array == expected_castle_array
  raise "Expected #{expected_castle_array}, got #{actual_castle_array}"
end

# Test error when initializing with no actions
begin
  PortableMoveNotation::Move.new
  raise "Expected ArgumentError but none was raised"
rescue ArgumentError
  # This is the expected error
end

# Test error when initializing with non-Action arguments
begin
  PortableMoveNotation::Move.new("not an action")
  raise "Expected ArgumentError but none was raised"
rescue ArgumentError
  # This is the expected error
end

# Test valid? with valid PMN data
result = PortableMoveNotation::Move.valid?(valid_pmn_array)
raise "Expected true for valid PMN, got #{result}" unless result == true

# Test valid? with invalid PMN data
result = PortableMoveNotation::Move.valid?(invalid_pmn_array)
raise "Expected false for invalid PMN, got #{result}" unless result == false

# Test valid? with non-array input
result = PortableMoveNotation::Move.valid?("not an array")
raise "Expected false for non-array, got #{result}" unless result == false

# Test valid? with empty array
result = PortableMoveNotation::Move.valid?([])
raise "Expected false for empty array, got #{result}" unless result == false

# Test valid? with multi-action move
multi_action_array = [
  ["e1", "g1", "K", nil],
  ["h1", "f1", "R", nil]
]
result = PortableMoveNotation::Move.valid?(multi_action_array)
raise "Expected true for valid multi-action PMN, got #{result}" unless result == true

# Test from_json with valid input
move = PortableMoveNotation::Move.from_json(valid_json_string)
raise "Expected Move instance" unless move.is_a?(PortableMoveNotation::Move)
raise "Expected 1 action, got #{move.actions.size}" unless move.actions.size == 1
unless move.actions.first.src_square == "e2"
  raise "Expected src_square to be 'e2', got #{move.actions.first.src_square}"
end
unless move.actions.first.dst_square == "e4"
  raise "Expected dst_square to be 'e4', got #{move.actions.first.dst_square}"
end
raise "Expected piece_name to be 'P', got #{move.actions.first.piece_name}" unless move.actions.first.piece_name == "P"
unless move.actions.first.captured_piece.nil?
  raise "Expected captured_piece to be nil, got #{move.actions.first.captured_piece}"
end

# Test from_json with invalid JSON
begin
  PortableMoveNotation::Move.from_json("invalid json")
  raise "Expected JSON::ParserError but none was raised"
rescue JSON::ParserError
  # This is the expected error
end

# Test from_json with malformed array
begin
  PortableMoveNotation::Move.from_json('[["e2"]]') # Missing required elements
  raise "Expected ArgumentError but none was raised"
rescue ArgumentError
  # This is the expected error
end

# Test from_pmn with valid input
move = PortableMoveNotation::Move.from_pmn(valid_pmn_array)
raise "Expected Move instance" unless move.is_a?(PortableMoveNotation::Move)
raise "Expected 1 action, got #{move.actions.size}" unless move.actions.size == 1
unless move.actions.first.src_square == "e2"
  raise "Expected src_square to be 'e2', got #{move.actions.first.src_square}"
end
unless move.actions.first.dst_square == "e4"
  raise "Expected dst_square to be 'e4', got #{move.actions.first.dst_square}"
end
raise "Expected piece_name to be 'P', got #{move.actions.first.piece_name}" unless move.actions.first.piece_name == "P"
unless move.actions.first.captured_piece.nil?
  raise "Expected captured_piece to be nil, got #{move.actions.first.captured_piece}"
end

# Test from_pmn with malformed array
begin
  PortableMoveNotation::Move.from_pmn(invalid_pmn_array)
  raise "Expected ArgumentError but none was raised"
rescue ArgumentError
  # This is the expected error
end

# Test to_pmn with single action
move = PortableMoveNotation::Move.new(pawn_action)
pmn = move.to_pmn
raise "Expected Array, got #{pmn.class}" unless pmn.is_a?(Array)
raise "Expected 1 item, got #{pmn.size}" unless pmn.size == 1

expected = ["e2", "e4", "P", nil]
raise "Expected #{expected}, got #{pmn.first}" unless pmn.first == expected

# Test to_pmn with multiple actions (castling)
move = PortableMoveNotation::Move.new(king_action, rook_action)
pmn = move.to_pmn
raise "Expected Array, got #{pmn.class}" unless pmn.is_a?(Array)
raise "Expected 2 items, got #{pmn.size}" unless pmn.size == 2

expected_first = ["e1", "g1", "K", nil]
expected_second = ["h1", "f1", "R", nil]
raise "Expected #{expected_first}, got #{pmn.first}" unless pmn.first == expected_first
raise "Expected #{expected_second}, got #{pmn.last}" unless pmn.last == expected_second

# Test to_json format
move = PortableMoveNotation::Move.new(pawn_action)
json = move.to_json
raise "Expected String, got #{json.class}" unless json.is_a?(String)

parsed = JSON.parse(json)
raise "Expected Array, got #{parsed.class}" unless parsed.is_a?(Array)
raise "Expected 1 item, got #{parsed.size}" unless parsed.size == 1
raise "Expected src_square 'e2', got #{parsed.first[0]}" unless parsed.first[0] == "e2"
raise "Expected dst_square 'e4', got #{parsed.first[1]}" unless parsed.first[1] == "e4"
raise "Expected piece_name 'P', got #{parsed.first[2]}" unless parsed.first[2] == "P"
raise "Expected captured_piece nil, got #{parsed.first[3]}" unless parsed.first[3].nil?

# Test JSON roundtrip
move = PortableMoveNotation::Move.from_json(valid_json_string)
json = move.to_json
expected = JSON.parse(valid_json_string)
actual = JSON.parse(json)
raise "Expected #{expected}, got #{actual}" unless expected == actual

# Test chess en passant scenario (simplified representation)
# En passant is represented as a simple capture where the captured pawn goes to hand
pawn_advance = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
# Simplified en passant: pawn captures diagonally, captured pawn enters hand
en_passant_capture = PortableMoveNotation::Action.new("d5", "e6", "p", "P")

initial_move = PortableMoveNotation::Move.new(pawn_advance)
raise "Expected 1 action, got #{initial_move.actions.size}" unless initial_move.actions.size == 1

en_passant_move = PortableMoveNotation::Move.new(en_passant_capture)
raise "Expected 1 action, got #{en_passant_move.actions.size}" unless en_passant_move.actions.size == 1

en_passant_json = en_passant_move.to_json
parsed = JSON.parse(en_passant_json)
raise "Expected 1 item, got #{parsed.size}" unless parsed.size == 1
raise "Expected src_square 'd5', got #{parsed.first[0]}" unless parsed.first[0] == "d5"
raise "Expected dst_square 'e6', got #{parsed.first[1]}" unless parsed.first[1] == "e6"
raise "Expected piece_name 'p', got #{parsed.first[2]}" unless parsed.first[2] == "p"
raise "Expected captured_piece 'P', got #{parsed.first[3]}" unless parsed.first[3] == "P"

# Test shogi drop scenario
drop_move = PortableMoveNotation::Move.new(drop_action)
raise "Expected 1 action, got #{drop_move.actions.size}" unless drop_move.actions.size == 1
raise "Expected src_square to be nil" unless drop_move.actions.first.src_square.nil?
unless drop_move.actions.first.dst_square == "27"
  raise "Expected dst_square to be '27', got #{drop_move.actions.first.dst_square}"
end

drop_json = drop_move.to_json
parsed_drop = JSON.parse(drop_json)
expected_drop = [[nil, "27", "p", nil]]
raise "Expected #{expected_drop}, got #{parsed_drop}" unless parsed_drop == expected_drop

promote_action = PortableMoveNotation::Action.new("27", "18", "+P", nil)
promote_move = PortableMoveNotation::Move.new(promote_action)
raise "Expected 1 action, got #{promote_move.actions.size}" unless promote_move.actions.size == 1
unless promote_move.actions.first.piece_name == "+P"
  raise "Expected piece_name to be '+P', got #{promote_move.actions.first.piece_name}"
end

# Test utility methods
move = PortableMoveNotation::Move.new(king_action, rook_action)
raise "Expected size 2, got #{move.size}" unless move.size == 2
raise "Expected not empty" if move.empty?
raise "Expected action at index 0" unless move[0] == king_action
raise "Expected action at index 1" unless move[1] == rook_action

# Test iteration
actions_collected = []
move.each { |action| actions_collected << action }
raise "Expected 2 actions collected" unless actions_collected.size == 2
raise "Expected first action to match" unless actions_collected[0] == king_action
raise "Expected second action to match" unless actions_collected[1] == rook_action

# Test equality and comparison
move1 = PortableMoveNotation::Move.new(pawn_action)
PortableMoveNotation::Move.new(pawn_action)
move3 = PortableMoveNotation::Move.new(king_action)

# NOTE: These create different Action objects but with same content
# so they should be equal
action_copy = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
move4 = PortableMoveNotation::Move.new(action_copy)

raise "Expected moves with same content to be equal" unless move1 == move4
raise "Expected different moves to be unequal" if move1 == move3
raise "Expected equal moves to have same hash" unless move1.hash == move4.hash

# Test string representations
move = PortableMoveNotation::Move.new(pawn_action)
raise "Expected inspect to contain array" unless move.inspect.include?('[["e2", "e4", "P", nil]]')
raise "Expected to_s to show array" unless move.to_s == '[["e2", "e4", "P", nil]]'

# Test complex move with capture and promotion
complex_action = PortableMoveNotation::Action.new("a7", "b8", "+Q", "R")
complex_move = PortableMoveNotation::Move.new(complex_action)
complex_json = complex_move.to_json
parsed_complex = JSON.parse(complex_json)
expected_complex = [["a7", "b8", "+Q", "R"]]
raise "Expected #{expected_complex}, got #{parsed_complex}" unless parsed_complex == expected_complex

# Test error handling for invalid PMN structures in Move validation
# Test that Move.valid? correctly rejects arrays with nil piece_name
invalid_nil_piece_array = [["e2", "e4", nil, nil]]
result = PortableMoveNotation::Move.valid?(invalid_nil_piece_array)
raise "Expected false for nil piece_name, got #{result}" unless result == false

# Test that Move.from_pmn rejects arrays with nil piece_name
begin
  PortableMoveNotation::Move.from_pmn(invalid_nil_piece_array)
  raise "Expected ArgumentError for nil piece_name but none was raised"
rescue ArgumentError
  # This is the expected behavior
end

puts "All Move tests passed!"
