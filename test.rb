# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Pmn (Portable Move Notation)
#
# - No test framework used (plain Ruby)
# - Covers module API, Move, Action, error wrapping, and key predicates
# - Aligned with the minimal API (no JSON helpers, pass moves allowed)

begin
  require_relative "lib/sashite/pmn"
rescue LoadError
  require_relative "lib/sashite-pmn"
end

require "set"

# Shorthand to keep tests readable
Pmn = Sashite::Pmn

# ------------------------- Test Harness ----------------------------------------

def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.class}: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

def assert_raises(klass)
  begin
    yield
  rescue => e
    raise "Expected #{klass}, got #{e.class}" unless e.is_a?(klass)
    return e
  end
  raise "Expected #{klass} to be raised"
end

puts
puts "Tests for Sashite::Pmn (Portable Move Notation)"
puts

# ------------------------- Module-level validation -----------------------------

run_test("Pmn.valid? accepts valid arrays") do
  valid_samples = [
    ["e2", "e4"],                           # 2 elements, inferred piece
    ["e2", "e4", "C:P"],                    # 3 elements
    ["e2", "e4", "C:P", "d7", "d5"]         # 5 elements (3 + 2)
  ]
  valid_samples.each do |arr|
    raise "#{arr.inspect} should be valid" unless Pmn.valid?(arr)
  end
end

run_test("Pmn.valid? rejects invalid arrays and non-arrays") do
  invalid_samples = [
    [],                           # empty
    ["e2"],                       # incomplete (len 1)
    ["e2", "e4", "C:P", "X"],     # length 4 (3k+1)
    ["e2", "e4", 3],              # non-string element
    ["e2", "e4", "InvalidPiece"], # invalid QPI
    nil, "e2", 123, :e2           # non-arrays
  ]
  invalid_samples.each do |x|
    raise "#{x.inspect} should be invalid" if Pmn.valid?(x)
  end
end

# ------------------------- Parsing & building ----------------------------------

run_test("Pmn.parse returns a Move and preserves sequence") do
  arr = ["e2", "e4", "C:P", "d7", "d5", "c:p"]
  move = Pmn.parse(arr)
  raise "parse should return Move" unless move.is_a?(Pmn::Move)
  raise "actions size mismatch" unless move.actions.size == 2
  raise "roundtrip mismatch" unless move.to_a == arr
  raise "move should be frozen" unless move.frozen?
  raise "actions array should be frozen" unless move.actions.frozen?
  raise "pmn_array should be frozen" unless move.pmn_array.frozen?
end

run_test("Pmn.from_actions builds a move from Action objects") do
  a1 = Pmn::Action.new("e2", "e4", "C:P")
  a2 = Pmn::Action.new("d7", "d5", "c:p")
  move = Pmn.from_actions([a1, a2])
  raise "from_actions should build 2 actions" unless move.actions.size == 2
  raise "array content mismatch" unless move.to_a == ["e2","e4","C:P","d7","d5","c:p"]
end

# ------------------------- Move.new variadic syntax ----------------------------

run_test("Move.new accepts variadic elements; array form is rejected") do
  m1 = Pmn::Move.new("e2", "e4", "C:P")
  m2 = Pmn::Move.new("e2", "e4")
  raise "m1 should be valid" unless m1.valid?
  raise "m2 should be valid" unless m2.valid?

  # Single-array syntax must raise (entropy reduction)
  assert_raises(Pmn::InvalidMoveError) { Pmn::Move.new(["e2","e4","C:P"]) }
end

# ------------------------- Move semantics & immutability -----------------------

run_test("Move semantics: simple/compound, equality, hashing") do
  move = Pmn::Move.new("e1", "g1", "C:K", "h1", "f1", "C:R")
  raise "compound? expected" unless move.compound?
  raise "size mismatch" unless move.size == 2
  raise "empty? must be false" if move.empty?
  raise "first action mismatch" unless move.first_action.source == "e1"
  raise "last action mismatch" unless move.last_action.destination == "f1"

  same = Pmn::Move.new("e1","g1","C:K","h1","f1","C:R")
  diff = Pmn::Move.new("e2","e4","C:P")
  raise "equality failed" unless move == same
  raise "hash mismatch" unless move.hash == same.hash
  raise "should not equal different" if move == diff
end

run_test("Move to_a returns a copy (defensive copy)") do
  arr = ["e2","e4","C:P","d7","d5"]
  move = Pmn.parse(arr)
  a1 = move.to_a
  raise "array mismatch" unless a1 == arr
  a1 << "MUT"
  raise "to_a must be a copy" unless move.to_a == arr
end

run_test("Move content helpers (drops/captures/board_moves/sources/etc.)") do
  move = Pmn.parse(["*", "e5", "S:P", "e5", "*", "s:p", "e2", "e4", "C:P"])
  raise "expected 3 actions" unless move.actions.size == 3
  raise "has_drops? expected" unless move.has_drops?
  raise "has_captures? expected" unless move.has_captures?
  raise "board_moves count mismatch" unless move.board_moves.size == 1

  # Uniqueness
  raise "sources should be unique" unless move.sources.uniq == move.sources
  raise "destinations should be unique" unless move.destinations.uniq == move.destinations

  # Pieces exclude inferred (all explicit here)
  expected_pieces = ["S:P","s:p","C:P"].sort
  raise "pieces mismatch" unless move.pieces.sort == expected_pieces
  raise "has_inferred? should be false" if move.has_inferred?
end

run_test("Move.has_inferred? reflects inferred actions and pieces() excludes nil") do
  move = Pmn.parse(["e2","e4","C:P","a1","a1"]) # second action inferred piece, pass allowed
  raise "should have 2 actions" unless move.actions.size == 2
  raise "has_inferred? should be true" unless move.has_inferred?
  raise "pieces should only include explicit ones" unless move.pieces == ["C:P"]
end

run_test("Move.with_actions appends immutably") do
  move1 = Pmn::Move.new("e2","e4","C:P")
  extra = Pmn::Action.new("d7","d5","c:p")
  move2 = move1.with_actions([extra])
  raise "original must be unchanged" unless move1.actions.size == 1
  raise "new move must have 2 actions" unless move2.actions.size == 2
  raise "sequence mismatch" unless move2.to_a == ["e2","e4","C:P","d7","d5","c:p"]
end

run_test("Move.from_actions constructs correctly") do
  actions = [Pmn::Action.new("e2","e4","C:P"), Pmn::Action.new("d7","d5","c:p")]
  move = Pmn::Move.from_actions(actions)
  raise "array mismatch" unless move.to_a == ["e2","e4","C:P","d7","d5","c:p"]
end

# ------------------------- Action: construction & predicates --------------------

run_test("Action construction and core predicates") do
  a1 = Pmn::Action.new("e2","e4","C:P")  # board move, explicit
  a2 = Pmn::Action.new("*","e5","S:P")   # drop
  a3 = Pmn::Action.new("e4","*","c:p")   # capture
  a4 = Pmn::Action.new("d2","d2")        # pass/in-place, inferred

  # board move
  raise "board_to_board? expected" unless a1.board_to_board?
  raise "board_move? expected" unless a1.board_move?
  raise "piece_specified? expected" unless a1.piece_specified?
  raise "piece_valid? expected" unless a1.piece_valid?

  # drop
  raise "drop? expected" unless a2.drop?
  raise "from_reserve? expected" unless a2.from_reserve?
  raise "to_reserve? should be false" if a2.to_reserve?

  # capture
  raise "capture? expected" unless a3.capture?
  raise "to_reserve? expected" unless a3.to_reserve?

  # pass / in-place (allowed)
  raise "pass should be board_to_board?" unless a4.board_to_board?
  raise "pass should be board_move?" unless a4.board_move?
  raise "inferred? expected" unless a4.inferred?
  raise "piece_specified? false expected" if a4.piece_specified?
  raise "piece_valid? false when nil" if a4.piece_valid?
end

run_test("Action equality, hash, to_a/to_h, inspect") do
  a1 = Pmn::Action.new("e2","e4","C:P")
  a2 = Pmn::Action.new("e2","e4","C:P")
  a3 = Pmn::Action.new("e2","e4")

  raise "actions should be equal" unless a1 == a2
  raise "hash mismatch" unless a1.hash == a2.hash
  raise "different (inferred) should not equal" if a1 == a3

  raise "to_a explicit mismatch" unless a1.to_a == ["e2","e4","C:P"]
  raise "to_a inferred mismatch" unless a3.to_a == ["e2","e4"]

  h = a1.to_h
  raise "hash keys missing" unless h[:source] == "e2" && h[:destination] == "e4" && h[:piece] == "C:P"

  # Not asserting exact string, but class name should appear
  raise "inspect should include class name" unless a1.inspect.include?("Sashite::Pmn::Action")
end

run_test("Action.from_hash constructs correctly") do
  a = Pmn::Action.from_hash(source: "a1", destination: "a1", piece: nil)
  raise "from_hash should build an Action" unless a.is_a?(Pmn::Action)
  raise "inferred piece expected" unless a.inferred?
end

# ------------------------- Error handling specifics -----------------------------

run_test("Action raises InvalidLocationError on bad locations") do
  assert_raises(Pmn::InvalidLocationError) { Pmn::Action.new("ZZ99", "e4", "C:P") } # bad source
  assert_raises(Pmn::InvalidLocationError) { Pmn::Action.new("e2", "??", "C:P") }   # bad destination
end

run_test("Action raises InvalidPieceError on bad QPI") do
  assert_raises(Pmn::InvalidPieceError) { Pmn::Action.new("e2","e4","NotQPI") }
end

run_test("Pmn.parse wraps action-level errors as InvalidMoveError") do
  assert_raises(Pmn::InvalidMoveError) { Pmn.parse(["ZZ99","e4","C:P"]) }   # invalid source
  assert_raises(Pmn::InvalidMoveError) { Pmn.parse(["e2","??","C:P"]) }     # invalid destination
  assert_raises(Pmn::InvalidMoveError) { Pmn.parse(["e2","e4","NotQPI"]) }  # invalid piece
end

run_test("Pmn.parse raises on invalid PMN arrays and non-arrays") do
  assert_raises(Pmn::InvalidMoveError) { Pmn.parse(["e2"]) }         # incomplete
  assert_raises(Pmn::InvalidMoveError) { Pmn.parse("not an array") } # wrong type
end

# ------------------------- Module helpers --------------------------------------

run_test("Module helpers valid_location? and valid_piece?") do
  raise "CELL e2 should be valid" unless Pmn.valid_location?("e2")
  raise "HAND * should be valid" unless Pmn.valid_location?("*")
  raise "ZZ99 should be invalid" if Pmn.valid_location?("ZZ99")

  raise "C:P should be valid piece" unless Pmn.valid_piece?("C:P")
  raise "invalid piece should be false" if Pmn.valid_piece?("InvalidPiece")
end

# ------------------------- Light performance sanity -----------------------------

run_test("Performance sanity (light loop)") do
  200.times do
    move = Pmn.parse(["e2","e4","C:P","d7","d5"])
    raise "failed" unless move.valid?
    arr = move.to_a
    raise "array mismatch" unless arr == ["e2","e4","C:P","d7","d5"]
  end
end

puts
puts "All PMN tests passed!"
puts
