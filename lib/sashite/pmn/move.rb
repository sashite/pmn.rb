# frozen_string_literal: true

require_relative "action"
require_relative "error"

module Sashite
  module Pmn
    # Represents a complete move in PMN notation.
    #
    # A Move is a sequence of one or more atomic actions described by a flat list
    # of elements. Every 2 or 3 consecutive elements form an action:
    #   [source, destination]            # inferred piece
    #   [source, destination, piece]     # explicit QPI piece
    #
    # Valid lengths: multiple of 3 OR multiple of 3 + 2 (minimum 2).
    class Move
      # @return [Array<Action>] ordered sequence of actions
      attr_reader :actions

      # @return [Array<String>] original PMN elements (frozen)
      attr_reader :pmn_array

      # Create a Move from PMN elements (variadic only).
      #
      # @param pmn_elements [Array<String>] passed as individual args
      # @raise [Error::Move] if called with a single Array or if invalid
      #
      # @example
      #   Move.new("e2","e4","C:P")
      #   Move.new("e2","e4")
      def initialize(*pmn_elements)
        # single-array form is intentionally not supported (entropy reduction)
        if pmn_elements.size == 1 && pmn_elements.first.is_a?(Array)
          raise Error::Move,
                'PMN must be passed as individual arguments, e.g. Move.new("e2","e4","C:P")'
        end

        validate_array!(pmn_elements)
        @pmn_array = pmn_elements.dup.freeze
        @actions   = parse_actions(@pmn_array).freeze
        validate_actions!
        freeze
      end

      # @return [Boolean] true if PMN length is valid and all actions are valid
      def valid?
        valid_length? && actions.all?(&:valid?)
      rescue StandardError
        false
      end

      # Shape / structure -----------------------------------------------------

      # @return [Boolean] exactly one action?
      def simple?
        actions.size == 1
      end

      # @return [Boolean] multiple actions?
      def compound?
        actions.size > 1
      end

      # @return [Action, nil]
      def first_action
        actions.first
      end

      # @return [Action, nil]
      def last_action
        actions.last
      end

      # @return [Integer] number of actions
      def size
        actions.size
      end
      alias length size

      # @return [Boolean] true if no actions
      def empty?
        actions.empty?
      end

      # Content helpers -------------------------------------------------------

      # @return [Boolean] any drop?
      def has_drops?
        actions.any?(&:drop?)
      end

      # @return [Boolean] any capture?
      def has_captures?
        actions.any?(&:capture?)
      end

      # @return [Array<Action>] only board-to-board actions
      def board_moves
        actions.select(&:board_to_board?)
      end

      # @return [Array<String>] unique sources
      def sources
        actions.map(&:source).uniq
      end

      # @return [Array<String>] unique destinations
      def destinations
        actions.map(&:destination).uniq
      end

      # @return [Array<String>] unique specified pieces (excludes inferred)
      def pieces
        actions.filter_map(&:piece).uniq
      end

      # @return [Boolean] true if any action has inferred piece
      def has_inferred?
        actions.any?(&:inferred?)
      end

      # Conversion ------------------------------------------------------------

      # @return [Array<String>] copy of original PMN elements
      def to_a
        pmn_array.dup
      end

      # Equality / hashing / debug -------------------------------------------

      # @param other [Object]
      # @return [Boolean] equality by original PMN elements
      def ==(other)
        return false unless other.is_a?(Move)

        pmn_array == other.pmn_array
      end
      alias eql? ==

      # @return [Integer]
      def hash
        pmn_array.hash
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} actions=#{actions.size} pmn=#{pmn_array.inspect}>"
      end

      # Functional composition -----------------------------------------------

      # @param actions_to_add [Array<Action>] actions to append
      # @return [Move] new Move with appended actions
      def with_actions(actions_to_add)
        combined = pmn_array + actions_to_add.flat_map(&:to_a)
        self.class.new(*combined)
      end

      # Build a move from Action objects.
      #
      # @param actions [Array<Action>]
      # @return [Move]
      def self.from_actions(actions)
        pmn = actions.flat_map(&:to_a)
        new(*pmn)
      end

      private

      # Validation ------------------------------------------------------------

      def validate_array!(array)
        raise Error::Move, "PMN must be an array, got #{array.class}" unless array.is_a?(Array)
        raise Error::Move, "PMN array cannot be empty" if array.empty?

        raise Error::Move, "All PMN elements must be strings" unless array.all?(String)

        return if valid_length?(array)

        raise Error::Move, "Invalid PMN array length: #{array.size}"
      end

      # Valid lengths: (size % 3 == 0) OR (size % 3 == 2), minimum 2.
      def valid_length?(array = pmn_array)
        return false if array.size < 2

        r = array.size % 3
        [0, 2].include?(r)
      end

      # Parsing ---------------------------------------------------------------

      def parse_actions(array)
        actions = []
        index = 0

        while index < array.size
          remaining = array.size - index

          if remaining == 2
            actions << Action.new(array[index], array[index + 1])
            index += 2
          elsif remaining >= 3
            actions << Action.new(array[index], array[index + 1], array[index + 2])
            index += 3
          else
            raise Error::Move, "Invalid action group at index #{index}"
          end
        end

        actions
      rescue Error::Action => e
        # Normalize action-level errors as move-level errors during parsing
        raise Error::Move, "Invalid action while parsing move at index #{index}: #{e.message}"
      end

      def validate_actions!
        actions.each_with_index do |action, i|
          next if action.valid?

          raise Error::Move, "Invalid action at position #{i}: #{action.inspect}"
        end
      end
    end
  end
end
