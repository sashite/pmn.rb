# frozen_string_literal: true

require "sashite/cell"
require "sashite/hand"
require "sashite/qpi"
require_relative "error"

module Sashite
  module Pmn
    # Represents an atomic action within a PMN move.
    #
    # Each action encodes a single transformation:
    #   [source, destination]            # inferred piece
    #   [source, destination, piece]     # explicit QPI piece
    #
    # Locations are either CELL coordinates or HAND ("*").
    # Actions where source == destination are allowed (pass / in-place).
    class Action
      # @return [String] the source location (CELL or "*")
      attr_reader :source

      # @return [String] the destination location (CELL or "*")
      attr_reader :destination

      # @return [String, nil] the piece in QPI format, or nil if inferred
      attr_reader :piece

      # Create an immutable action.
      #
      # @param source [String] CELL or "*"
      # @param destination [String] CELL or "*"
      # @param piece [String, nil] QPI string (optional)
      # @raise [Error::Location] if source/destination are invalid
      # @raise [Error::Piece] if piece is provided but invalid
      def initialize(source, destination, piece = nil)
        validate_source!(source)
        validate_destination!(destination)
        validate_piece!(piece) if piece

        @source = source.freeze
        @destination = destination.freeze
        @piece = piece&.freeze

        freeze
      end

      # ---------- Predicates -------------------------------------------------

      # @return [Boolean] true if piece is not explicitly specified
      def inferred?
        piece.nil?
      end

      # @return [Boolean] true if a piece string is explicitly specified
      def piece_specified?
        !piece.nil?
      end

      # @return [Boolean] true if a specified piece is valid QPI (false if none)
      def piece_valid?
        return false if piece.nil?

        Qpi.valid?(piece)
      end

      # @return [Boolean] true if source is HAND ("*")
      def from_reserve?
        Hand.reserve?(source)
      end

      # @return [Boolean] true if destination is HAND ("*")
      def to_reserve?
        Hand.reserve?(destination)
      end

      # @return [Boolean] true if both endpoints are board locations
      def board_to_board?
        Cell.valid?(source) && Cell.valid?(destination)
      end

      # @return [Boolean] true if the action places from reserve to board
      def drop?
        from_reserve? && Cell.valid?(destination)
      end

      # @return [Boolean] true if the action takes from board to reserve
      def capture?
        Cell.valid?(source) && to_reserve?
      end

      # @return [Boolean] true when neither drop nor capture
      def board_move?
        !drop? && !capture?
      end

      # ---------- Conversions -----------------------------------------------

      # @return [Array<String>] 2 elems if inferred, 3 if explicit
      def to_a
        inferred? ? [source, destination] : [source, destination, piece]
      end

      # @return [Hash] { source:, destination:, piece: } (piece omitted if nil)
      def to_h
        { source: source, destination: destination, piece: piece }.compact
      end

      # ---------- Validation & Equality -------------------------------------

      # @return [Boolean] true if all components are valid
      def valid?
        valid_location?(source) &&
          valid_location?(destination) &&
          (piece.nil? || Qpi.valid?(piece))
      end

      # @param other [Object]
      # @return [Boolean] equality by source, destination, piece
      def ==(other)
        return false unless other.is_a?(Action)

        source == other.source &&
          destination == other.destination &&
          piece == other.piece
      end
      alias eql? ==

      # @return [Integer]
      def hash
        [source, destination, piece].hash
      end

      # @return [String]
      def inspect
        attrs = ["source=#{source.inspect}", "destination=#{destination.inspect}"]
        attrs << "piece=#{piece.inspect}" if piece
        "#<#{self.class.name} #{attrs.join(' ')}>"
      end

      # ---------- Factories --------------------------------------------------

      # Build from a hash with keys :source, :destination, optional :piece.
      #
      # @param hash [Hash]
      # @return [Action]
      # @raise [ArgumentError] if required keys are missing
      def self.from_hash(hash)
        raise ArgumentError, "Hash must include :source" unless hash.key?(:source)
        raise ArgumentError, "Hash must include :destination" unless hash.key?(:destination)

        new(hash[:source], hash[:destination], hash[:piece])
      end

      private

      # ---------- Internal validation helpers -------------------------------

      # @param src [String]
      # @raise [Error::Location]
      def validate_source!(src)
        return if valid_location?(src)

        raise Error::Location, "Invalid source location: #{src.inspect}"
      end

      # @param dst [String]
      # @raise [Error::Location]
      def validate_destination!(dst)
        return if valid_location?(dst)

        raise Error::Location, "Invalid destination location: #{dst.inspect}"
      end

      # @param qpi [String, nil]
      # @raise [Error::Piece]
      def validate_piece!(qpi)
        return if qpi.nil?
        return if Qpi.valid?(qpi)

        raise Error::Piece, "Invalid piece QPI format: #{qpi.inspect}"
      end

      # @param location [String]
      # @return [Boolean] true if CELL or HAND ("*")
      def valid_location?(location)
        Cell.valid?(location) || Hand.reserve?(location)
      end
    end
  end
end
