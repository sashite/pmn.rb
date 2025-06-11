# frozen_string_literal: true

module PortableMoveNotation
  # == Action
  #
  # An **Action** is the *atomic* unit of Portable Move Notation. Each instance
  # describes **one** deterministic transformation applied to either the board
  # or the mover's reserve using the PMN v1.0.0 array format.
  #
  # PMN v1.0.0 uses a 4-element array format:
  # `[source_square, destination_square, piece_name, captured_piece]`
  #
  # | Index | Field            | Type           | Meaning                                                    |
  # |-------|------------------|----------------|------------------------------------------------------------|
  # | 0     | `src_square`     | String or nil  | Square vacated (nil when dropping from hand)              |
  # | 1     | `dst_square`     | String         | Square now occupied by piece_name                          |
  # | 2     | `piece_name`     | String         | Post-action piece identifier (may contain modifiers)      |
  # | 3     | `captured_piece` | String or nil  | Piece entering mover's reserve (nil if nothing captured)  |
  #
  # The implicit side‑effects are rule‑agnostic:
  # * `src_square` (when not nil) becomes empty.
  # * `dst_square` now contains `piece_name`.
  # * If `captured_piece` is set, add exactly one such piece to the mover's reserve.
  # * If `src_square` is nil, remove one copy of `piece_name` from hand.
  #
  # === Examples
  #
  # @example Basic piece movement (Chess pawn e2 → e4)
  #   PortableMoveNotation::Action.new("e2", "e4", "P", nil)
  #
  # @example Drop from hand (Shogi pawn onto 27)
  #   PortableMoveNotation::Action.new(nil, "27", "p", nil)
  #
  # @example Capture with promotion (Bishop captures +p, promotes, P enters hand)
  #   PortableMoveNotation::Action.new("36", "27", "+B", "P")
  #
  # @see https://sashite.dev/documents/pmn/1.0.0/ Portable Move Notation specification
  class Action
    # ------------------------------------------------------------------
    # Class helpers
    # ------------------------------------------------------------------

    # Validates that *action_data* is a structurally correct PMN **action array**.
    # Expects a 4-element array following the PMN v1.0.0 format.
    #
    # @param action_data [Array] Raw PMN action array.
    # @return [Boolean] +true+ if the array can be converted into a valid {Action}.
    def self.valid?(action_data)
      return false unless action_data.is_a?(::Array)
      return false unless action_data.size == 4

      src_square, dst_square, piece_name, captured_piece = action_data

      # Validate dst_square and piece_name are non-empty strings
      return false unless dst_square.is_a?(::String) && !dst_square.empty?
      return false unless piece_name.is_a?(::String) && !piece_name.empty?

      # Validate src_square is either nil or non-empty string
      return false unless src_square.nil? || (src_square.is_a?(::String) && !src_square.empty?)

      # Validate captured_piece is either nil or non-empty string
      return false unless captured_piece.nil? || (captured_piece.is_a?(::String) && !captured_piece.empty?)

      true
    rescue StandardError
      false
    end

    # Builds an {Action} from an array following PMN v1.0.0 format.
    #
    # @param action_array [Array] 4-element array [src_square, dst_square, piece_name, captured_piece]
    # @return [Action]
    # @raise [ArgumentError] If array format is invalid.
    def self.from_array(action_array)
      raise ArgumentError, "Expected 4-element array" unless action_array.is_a?(::Array) && action_array.size == 4

      src_square, dst_square, piece_name, captured_piece = action_array
      new(src_square, dst_square, piece_name, captured_piece)
    end

    # ------------------------------------------------------------------
    # Attributes
    # ------------------------------------------------------------------

    # @return [String, nil] Source square (or nil for drops)
    attr_reader :src_square
    # @return [String] Destination square
    attr_reader :dst_square
    # @return [String] Post‑action piece identifier
    attr_reader :piece_name
    # @return [String, nil] Captured piece that enters hand, or nil
    attr_reader :captured_piece

    # ------------------------------------------------------------------
    # Construction
    # ------------------------------------------------------------------

    # Instantiates a new {Action} using PMN v1.0.0 array semantics.
    #
    # @param src_square [String, nil] Source coordinate or nil for drops.
    # @param dst_square [String] Destination coordinate (required).
    # @param piece_name [String] Post‑action piece identifier (required).
    # @param captured_piece [String, nil] Captured piece entering hand.
    # @raise [ArgumentError] If any value fails validation.
    def initialize(src_square, dst_square, piece_name, captured_piece)
      validate_square(src_square) unless src_square.nil?
      validate_square(dst_square)
      validate_piece_name(piece_name)
      validate_captured_piece(captured_piece) unless captured_piece.nil?

      @src_square = src_square
      @dst_square = dst_square
      @piece_name = piece_name
      @captured_piece = captured_piece

      freeze
    end

    # ------------------------------------------------------------------
    # Serialisation helpers
    # ------------------------------------------------------------------

    # Returns the PMN v1.0.0 array representation.
    # This is the canonical format for JSON serialization.
    #
    # @return [Array] 4-element array [src_square, dst_square, piece_name, captured_piece]
    def to_a
      [src_square, dst_square, piece_name, captured_piece]
    end

    # Alias for to_a for backward compatibility
    alias to_pmn to_a

    # ------------------------------------------------------------------
    # Comparison and inspection
    # ------------------------------------------------------------------

    # Compare actions based on their array representation
    def ==(other)
      other.is_a?(Action) && to_a == other.to_a
    end

    # Hash based on array representation
    def hash
      to_a.hash
    end

    def eql?(other)
      self == other
    end

    # Human-readable string representation
    def inspect
      "#<#{self.class.name} #{to_a.inspect}>"
    end

    def to_s
      to_a.to_s
    end

    private

    # Validates that *square* is a non‑empty string.
    #
    # @param square [Object]
    # @raise [ArgumentError] If invalid.
    def validate_square(square)
      return if square.is_a?(::String) && !square.empty?

      raise ::ArgumentError, "Square must be a non-empty string, got #{square.inspect}"
    end

    # Validates piece_name format.
    # PMN v1.0.0 allows any non-empty UTF-8 string for piece identifiers.
    #
    # @param piece_name [Object]
    # @raise [ArgumentError] If invalid.
    def validate_piece_name(piece_name)
      return if piece_name.is_a?(::String) && !piece_name.empty?

      raise ::ArgumentError, "Piece name must be a non-empty string, got #{piece_name.inspect}"
    end

    # Validates captured_piece format.
    # PMN v1.0.0 allows any non-empty UTF-8 string for piece identifiers.
    #
    # @param captured_piece [Object]
    # @raise [ArgumentError] If invalid.
    def validate_captured_piece(captured_piece)
      return if captured_piece.is_a?(::String) && !captured_piece.empty?

      raise ::ArgumentError, "Captured piece must be a non-empty string, got #{captured_piece.inspect}"
    end
  end
end
