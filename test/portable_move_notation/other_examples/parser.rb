# frozen_string_literal: true

require_relative '../../test_helper'

raise unless PortableMoveNotation.parse('60,62,C:-K;63,61,C:R') == [[60, 62, 'C:-K', nil, 63, 61, 'C:R', nil]]
raise unless PortableMoveNotation.parse('12,4,C:P,C:N') == [[12, 4, 'C:P', 'C:N']]
raise unless PortableMoveNotation.parse('33,24,S:P,S:+P') == [[33, 24, 'S:P', 'S:+P']]
raise unless PortableMoveNotation.parse('*,42,S:P') == [[nil, 42, 'S:P', nil]]
raise unless PortableMoveNotation.parse('48,32,C:P.33,32,c:p;32,40,c:p') == [[48, 32, 'C:P', nil], [33, 32, 'c:p', nil, 32, 40, 'c:p', nil]]
