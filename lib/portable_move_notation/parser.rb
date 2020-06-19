# frozen_string_literal: true

module PortableMoveNotation
  class Parser
    def self.call(pmn_string)
      pmn_string.split('.').map do |pan_string|
        ::Sashite::PAN::Parser.call(pan_string)
                              .flatten(1)
      end
    end
  end
end

require 'sashite/pan/parser'
