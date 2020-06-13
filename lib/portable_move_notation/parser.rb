# frozen_string_literal: true

module PortableMoveNotation
  class Parser
    def self.call(serialized_moves_string)
      serialized_moves_string.split('.').map do |serialized_actions|
        Action::Parser.call(serialized_actions)
      end
    end
  end
end

require_relative 'action/parser'
