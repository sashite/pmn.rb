# frozen_string_literal: true

module Sashite
  module Pmn
    # Base class for all PMN-related errors
    class Error < StandardError; end

    # Raised when a PMN move (sequence) is malformed or invalid
    class InvalidMoveError < Error; end

    # Raised when an atomic action is malformed or fails validation
    class InvalidActionError < Error; end

    # Raised when a location is neither a valid CELL coordinate nor HAND ("*")
    class InvalidLocationError < InvalidActionError; end

    # Raised when a piece identifier is not valid QPI
    class InvalidPieceError < InvalidActionError; end
  end
end
