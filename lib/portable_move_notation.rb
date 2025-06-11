# frozen_string_literal: true

# Portable Move Notation module
#
# PMN v1.0.0 implementation providing rule-agnostic representation of
# state-changing actions in abstract strategy board games.
#
# This implementation follows the PMN v1.0.0 specification which uses
# an array-of-arrays format: each action is a 4-element array containing
# [source_square, destination_square, piece_name, captured_piece].
#
# @see https://sashite.dev/documents/pmn/1.0.0/ PMN v1.0.0 Specification
# @see https://sashite.dev/schemas/pmn/1.0.0/schema.json JSON Schema
module PortableMoveNotation
  # Schema URL for validation
  SCHEMA_URL = "https://sashite.dev/schemas/pmn/1.0.0/schema.json"

  # Quick validation method for PMN data
  #
  # @param pmn_data [Array] Array of action arrays to validate
  # @return [Boolean] true if data conforms to PMN v1.0.0 format
  def self.valid?(pmn_data)
    Move.valid?(pmn_data)
  end

  # Parse PMN JSON string into a Move object
  #
  # @param json_string [String] JSON string containing PMN data
  # @return [Move] Parsed move object
  # @raise [JSON::ParserError] If JSON is invalid
  # @raise [ArgumentError] If PMN structure is invalid
  def self.parse(json_string)
    Move.from_json(json_string)
  end

  # Generate PMN JSON from a Move object
  #
  # @param move [Move] Move object to serialize
  # @return [String] JSON string in PMN v1.0.0 format
  def self.generate(move)
    move.to_json
  end
end

require_relative File.join("portable_move_notation", "move")
