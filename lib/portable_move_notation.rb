# frozen_string_literal: true

# Portable Move Notation module
module PortableMoveNotation
  def self.dump(*moves)
    Dumper.call(*moves)
  end

  def self.parse(string)
    Parser.call(string)
  end
end

require_relative 'portable_move_notation/dumper'
require_relative 'portable_move_notation/parser'
