# frozen_string_literal: true

require_relative 'move'

module PortableMoveNotation
  # Dumper class
  class Dumper < Move
    def self.call(*moves)
      moves.map { |move| ::Sashite::PAN::Dumper.call(*move.each_slice(4)) }
           .join(separator)
    end
  end
end

require 'sashite/pan/dumper'
