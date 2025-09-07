# frozen_string_literal: true

require "sashite/cell"
require "sashite/hand"
require "sashite/qpi"

require_relative "pmn/action"
require_relative "pmn/move"
require_relative "pmn/error"

module Sashite
  # PMN (Portable Move Notation) implementation for Ruby
  #
  # PMN is an array-based, rule-agnostic format that decomposes a move into a
  # sequence of atomic actions. Each action is 2 or 3 elements:
  #   [source, destination]            # inferred piece
  #   [source, destination, piece]     # explicit piece (QPI)
  #
  # Valid PMN arrays have length:
  #   - multiple of 3, or
  #   - multiple of 3 + 2
  # with a minimum of 2.
  #
  # See specs: https://sashite.dev/specs/pmn/1.0.0/
  module Pmn
    # Parse a PMN array into a Move object.
    #
    # @param pmn_array [Array<String>] flat array of PMN elements
    # @return [Sashite::Pmn::Move]
    # @raise [Sashite::Pmn::InvalidMoveError] if the array or any action is invalid
    #
    # @example
    #   Sashite::Pmn.parse(["e2","e4","C:P"]).actions.size # => 1
    def self.parse(pmn_array)
      raise InvalidMoveError, "PMN must be an array, got #{pmn_array.class}" unless pmn_array.is_a?(Array)

      Move.new(*pmn_array)
    end

    # Check if an array is valid PMN notation (non-raising).
    #
    # @param pmn_array [Array]
    # @return [Boolean] true if valid, false otherwise
    #
    # @example
    #   Sashite::Pmn.valid?(["e2","e4","C:P"]) # => true
    #   Sashite::Pmn.valid?(["e2"])            # => false
    def self.valid?(pmn_array)
      return false unless pmn_array.is_a?(Array)
      return false if pmn_array.empty?

      move = Move.new(*pmn_array)
      move.valid?
    rescue Error
      false
    end

    # Create a Move from Action objects.
    #
    # @param actions [Array<Sashite::Pmn::Action>]
    # @return [Sashite::Pmn::Move]
    # @raise [ArgumentError] if actions is not an Array
    #
    # @example
    #   a1 = Sashite::Pmn::Action.new("e2","e4","C:P")
    #   a2 = Sashite::Pmn::Action.new("d7","d5","c:p")
    #   move = Sashite::Pmn.from_actions([a1,a2])
    def self.from_actions(actions)
      raise ArgumentError, "Actions must be an array" unless actions.is_a?(Array)

      pmn_array = actions.flat_map(&:to_a)
      Move.new(*pmn_array)
    end

    # Validate a location string (CELL or HAND "*").
    #
    # @param location [String]
    # @return [Boolean]
    #
    # @api public
    def self.valid_location?(location)
      return false unless location.is_a?(String)

      Cell.valid?(location) || Hand.reserve?(location)
    end

    # Validate a QPI piece string.
    #
    # @param piece [String]
    # @return [Boolean]
    #
    # @api public
    def self.valid_piece?(piece)
      return false unless piece.is_a?(String)

      Qpi.valid?(piece)
    end
  end
end
