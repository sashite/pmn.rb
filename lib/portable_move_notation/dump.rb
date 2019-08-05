# frozen_string_literal: true

module PortableMoveNotation
  class Dump
    def self.call(*unserialized_moves)
      unserialized_moves.map { |actions| Action::Dump.call(*actions) }.join('.')
    end
  end
end

require_relative 'action/dump'
