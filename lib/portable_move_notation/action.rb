# frozen_string_literal: true

module PortableMoveNotation
  # == Action
  #
  # An **Action** is the *atomic* unit of Portable Move Notation.  Each instance
  # describes **one** deterministic transformation applied to either the board
  # or the mover's reserve.
  #
  # | Field        | Meaning                                                                |
  # |--------------|------------------------------------------------------------------------|
  # | `src_square` | Integer index of the square *vacated* – or +nil+ when dropping         |
  # | `dst_square` | Integer index of the square now **occupied** by {#piece_name}          |
  # | `piece_name` | Post‑action identifier on `dst_square` (may contain prefix/suffix)     |
  # | `piece_hand` | Bare letter that enters the mover's hand – or +nil+                    |
  #
  # The implicit side‑effects are rule‑agnostic:
  # * `src_square` (when not +nil+) becomes empty.
  # * `dst_square` now contains {#piece_name}.
  # * If {#piece_hand} is set, add exactly one such piece to the mover's reserve.
  # * If `src_square` is +nil+, remove one unmodified copy of {#piece_name} from hand.
  #
  # === Examples
  #
  # @example Basic piece movement (Chess pawn e2 → e4)
  #   PortableMoveNotation::Action.new(src_square: 52, dst_square: 36, piece_name: "P")
  #
  # @example Drop from hand (Shogi pawn onto 27)
  #   PortableMoveNotation::Action.new(src_square: nil, dst_square: 27, piece_name: "p")
  #
  # @example Capture with demotion (Bishop captures +p and acquires P in hand)
  #   PortableMoveNotation::Action.new(src_square: 36, dst_square: 27, piece_name: "B", piece_hand: "P")
  #
  # @see https://sashite.dev/documents/pmn/ Portable Move Notation specification
  # @see https://sashite.dev/documents/pnn/ Piece Name Notation specification
  class Action
    # Regular expression for validating piece identifiers as per PNN.
    # Matches: optional '+'/ '-' prefix, a single ASCII letter, optional "'" suffix.
    PIECE_NAME_PATTERN = /\A[-+]?[A-Za-z]['"]?\z/

    # ------------------------------------------------------------------
    # Class helpers
    # ------------------------------------------------------------------

    # Validates that *action_data* is a structurally correct PMN **action hash**.
    # (Keys are expected to be *strings*.)
    #
    # @param action_data [Hash] Raw PMN action hash.
    # @return [Boolean] +true+ if the hash can be converted into a valid {Action}.
    def self.valid?(action_data)
      return false unless action_data.is_a?(::Hash)
      return false unless action_data.key?("dst_square") && action_data.key?("piece_name")

      new(
        src_square: action_data["src_square"],
        dst_square: action_data["dst_square"],
        piece_name: action_data["piece_name"],
        piece_hand: action_data["piece_hand"]
      )
      true
    rescue ::ArgumentError
      false
    end

    # Builds an {Action} from keyword parameters.
    #
    # @param params [Hash] Keyword parameters.
    # @option params [Integer, nil] :src_square Source coordinate, or +nil+ when dropping from hand.
    # @option params [Integer] :dst_square Destination coordinate (required).
    # @option params [String] :piece_name Post‑move piece identifier (required).
    # @option params [String, nil] :piece_hand Captured piece letter entering hand.
    # @return [Action]
    # @raise [KeyError] If +:dst_square+ or +:piece_name+ is missing.
    def self.from_params(**params)
      new(
        src_square: params[:src_square],
        dst_square: params.fetch(:dst_square),
        piece_name: params.fetch(:piece_name),
        piece_hand: params[:piece_hand]
      )
    end

    # ------------------------------------------------------------------
    # Attributes
    # ------------------------------------------------------------------

    # @return [Integer, nil] Source square (or +nil+ for drops)
    attr_reader :src_square
    # @return [Integer] Destination square
    attr_reader :dst_square
    # @return [String] Post‑move piece identifier
    attr_reader :piece_name
    # @return [String, nil] Captured piece that enters hand, or +nil+
    attr_reader :piece_hand

    # ------------------------------------------------------------------
    # Construction
    # ------------------------------------------------------------------

    # Instantiates a new {Action}.
    #
    # @param dst_square [Integer] Destination coordinate.
    # @param piece_name [String]  Post‑move piece identifier.
    # @param src_square [Integer, nil] Source coordinate or +nil+.
    # @param piece_hand [String, nil] Captured piece entering hand.
    # @raise [ArgumentError] If any value fails validation.
    def initialize(dst_square:, piece_name:, src_square: nil, piece_hand: nil)
      validate_square(src_square) unless src_square.nil?
      validate_square(dst_square)
      validate_piece_name(piece_name)
      validate_piece_hand(piece_hand) unless piece_hand.nil?

      @src_square = src_square
      @dst_square = dst_square
      @piece_name = piece_name
      @piece_hand = piece_hand

      freeze
    end

    # ------------------------------------------------------------------
    # Serialisation helpers
    # ------------------------------------------------------------------

    # Returns a **symbol‑keyed** parameter hash (useful for duplication).
    #
    # @return [Hash]
    def to_params
      {
        src_square:,
        dst_square:,
        piece_name:,
        piece_hand:
      }.compact
    end

    # Returns a **string‑keyed** hash that conforms to the PMN JSON schema.
    #
    # @return [Hash]
    def to_h
      {
        "src_square" => src_square,
        "dst_square" => dst_square,
        "piece_name" => piece_name,
        "piece_hand" => piece_hand
      }
    end

    private

    # Validates that *square* is a non‑negative integer.
    #
    # @param square [Object]
    # @raise [ArgumentError] If invalid.
    def validate_square(square)
      return if square.is_a?(::Integer) && square >= 0

      raise ::ArgumentError, "Square must be a non-negative integer"
    end

    # Validates {#piece_name} format.
    #
    # @param piece_name [Object]
    # @raise [ArgumentError] If invalid.
    def validate_piece_name(piece_name)
      return if piece_name.is_a?(::String) && piece_name.match?(PIECE_NAME_PATTERN)

      raise ::ArgumentError, "Invalid piece_name format: #{piece_name.inspect}"
    end

    # Validates {#piece_hand} format.
    #
    # @param piece_hand [Object]
    # @raise [ArgumentError] If invalid.
    def validate_piece_hand(piece_hand)
      return if piece_hand.is_a?(::String) && piece_hand.match?(/\A[A-Za-z]\z/)

      raise ::ArgumentError, "Invalid piece_hand format: #{piece_hand.inspect}"
    end
  end
end
