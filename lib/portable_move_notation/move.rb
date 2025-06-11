# frozen_string_literal: true

require "json"

module PortableMoveNotation
  # == Move
  #
  # A **Move** is an *ordered list* of {Action} instances that, applied **in
  # order**, realise a deterministic change of game state under Portable Move
  # Notation (PMN) v1.0.0. A move can be as small as a single pawn push or as
  # large as a compound fairy‐move that relocates several pieces at once.
  #
  # PMN v1.0.0 uses an array-of-arrays format where each inner array represents
  # a single action: `[source_square, destination_square, piece_name, captured_piece]`
  #
  # The class is deliberately **rule‑agnostic**: it guarantees only that the
  # underlying data *matches the PMN schema*. Whether the move is *legal* in a
  # given game is beyond its responsibility and must be enforced by an engine
  # or referee layer.
  #
  # === Quick start
  #
  # ```ruby
  # require "portable_move_notation"
  #
  # # Plain chess pawn move: e2 → e4
  # pawn = PortableMoveNotation::Action.new("e2", "e4", "P", nil)
  # move = PortableMoveNotation::Move.new(pawn)
  # puts move.to_json
  # # => [["e2","e4","P",null]]
  #
  # parsed = PortableMoveNotation::Move.from_json(move.to_json)
  # parsed.actions.first.dst_square  # => "e4"
  # ```
  #
  # === Composite example (Chess kingside castling)
  #
  # ```ruby
  # king = PortableMoveNotation::Action.new("e1", "g1", "K", nil)
  # rook = PortableMoveNotation::Action.new("h1", "f1", "R", nil)
  # castle = PortableMoveNotation::Move.new(king, rook)
  # ```
  #
  # @see https://sashite.dev/documents/pmn/1.0.0/ Portable Move Notation specification
  class Move
    # --------------------------------------------------------------------
    # Class helpers
    # --------------------------------------------------------------------

    # Validates that *pmn_data* is an **array of PMN action arrays**.
    # The method does **not** instantiate {Action} objects on success; it merely
    # checks that each element *could* be turned into one.
    #
    # @param pmn_data [Array<Array>] Raw PMN structure (array of 4-element arrays).
    # @return [Boolean] +true+ when every element passes {Action.valid?}.
    #
    # @example Validate PMN parsed from JSON
    #   data = JSON.parse('[["e2","e4","P",null]]')
    #   PortableMoveNotation::Move.valid?(data)  # => true
    def self.valid?(pmn_data)
      return false unless pmn_data.is_a?(::Array) && !pmn_data.empty?

      pmn_data.all? { |action_array| Action.valid?(action_array) }
    end

    # Constructs a {Move} from its canonical **JSON** representation.
    #
    # @param json_string [String] PMN‑formatted JSON (array of action arrays).
    # @return [Move]
    # @raise [JSON::ParserError] If +json_string+ is not valid JSON.
    # @raise [ArgumentError] If an action array is malformed.
    #
    # @example
    #   json = '[["e2","e4","P",null]]'
    #   PortableMoveNotation::Move.from_json(json)
    def self.from_json(json_string)
      from_pmn(::JSON.parse(json_string))
    end

    # Constructs a {Move} from an *already parsed* PMN array.
    #
    # @param pmn_array [Array<Array>] PMN action arrays (4-element arrays).
    # @return [Move]
    # @raise [ArgumentError] If an action array is malformed.
    def self.from_pmn(pmn_array)
      actions = pmn_array.map do |action_array|
        Action.from_array(action_array)
      end
      new(*actions)
    end

    # --------------------------------------------------------------------
    # Attributes & construction
    # --------------------------------------------------------------------

    # @return [Array<Action>] Ordered, frozen list of actions.
    attr_reader :actions

    # Creates a new {Move}.
    #
    # @param actions [Array<Action>] One or more {Action} objects.
    # @raise [ArgumentError] If +actions+ is empty or contains non‑Action items.
    def initialize(*actions)
      validate_actions(actions)
      @actions = actions.freeze
      freeze
    end

    # --------------------------------------------------------------------
    # Serialisation helpers
    # --------------------------------------------------------------------

    # Converts the move to an **array of PMN action arrays**.
    # This is the canonical PMN v1.0.0 format.
    #
    # @return [Array<Array>] Array of 4-element action arrays
    def to_pmn
      actions.map(&:to_a)
    end

    # Alias for to_pmn for clarity
    alias to_a to_pmn

    # Converts the move to a **JSON string** following PMN v1.0.0 format.
    #
    # @return [String] JSON representation as array of action arrays
    def to_json(*_args)
      ::JSON.generate(to_pmn)
    end

    # --------------------------------------------------------------------
    # Comparison and inspection
    # --------------------------------------------------------------------

    # Compare moves based on their PMN array representation
    def ==(other)
      other.is_a?(Move) && to_pmn == other.to_pmn
    end

    # Hash based on PMN array representation
    def hash
      to_pmn.hash
    end

    def eql?(other)
      self == other
    end

    # Human-readable string representation
    def inspect
      "#<#{self.class.name} #{to_pmn.inspect}>"
    end

    def to_s
      to_pmn.to_s
    end

    # --------------------------------------------------------------------
    # Utility methods
    # --------------------------------------------------------------------

    # Number of actions in this move
    def size
      actions.size
    end

    # Check if move is empty (shouldn't happen with current validation)
    def empty?
      actions.empty?
    end

    # Iterate over actions
    def each(&)
      actions.each(&)
    end

    # Access individual actions by index
    def [](index)
      actions[index]
    end

    private

    # Ensures +actions+ is a non‑empty array of {Action} instances.
    #
    # @param actions [Array<Object>] Items to validate.
    # @raise [ArgumentError] If validation fails.
    def validate_actions(actions)
      return if actions.any? && actions.all?(Action)

      raise ::ArgumentError, "Actions must be a non-empty array of Action objects"
    end
  end
end

require_relative "action"
