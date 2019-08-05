# frozen_string_literal: true

module PortableMoveNotation
  class Load
    def self.call(serialized_moves)
      serialized_moves.split('.').map do |serialized_actions|
        Action::Load.call(serialized_actions)
      end
    end
  end
end

require_relative 'action/load'
