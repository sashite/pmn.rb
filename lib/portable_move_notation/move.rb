# frozen_string_literal: true

require "json"

module PortableMoveNotation
  # == Move
  #
  # A **Move** is an *ordered list* of {Action} instances that, applied **in
  # order**, realise a deterministic change of game state under Portable Move
  # Notation (PMN).  A move can be as small as a single pawn push or as large as
  # a compound fairy‐move that relocates several pieces at once.
  #
  # The class is deliberately **rule‑agnostic**: it guarantees only that the
  # underlying data *matches the PMN schema*.  Whether the move is *legal* in a
  # given game is beyond its responsibility and must be enforced by an engine
  # or referee layer.
  #
  # === Quick start
  #
  # ```ruby
  # require "portable_move_notation"
  #
  # # Plain chess pawn move: e2 → e4
  # pawn = PortableMoveNotation::Action.new(
  #   src_square: 52,
  #   dst_square: 36,
  #   piece_name: "P"
  # )
  #
  # move = PortableMoveNotation::Move.new(pawn)
  # puts move.to_json
  # # => JSON representation of the move
  #
  # parsed = PortableMoveNotation::Move.from_json(move.to_json)
  # parsed.actions.first.dst_square  # => 36
  # ```
  #
  # === Composite example (Chess kingside castling)
  #
  # ```ruby
  # king = PortableMoveNotation::Action.new(
  #   src_square: 60, dst_square: 62, piece_name: "K"
  # )
  # rook = PortableMoveNotation::Action.new(
  #   src_square: 63, dst_square: 61, piece_name: "R"
  # )
  #
  # castle = PortableMoveNotation::Move.new(king, rook)
  # ```
  #
  # @see https://sashite.dev/documents/pmn/ Portable Move Notation specification
  class Move
    # --------------------------------------------------------------------
    # Class helpers
    # --------------------------------------------------------------------

    # Validates that *pmn_data* is an **array of PMN action hashes**.
    # The method does **not** instantiate {Action} objects on success; it merely
    # checks that each element *could* be turned into one.
    #
    # @param pmn_data [Array<Hash>] Raw PMN structure (commonly the result of
    #   `JSON.parse`).
    # @return [Boolean] +true+ when every element passes {Action.valid?}.
    #
    # @example Validate PMN parsed from JSON
    #   data = JSON.parse('[{"dst_square":27,"piece_name":"p"}]')
    #   PortableMoveNotation::Move.valid?(data)  # => true
    def self.valid?(pmn_data)
      return false unless pmn_data.is_a?(::Array) && !pmn_data.empty?

      pmn_data.all? { |hash| Action.valid?(hash) }
    end

    # Constructs a {Move} from its canonical **JSON** representation.
    #
    # @param json_string [String] PMN‑formatted JSON.
    # @return [Move]
    # @raise [JSON::ParserError] If +json_string+ is not valid JSON.
    # @raise [KeyError] If an action hash lacks required keys.
    #
    # @example
    #   json = '[{"src_square":nil,"dst_square":27,"piece_name":"p"}]'
    #   PortableMoveNotation::Move.from_json(json)
    def self.from_json(json_string)
      from_pmn(::JSON.parse(json_string))
    end

    # Constructs a {Move} from an *already parsed* PMN array.
    #
    # @param pmn_array [Array<Hash>] PMN action hashes (string keys).
    # @return [Move]
    # @raise [KeyError] If an action hash lacks required keys.
    def self.from_pmn(pmn_array)
      actions = pmn_array.map do |hash|
        Action.new(
          src_square: hash["src_square"],
          dst_square: hash.fetch("dst_square"),
          piece_name: hash.fetch("piece_name"),
          piece_hand: hash["piece_hand"]
        )
      end
      new(*actions)
    end

    # Constructs a {Move} from keyword parameters.
    #
    # @param actions [Array<Action, Hash>] One or more {Action} objects *or*
    #   parameter hashes accepted by {Action.from_params}.
    # @return [Move]
    # @raise [KeyError] If +actions+ is missing.
    #
    # @example
    #   Move.from_params(actions: [src_square: nil, dst_square: 27, piece_name: "p"])
    def self.from_params(actions:)
      array = Array(actions).map do |obj|
        obj.is_a?(Action) ? obj : Action.from_params(**obj)
      end
      new(*array)
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

    # Converts the move to an **array of PMN hashes** (string keys).
    #
    # @return [Array<Hash>]
    def to_pmn
      actions.map(&:to_h)
    end

    # Converts the move to a **JSON string**.
    #
    # @return [String]
    def to_json(*_args)
      ::JSON.generate(to_pmn)
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
