# frozen_string_literal: true

module PortableMoveNotation
  class Dumper
    def self.call(*moves)
      moves.map do |move|
        actions = move.each_slice(4)
        ::Sashite::PAN::Dumper.call(*actions)
      end.join('.')
    end
  end
end

require 'sashite/pan/dumper'
