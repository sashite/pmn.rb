# frozen_string_literal: true

# Portable Move Notation module
module PortableMoveNotation
  def self.dump(*moves)
    Dumper.call(*moves)
  end

  def self.parse(pmn_string)
    Parser.call(pmn_string)
  end
end

require_relative 'portable_move_notation/dumper'
require_relative 'portable_move_notation/parser'
