# frozen_string_literal: true

module PortableMoveNotation
  class Dumper
    def self.call(*unserialized_moves)
      unserialized_moves.map do |move|
        actions = move.each_slice(4)
        Action::Dumper.call(*actions)
      end.join('.')
    end
  end
end

require_relative 'action/dumper'
