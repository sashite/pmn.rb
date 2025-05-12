# frozen_string_literal: true

module PortableMoveNotation
  # Represents a PMN move - a collection of one or more atomic actions
  # that together describe a game state transition
  #
  # A move may consist of one or more actions, allowing for representation
  # of complex moves such as castling, en passant captures, or multi-step
  # actions in various abstract strategy games.
  #
  # @example Creating a simple move
  #   action = Action.new(src_square: 52, dst_square: 36, piece_name: "P")
  #   move = Move.new(action)
  #
  # @example Creating a castling move
  #   king_action = Action.new(src_square: 60, dst_square: 62, piece_name: "K")
  #   rook_action = Action.new(src_square: 63, dst_square: 61, piece_name: "R")
  #   castling = Move.new(king_action, rook_action)
  #
  # @see https://sashite.dev/documents/pmn/1.0.0/ PMN Specification
  class Move
    # Validates a PMN array data structure
    #
    # @param pmn_data [Array] PMN data to validate
    # @return [Boolean] true if valid, false otherwise
    def self.valid?(pmn_data)
      return false unless pmn_data.is_a?(Array) && !pmn_data.empty?

      pmn_data.all? { |action_data| Action.valid?(action_data) }
    end

    # Creates a Move instance from a JSON string in PMN format
    #
    # @param json_string [String] JSON string to parse
    # @return [Move] A new move instance
    # @raise [JSON::ParserError] if the JSON string is malformed
    # @raise [KeyError] if required fields are missing
    def self.from_json(json_string)
      json_data = ::JSON.parse(json_string)

      actions = json_data.map do |action_data|
        Action.new(
          src_square: action_data["src_square"],
          dst_square: action_data.fetch("dst_square"),
          piece_name: action_data.fetch("piece_name"),
          piece_hand: action_data["piece_hand"]
        )
      end

      new(*actions)
    end

    # Creates a Move instance from an array of PMN action hashes
    #
    # @param pmn_array [Array<Hash>] Array of PMN action hashes
    # @return [Move] A new move instance
    # @raise [KeyError] if required fields are missing
    def self.from_pmn(pmn_array)
      actions = pmn_array.map do |action_data|
        Action.new(
          src_square: action_data["src_square"],
          dst_square: action_data.fetch("dst_square"),
          piece_name: action_data.fetch("piece_name"),
          piece_hand: action_data["piece_hand"]
        )
      end

      new(*actions)
    end

    # Creates a Move instance from a parameters hash
    #
    # @param params [Hash] Move parameters
    # @option params [Array<Action, Hash>] :actions List of actions or action params
    # @return [Move] A new move instance
    # @raise [KeyError] if the :actions key is missing
    def self.from_params(**params)
      actions = Array(params.fetch(:actions)).map do |action_params|
        if action_params.is_a?(Action)
          action_params
        else
          Action.from_params(**action_params)
        end
      end

      new(*actions)
    end

    # The list of actions that compose this move
    #
    # @return [Array<Action>] List of action objects (frozen)
    attr_reader :actions

    # Initializes a new move with the given actions
    #
    # @param actions [Array<Action>] List of actions as splat arguments
    # @raise [ArgumentError] if actions is not a non-empty array of Action objects
    def initialize(*actions)
      validate_actions(*actions)
      @actions = actions.freeze

      freeze
    end

    # Converts the move to PMN format (array of hashes)
    #
    # @return [Array<Hash>] PMN representation of the move
    def to_pmn
      actions.map(&:to_h)
    end

    # Converts the move to a JSON string
    #
    # @return [String] JSON string of the move in PMN format
    def to_json(*_args)
      ::JSON.generate(to_pmn)
    end

    private

    # Validates the actions array
    #
    # @param actions [Object] Actions to validate
    # @raise [ArgumentError] if actions is not a non-empty array of Action objects
    def validate_actions(*actions)
      return if !actions.empty? && actions.all?(Action)

      raise ::ArgumentError, "Actions must be a non-empty array of Action objects"
    end
  end
end

require_relative "action"
