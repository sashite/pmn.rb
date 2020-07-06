# frozen_string_literal: true

require_relative 'move'

module PortableMoveNotation
  # Parser class
  class Parser < Move
    def self.call(string)
      string.split(separator)
            .map { |serialized_move| new(serialized_move).call }
    end

    attr_reader :serialized_actions

    def initialize(serialized_move)
      @serialized_actions = serialized_move.split(';')
    end

    def call
      serialized_actions.flat_map { |string| action_items(*string.split(',')) }
    end

    private

    def action_items(*args)
      src_square = args.fetch(0)
      src_square = src_square.eql?(drop_char) ? nil : Integer(src_square)
      dst_square = Integer(args.fetch(1))
      piece_name = args.fetch(2)
      piece_hand = args.fetch(3, nil)

      [src_square, dst_square, piece_name, piece_hand]
    end

    def drop_char
      '*'
    end
  end
end
