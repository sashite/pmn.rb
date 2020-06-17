# frozen_string_literal: true

module PortableMoveNotation
  class Dumper
    def self.call(*unserialized_moves)
      unserialized_moves.map do |unserialized_move|
        unserialized_actions = unserialized_move.each_slice(4)
        ::Sashite::PAN::Dumper.call(*unserialized_actions)
      end.join('.')
    end
  end
end

require 'sashite/pan/dumper'
