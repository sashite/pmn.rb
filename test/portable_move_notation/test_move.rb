# frozen_string_literal: true

require "json"
require_relative "../../lib/portable_move_notation"

# Simple tests for PortableMoveNotation::Move

puts "Testing PortableMoveNotation::Move..."

# Setup basic test actions
pawn_action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P",
  piece_hand: nil
)

king_action = PortableMoveNotation::Action.new(
  src_square: "e1",
  dst_square: "g1",
  piece_name: "K",
  piece_hand: nil
)

rook_action = PortableMoveNotation::Action.new(
  src_square: "h1",
  dst_square: "f1",
  piece_name: "R",
  piece_hand: nil
)

drop_action = PortableMoveNotation::Action.new(
  src_square: nil,
  dst_square: "27",
  piece_name: "p",
  piece_hand: nil
)

valid_pmn_array = [
  { "src_square" => "e2", "dst_square" => "e4", "piece_name" => "P", "piece_hand" => nil }
]

invalid_pmn_array = [
  { "src_square" => "e2" } # Missing dst_square and piece_name
]

valid_json_string = '[{"src_square":"e2","dst_square":"e4","piece_name":"P","piece_hand":null}]'

# Test initializing with a single action
move = PortableMoveNotation::Move.new(pawn_action)
raise "Expected Move instance" unless move.is_a?(PortableMoveNotation::Move)
raise "Expected 1 action, got #{move.actions.size}" unless move.actions.size == 1
raise "Expected action to match" unless move.actions.first == pawn_action
raise "Expected move to be frozen" unless move.frozen?
raise "Expected actions array to be frozen" unless move.actions.frozen?

# Test initializing with multiple actions
move = PortableMoveNotation::Move.new(king_action, rook_action)
raise "Expected 2 actions, got #{move.actions.size}" unless move.actions.size == 2
raise "Expected first action to be king_action" unless move.actions.first == king_action
raise "Expected second action to be rook_action" unless move.actions.last == rook_action

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
raise "Expected piece_hand to be nil, got #{move.actions.first.piece_hand}" unless move.actions.first.piece_hand.nil?

# Test from_json with invalid JSON
begin
  PortableMoveNotation::Move.from_json("invalid json")
  raise "Expected JSON::ParserError but none was raised"
rescue JSON::ParserError
  # This is the expected error
end

# Test from_json with missing required fields
begin
  PortableMoveNotation::Move.from_json('[{"src_square":"e2"}]')
  raise "Expected KeyError but none was raised"
rescue KeyError
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
raise "Expected piece_hand to be nil, got #{move.actions.first.piece_hand}" unless move.actions.first.piece_hand.nil?

# Test from_pmn with missing required fields
begin
  PortableMoveNotation::Move.from_pmn(invalid_pmn_array)
  raise "Expected KeyError but none was raised"
rescue KeyError
  # This is the expected error
end

# Test from_params with Action object
move = PortableMoveNotation::Move.from_params(actions: [pawn_action])
raise "Expected Move instance" unless move.is_a?(PortableMoveNotation::Move)
raise "Expected 1 action, got #{move.actions.size}" unless move.actions.size == 1
raise "Expected action to match" unless move.actions.first == pawn_action

# Test from_params with hash
params = {
  actions: [
    {
      src_square: "e2",
      dst_square: "e4",
      piece_name: "P"
    }
  ]
}
move = PortableMoveNotation::Move.from_params(**params)
raise "Expected Move instance" unless move.is_a?(PortableMoveNotation::Move)
raise "Expected 1 action, got #{move.actions.size}" unless move.actions.size == 1
unless move.actions.first.src_square == "e2"
  raise "Expected src_square to be 'e2', got #{move.actions.first.src_square}"
end
unless move.actions.first.dst_square == "e4"
  raise "Expected dst_square to be 'e4', got #{move.actions.first.dst_square}"
end
raise "Expected piece_name to be 'P', got #{move.actions.first.piece_name}" unless move.actions.first.piece_name == "P"

# Test from_params with missing actions key
begin
  PortableMoveNotation::Move.from_params(actions: nil)
  raise "Expected ArgumentError but none was raised"
rescue ArgumentError
  # This is the expected error
end

# Test to_pmn with single action
move = PortableMoveNotation::Move.new(pawn_action)
pmn = move.to_pmn
raise "Expected Array, got #{pmn.class}" unless pmn.is_a?(Array)
raise "Expected 1 item, got #{pmn.size}" unless pmn.size == 1

expected = { "src_square" => "e2", "dst_square" => "e4", "piece_name" => "P", "piece_hand" => nil }
raise "Expected #{expected}, got #{pmn.first}" unless pmn.first == expected

# Test to_pmn with multiple actions
move = PortableMoveNotation::Move.new(king_action, rook_action)
pmn = move.to_pmn
raise "Expected Array, got #{pmn.class}" unless pmn.is_a?(Array)
raise "Expected 2 items, got #{pmn.size}" unless pmn.size == 2

expected_first = { "src_square" => "e1", "dst_square" => "g1", "piece_name" => "K", "piece_hand" => nil }
expected_second = { "src_square" => "h1", "dst_square" => "f1", "piece_name" => "R", "piece_hand" => nil }
raise "Expected #{expected_first}, got #{pmn.first}" unless pmn.first == expected_first
raise "Expected #{expected_second}, got #{pmn.last}" unless pmn.last == expected_second

# Test to_json format
move = PortableMoveNotation::Move.new(pawn_action)
json = move.to_json
raise "Expected String, got #{json.class}" unless json.is_a?(String)

parsed = JSON.parse(json)
raise "Expected Array, got #{parsed.class}" unless parsed.is_a?(Array)
raise "Expected 1 item, got #{parsed.size}" unless parsed.size == 1
raise "Expected src_square 'e2', got #{parsed.first['src_square']}" unless parsed.first["src_square"] == "e2"

# Test JSON roundtrip
move = PortableMoveNotation::Move.from_json(valid_json_string)
json = move.to_json
expected = JSON.parse(valid_json_string)
actual = JSON.parse(json)
raise "Expected #{expected}, got #{actual}" unless expected == actual

# Test chess en passant scenario
pawn_move_action = PortableMoveNotation::Action.new(
  src_square: "e2",
  dst_square: "e4",
  piece_name: "P",
  piece_hand: nil
)

capture_action1 = PortableMoveNotation::Action.new(
  src_square: "d4",
  dst_square: "e3",
  piece_name: "p",
  piece_hand: nil
)

capture_action2 = PortableMoveNotation::Action.new(
  src_square: "e3",
  dst_square: "e4",
  piece_name: "p",
  piece_hand: nil
)

initial_move = PortableMoveNotation::Move.new(pawn_move_action)
raise "Expected 1 action, got #{initial_move.actions.size}" unless initial_move.actions.size == 1

en_passant_move = PortableMoveNotation::Move.new(capture_action1, capture_action2)
raise "Expected 2 actions, got #{en_passant_move.actions.size}" unless en_passant_move.actions.size == 2

en_passant_json = en_passant_move.to_json
parsed = JSON.parse(en_passant_json)
raise "Expected 2 items, got #{parsed.size}" unless parsed.size == 2
raise "Expected src_square 'd4', got #{parsed.first['src_square']}" unless parsed.first["src_square"] == "d4"
raise "Expected dst_square 'e3', got #{parsed.first['dst_square']}" unless parsed.first["dst_square"] == "e3"
raise "Expected src_square 'e3', got #{parsed.last['src_square']}" unless parsed.last["src_square"] == "e3"
raise "Expected dst_square 'e4', got #{parsed.last['dst_square']}" unless parsed.last["dst_square"] == "e4"

# Test shogi drop and promote scenario
drop_move = PortableMoveNotation::Move.new(drop_action)
raise "Expected 1 action, got #{drop_move.actions.size}" unless drop_move.actions.size == 1
raise "Expected src_square to be nil" unless drop_move.actions.first.src_square.nil?
unless drop_move.actions.first.dst_square == "27"
  raise "Expected dst_square to be '27', got #{drop_move.actions.first.dst_square}"
end

promote_action = PortableMoveNotation::Action.new(
  src_square: "27",
  dst_square: "18",
  piece_name: "+P",
  piece_hand: nil
)

promote_move = PortableMoveNotation::Move.new(promote_action)
raise "Expected 1 action, got #{promote_move.actions.size}" unless promote_move.actions.size == 1
unless promote_move.actions.first.piece_name == "+P"
  raise "Expected piece_name to be '+P', got #{promote_move.actions.first.piece_name}"
end

puts "All tests passed!"
