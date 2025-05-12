# frozen_string_literal: true

module PortableMoveNotation
  # Represents an atomic action in PMN format
  #
  # An Action is the fundamental unit of PMN, representing a single piece movement
  # from a source square to a destination square, with optional capture information.
  #
  # PMN actions consist of four primary components:
  # - src_square: Source coordinate (or nil for drops)
  # - dst_square: Destination coordinate (required)
  # - piece_name: Identifier of the moving piece (required)
  # - piece_hand: Identifier of any captured piece (or nil)
  #
  # @example Basic piece movement
  #   Action.new(src_square: 52, dst_square: 36, piece_name: "P")
  #
  # @example Piece drop (from outside the board)
  #   Action.new(src_square: nil, dst_square: 27, piece_name: "p")
  #
  # @example Capture with piece becoming available for dropping
  #   Action.new(src_square: 33, dst_square: 24, piece_name: "+P", piece_hand: "R")
  #
  # @see https://sashite.dev/documents/pmn/1.0.0/ PMN Specification
  # @see https://sashite.dev/documents/pnn/1.0.0/ PNN Specification for piece format
  class Action
    # Validates a PMN action hash
    #
    # @param action_data [Hash] PMN action data to validate
    # @return [Boolean] true if valid, false otherwise
    def self.valid?(action_data)
      return false unless action_data.is_a?(::Hash)
      return false unless action_data.key?("dst_square") && action_data.key?("piece_name")

      begin
        # Use existing validation logic by attempting to create an instance
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
    end

    # Creates an Action instance from parameters
    #
    # @param params [Hash] Action parameters
    # @return [Action] A new action instance
    # @raise [KeyError] if required parameters are missing
    def self.from_params(**params)
      new(
        src_square: params[:src_square],
        dst_square: params.fetch(:dst_square),
        piece_name: params.fetch(:piece_name),
        piece_hand: params[:piece_hand]
      )
    end

    # The source coordinate of the action, or nil for drops
    # @return [Integer, nil] Source square coordinate
    attr_reader :src_square

    # The destination coordinate of the action
    # @return [Integer] Destination square coordinate
    attr_reader :dst_square

    # The piece identifier in PNN format
    # @return [String] Piece name
    attr_reader :piece_name

    # The identifier of any captured piece that becomes available for dropping, or nil
    # @return [String, nil] Captured piece identifier
    attr_reader :piece_hand

    # Initializes a new action
    #
    # @param src_square [Integer, nil] Source square (nil for placements from outside the board)
    # @param dst_square [Integer] Destination square (required)
    # @param piece_name [String] Piece identifier in PNN format (required)
    # @param piece_hand [String, nil] Captured piece identifier that becomes droppable, or nil
    # @raise [ArgumentError] if any validation fails
    def initialize(dst_square:, piece_name:, src_square: nil, piece_hand: nil)
      # Input validation
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

    # Converts the action to a parameter hash
    #
    # @return [Hash] Parameter hash representation of the action
    def to_params
      {
        src_square:,
        dst_square:,
        piece_name:,
        piece_hand:
      }.compact
    end

    # Converts the action to a PMN-compatible hash
    #
    # This creates a hash with string keys as required by the PMN JSON format
    #
    # @return [Hash] PMN-compatible hash representation
    def to_h
      {
        "src_square" => src_square,
        "dst_square" => dst_square,
        "piece_name" => piece_name,
        "piece_hand" => piece_hand
      }
    end

    private

    # Validates that a square coordinate is a non-negative integer
    #
    # @param square [Object] Value to validate
    # @raise [ArgumentError] if the value is not a non-negative integer
    def validate_square(square)
      return if square.is_a?(::Integer) && square >= 0

      raise ::ArgumentError, "Square must be a non-negative integer"
    end

    # Validates the piece name format according to PNN specification
    #
    # @param piece_name [Object] Piece name to validate
    # @raise [ArgumentError] if the format is invalid
    def validate_piece_name(piece_name)
      return if piece_name.is_a?(::String) && piece_name.match?(/\A[-+]?[a-zA-Z][=<>]?\z/)

      raise ::ArgumentError, "Invalid piece_name format: #{piece_name}"
    end

    # Validates the piece hand format according to PNN specification
    #
    # Piece hand must be a single letter with no modifiers
    #
    # @param piece_hand [Object] Piece hand value to validate
    # @raise [ArgumentError] if the format is invalid
    def validate_piece_hand(piece_hand)
      return if piece_hand.is_a?(::String) && piece_hand.match?(/\A[a-zA-Z]\z/)

      raise ::ArgumentError, "Invalid piece_hand format: #{piece_hand}"
    end
  end
end
