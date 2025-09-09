# frozen_string_literal: true

module Sashite
  module Pmn
    # Base error namespace for PMN.
    #
    # Usage patterns:
    #   rescue Sashite::Pmn::Error => e
    #   rescue Sashite::Pmn::Error::Move
    #   rescue Sashite::Pmn::Error::Location, Sashite::Pmn::Error::Piece
    class Error < ::StandardError
      # Raised when a PMN move (sequence) is malformed or invalid.
      #
      # @example
      #   begin
      #     Sashite::Pmn::Move.new("e2")  # Incomplete action
      #   rescue Sashite::Pmn::Error::Move => e
      #     warn "Invalid move sequence: #{e.message}"
      #   end
      class Move < Error; end

      # Raised when an atomic action is malformed or fails validation.
      #
      # @example
      #   begin
      #     Sashite::Pmn::Action.new("invalid", "e4", "C:P")
      #   rescue Sashite::Pmn::Error::Action => e
      #     warn "Invalid atomic action: #{e.message}"
      #   end
      class Action < Error; end

      # Raised when a location is neither a valid CELL coordinate nor HAND ("*").
      #
      # @example
      #   begin
      #     Sashite::Pmn::Action.new("ZZ99", "e4", "C:P")
      #   rescue Sashite::Pmn::Error::Location => e
      #     warn "Invalid location: #{e.message}"
      #   end
      class Location < Action; end

      # Raised when a piece identifier is not valid QPI format.
      #
      # @example
      #   begin
      #     Sashite::Pmn::Action.new("e2", "e4", "NotQPI")
      #   rescue Sashite::Pmn::Error::Piece => e
      #     warn "Invalid piece QPI: #{e.message}"
      #   end
      class Piece < Action; end
    end
  end
end
