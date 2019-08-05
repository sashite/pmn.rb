# frozen_string_literal: true

# Portable Move Notation module
module PortableMoveNotation
  def self.dump(*moves)
    Dump.call(*moves)
  end

  def self.load(pmn_string)
    Load.call(pmn_string)
  end
end

require_relative 'portable_move_notation/dump'
require_relative 'portable_move_notation/load'
