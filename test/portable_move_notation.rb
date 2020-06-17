# frozen_string_literal: true

require_relative '../lib/portable_move_notation'

# Black castles on king-side

raise unless PortableMoveNotation.dump([60, 62, '♔', nil, 63, 61, '♖', nil]) == '60,62,♔;63,61,♖'
raise unless PortableMoveNotation.parse('60,62,♔;63,61,♖') == [[60, 62, '♔', nil, 63, 61, '♖', nil]]

# Promoting a chess pawn into a knight

raise unless PortableMoveNotation.dump([12, 4, '♘', nil]) == '12,4,♘'
raise unless PortableMoveNotation.parse('12,4,♘') == [[12, 4, '♘', nil]]

# Capturing a rook and promoting a shogi pawn

raise unless PortableMoveNotation.dump([33, 24, '+P', 'R']) == '33,24,+P,R'
raise unless PortableMoveNotation.parse('33,24,+P,R') == [[33, 24, '+P', 'R']]

# Dropping a shogi pawn

raise unless PortableMoveNotation.dump([nil, 42, 'P', nil]) == '*,42,P'
raise unless PortableMoveNotation.parse('*,42,P') == [[nil, 42, 'P', nil]]

# Capturing a white chess pawn en passant

raise unless PortableMoveNotation.dump([48, 32, '♙', nil], [33, 32, '♟', nil, 32, 40, '♟', nil]) == '48,32,♙.33,32,♟;32,40,♟'
raise unless PortableMoveNotation.parse('48,32,♙.33,32,♟;32,40,♟') == [[48, 32, '♙', nil], [33, 32, '♟', nil, 32, 40, '♟', nil]]
