# frozen_string_literal: true

require_relative '../../test_helper'

raise unless PortableMoveNotation.load('60,62,W:-K;63,61,W:R') == [[[60, 62, 'W:-K', nil], [63, 61, 'W:R', nil]]]
raise unless PortableMoveNotation.load('12,4,W:P,W:N') == [[[12, 4, 'W:P', 'W:N']]]
raise unless PortableMoveNotation.load('33,24,S:P,S:+P') == [[[33, 24, 'S:P', 'S:+P']]]
raise unless PortableMoveNotation.load('*,42,S:P') == [[[nil, 42, 'S:P', nil]]]
raise unless PortableMoveNotation.load('48,32,W:P.33,32,w:p;32,40,w:p') == [[[48, 32, 'W:P', nil]], [[33, 32, 'w:p', nil], [32, 40, 'w:p', nil]]]
