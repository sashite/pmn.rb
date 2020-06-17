# frozen_string_literal: true

module PortableMoveNotation
  class Parser
    def self.call(serialized_moves_string)
      serialized_moves_string.split('.').map do |serialized_actions_string|
        ::Sashite::PAN::Parser.call(serialized_actions_string).flatten(1)
      end
    end
  end
end

require 'sashite/pan/parser'
