# frozen_string_literal: true

require_relative "../lib/portable_move_notation"
require "json"

# Complete test suite for PMN v1.0.0 implementation

puts "=" * 60
puts "PMN v1.0.0 Ruby Implementation - Complete Test Suite"
puts "=" * 60

# Test module-level convenience methods
puts "\nTesting module-level methods..."

# Test module validation
pmn_data = [["e2", "e4", "P", nil]]
raise "Expected module valid? to return true" unless PortableMoveNotation.valid?(pmn_data)

invalid_data = [["e2"]]
raise "Expected module valid? to return false" if PortableMoveNotation.valid?(invalid_data)

# Test module parse
json_string = '[["e2","e4","P",null]]'
move = PortableMoveNotation.parse(json_string)
raise "Expected parsed move to be Move instance" unless move.is_a?(PortableMoveNotation::Move)

# Test module generate
generated_json = PortableMoveNotation.generate(move)
raise "Expected generated JSON to be string" unless generated_json.is_a?(String)

parsed_back = JSON.parse(generated_json)
raise "Expected roundtrip to work" unless parsed_back == [["e2", "e4", "P", nil]]

puts "✓ Module-level methods work correctly"

# Test schema compliance
puts "\nTesting JSON Schema compliance..."

# Test various valid PMN structures
test_cases = [
  # Simple pawn move
  [["e2", "e4", "P", nil]],

  # Drop from hand
  [[nil, "27", "p", nil]],

  # Capture
  [%w[d4 e5 P p]],

  # Promotion
  [["a7", "a8", "+Q", nil]],

  # Complex castling
  [["e1", "g1", "K", nil], ["h1", "f1", "R", nil]],

  # En passant (simplified representation - just the capture move)
  # Note: PMN focuses on state changes, not the specific removal of the captured pawn
  # The captured pawn entering the hand is represented by the captured_piece field
  [%w[d5 e6 P p]],

  # Unicode pieces
  [["e1", "e2", "♔", nil]],

  # Descriptive pieces
  [%w[a1 a2 WhiteRook BlackPawn]],

  # Custom notation
  [["center", "edge_7", "MagicDragon_powered", nil]],

  # Multiple custom actions
  [["start", "mid", "Piece1", nil], %w[mid end Piece2 Captured1]]
]

test_cases.each_with_index do |test_case, index|
  # Test that our implementation can parse it
  move = PortableMoveNotation::Move.from_pmn(test_case)

  # Test that it serializes correctly
  json = move.to_json
  parsed = JSON.parse(json)

  # Test roundtrip
  move_back = PortableMoveNotation::Move.from_pmn(parsed)

  raise "Roundtrip failed" unless move.to_pmn == move_back.to_pmn

  puts "✓ Test case #{index + 1}: #{test_case.inspect}"
rescue StandardError => e
  puts "✗ Test case #{index + 1} failed: #{e.message}"
  raise
end

puts "✓ All schema compliance tests passed"

# Test error handling
puts "\nTesting error handling..."

error_test_cases = [
  # Wrong array size
  { data: [%w[e2 e4]], error: ArgumentError, desc: "array too short" },

  # Wrong types
  { data: [[42, "e4", "P", nil]], error: ArgumentError, desc: "non-string source" },
  { data: [["e2", 42, "P", nil]], error: ArgumentError, desc: "non-string destination" },
  { data: [["e2", "e4", 42, nil]], error: ArgumentError, desc: "non-string piece" },
  { data: [["e2", "e4", "P", 42]], error: ArgumentError, desc: "non-string capture" },

  # Empty strings
  { data: [["", "e4", "P", nil]], error: ArgumentError, desc: "empty source" },
  { data: [["e2", "", "P", nil]], error: ArgumentError, desc: "empty destination" },
  { data: [["e2", "e4", "", nil]], error: ArgumentError, desc: "empty piece" },
  { data: [["e2", "e4", "P", ""]], error: ArgumentError, desc: "empty capture" },

  # nil piece_name (not allowed in PMN specification)
  { data: [["e2", "e4", nil, nil]], error: ArgumentError, desc: "nil piece_name" },

  # Invalid JSON
  { json: "invalid json", error: JSON::ParserError, desc: "invalid JSON" },
  { json: '{"not": "array"}', error: ArgumentError, desc: "JSON object instead of array" }
]

error_test_cases.each do |test_case|
  if test_case[:json]
    PortableMoveNotation::Move.from_json(test_case[:json])
  else
    PortableMoveNotation::Move.from_pmn(test_case[:data])
  end

  puts "✗ Expected error for #{test_case[:desc]} but none was raised"
  raise "Test failed"
rescue test_case[:error]
  puts "✓ Correctly caught error for #{test_case[:desc]}"
rescue StandardError => e
  puts "✗ Wrong error type for #{test_case[:desc]}: got #{e.class}, expected #{test_case[:error]}"
  raise
end

puts "✓ All error handling tests passed"

# Test performance and memory usage
puts "\nTesting performance characteristics..."

# Test with large number of actions
large_actions = Array.new(1000) do |i|
  ["sq#{i}", "sq#{i + 1}", "P#{i}", i.even? ? "C#{i}" : nil]
end

start_time = Time.now
large_move = PortableMoveNotation::Move.from_pmn(large_actions)
parse_time = Time.now - start_time

start_time = Time.now
json = large_move.to_json
serialize_time = Time.now - start_time

start_time = Time.now
PortableMoveNotation::Move.from_json(json)
deserialize_time = Time.now - start_time

puts "✓ Large move (1000 actions) - Parse: #{(parse_time * 1000).round(2)}ms, Serialize: #{(serialize_time * 1000).round(2)}ms, Deserialize: #{(deserialize_time * 1000).round(2)}ms"

# Test immutability
puts "\nTesting immutability..."

action = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
move = PortableMoveNotation::Move.new(action)

raise "Action should be frozen" unless action.frozen?
raise "Move should be frozen" unless move.frozen?
raise "Actions array should be frozen" unless move.actions.frozen?

# Try to modify (should fail)
begin
  move.actions << "something"
  raise "Should not be able to modify actions array"
rescue FrozenError, NoMethodError
  puts "✓ Actions array is properly immutable"
end

puts "✓ All immutability tests passed"

# Test compatibility scenarios
puts "\nTesting real-world compatibility scenarios..."

# Chess scenarios
chess_scenarios = [
  {
    name:  "Chess opening (e4 e5)",
    moves: [
      [["e2", "e4", "P", nil]],
      [["e7", "e5", "p", nil]]
    ]
  },
  {
    name:  "Chess castling kingside",
    moves: [
      [["e1", "g1", "K", nil], ["h1", "f1", "R", nil]]
    ]
  },
  {
    name:  "Chess en passant (simplified)",
    moves: [
      [["e2", "e4", "P", nil]],
      [["d7", "d5", "p", nil]],
      [%w[e4 d5 P p]] # Simplified en passant representation
    ]
  }
]

# Shogi scenarios
shogi_scenarios = [
  {
    name:  "Shogi pawn drop",
    moves: [
      [[nil, "27", "p", nil]]
    ]
  },
  {
    name:  "Shogi promotion",
    moves: [
      [["27", "18", "+P", nil]]
    ]
  },
  {
    name:  "Shogi capture with demotion",
    moves: [
      [%w[36 27 B P]]
    ]
  }
]

all_scenarios = chess_scenarios + shogi_scenarios

all_scenarios.each do |scenario|
  scenario[:moves].each_with_index do |move_data, move_index|
    move = PortableMoveNotation::Move.from_pmn(move_data)
    json = move.to_json
    parsed = JSON.parse(json)

    # Verify roundtrip
    move_back = PortableMoveNotation::Move.from_pmn(parsed)
    raise "Roundtrip failed" unless move.to_pmn == move_back.to_pmn
  rescue StandardError => e
    puts "✗ Scenario '#{scenario[:name]}' move #{move_index + 1} failed: #{e.message}"
    raise
  end
  puts "✓ #{scenario[:name]}"
end

puts "✓ All compatibility scenarios passed"

# Test edge cases
puts "\nTesting edge cases..."

edge_cases = [
  {
    name: "Very long square names",
    data: [["very_long_square_name_123456", "another_very_long_name_789", "VeryLongPieceName", nil]]
  },
  {
    name: "Unicode square names",
    data: [["中1", "中2", "王", nil]]
  },
  {
    name: "Single character everything",
    data: [%w[a b c d]]
  },
  {
    name: "Numbers as strings",
    data: [%w[1 2 3 4]]
  },
  {
    name: "Mixed notation systems",
    data: [
      ["e2", "e4", "♔", nil],
      ["a1", "a8", "CHESS:R", "shogi:p"],
      ["@3,4", "#5,6", "MagicPiece_v2", nil]
    ]
  }
]

edge_cases.each do |test_case|
  move = PortableMoveNotation::Move.from_pmn(test_case[:data])
  json = move.to_json
  parsed = JSON.parse(json)
  move_back = PortableMoveNotation::Move.from_pmn(parsed)

  raise "Roundtrip failed" unless move.to_pmn == move_back.to_pmn

  puts "✓ #{test_case[:name]}"
rescue StandardError => e
  puts "✗ Edge case '#{test_case[:name]}' failed: #{e.message}"
  raise
end

puts "✓ All edge case tests passed"

# Final validation
puts "\nRunning final validation..."

# Test that constants are properly defined
raise "SCHEMA_URL constant missing" unless defined?(PortableMoveNotation::SCHEMA_URL)

# Test that all required methods exist
required_methods = {
  PortableMoveNotation::Action => %i[new valid? from_array to_a src_square dst_square piece_name
                                     captured_piece],
  PortableMoveNotation::Move   => %i[new valid? from_json from_pmn to_json to_pmn actions size empty?
                                     each]
}

required_methods.each do |klass, methods|
  methods.each do |method|
    raise "#{klass} missing method #{method}" unless klass.method_defined?(method) || klass.respond_to?(method)
  end
end

puts "✓ All required methods present"
puts "✓ All constants properly defined"

puts "\n#{'=' * 60}"
puts "🎉 ALL TESTS PASSED! PMN v1.0.0 implementation is correct."
puts "=" * 60
puts "\nImplementation summary:"
puts "- Actions use 4-element arrays: [src_square, dst_square, piece_name, captured_piece]"
puts "- Moves are arrays of action arrays"
puts "- Full JSON roundtrip compatibility"
puts "- Comprehensive error handling"
puts "- Immutable objects for thread safety"
puts "- Support for any UTF-8 piece notation"
puts "- Schema compliance with PMN v1.0.0"
puts "- Module-level convenience methods"
