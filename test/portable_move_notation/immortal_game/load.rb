# frozen_string_literal: true

require_relative '../../test_helper'

immortal_game_moves = [
  [[52, 36, 'W:P', nil]],
  [[12, 28, 'w:p', nil]],
  [[53, 37, 'W:P', nil]],
  [[28, 37, 'w:p', nil]],
  [[61, 34, 'W:B', nil]],
  [[3, 39, 'w:q', nil]],
  [[60, 61, 'W:-K', nil]],
  [[9, 25, 'w:p', nil]],
  [[34, 25, 'W:B', nil]],
  [[6, 21, 'w:n', nil]],
  [[62, 45, 'W:N', nil]],
  [[39, 23, 'w:q', nil]],
  [[51, 43, 'W:P', nil]],
  [[21, 31, 'w:n', nil]],
  [[45, 39, 'W:N', nil]],
  [[23, 30, 'w:q', nil]],
  [[39, 29, 'W:N', nil]],
  [[10, 18, 'w:p', nil]],
  [[54, 38, 'W:P', nil]],
  [[31, 21, 'w:n', nil]],
  [[63, 62, 'W:R', nil]],
  [[18, 25, 'w:p', nil]],
  [[55, 39, 'W:P', nil]],
  [[30, 22, 'w:q', nil]],
  [[39, 31, 'W:P', nil]],
  [[22, 30, 'w:q', nil]],
  [[59, 45, 'W:Q', nil]],
  [[21, 6, 'w:n', nil]],
  [[58, 37, 'W:B', nil]],
  [[30, 21, 'w:q', nil]],
  [[57, 42, 'W:N', nil]],
  [[5, 26, 'w:b', nil]],
  [[42, 27, 'W:N', nil]],
  [[21, 49, 'w:q', nil]],
  [[37, 19, 'W:B', nil]],
  [[26, 62, 'w:b', nil]],
  [[36, 28, 'W:P', nil]],
  [[49, 56, 'w:q', nil]],
  [[61, 52, 'W:-K', nil]],
  [[1, 16, 'w:n', nil]],
  [[29, 14, 'W:N', nil]],
  [[4, 3, 'w:-k', nil]],
  [[45, 21, 'W:Q', nil]],
  [[6, 21, 'w:n', nil]],
  [[19, 12, 'W:B', nil]]
]

actual_value    = PortableMoveNotation.load('52,36,W:P.12,28,w:p.53,37,W:P.28,37,w:p.61,34,W:B.3,39,w:q.60,61,W:-K.9,25,w:p.34,25,W:B.6,21,w:n.62,45,W:N.39,23,w:q.51,43,W:P.21,31,w:n.45,39,W:N.23,30,w:q.39,29,W:N.10,18,w:p.54,38,W:P.31,21,w:n.63,62,W:R.18,25,w:p.55,39,W:P.30,22,w:q.39,31,W:P.22,30,w:q.59,45,W:Q.21,6,w:n.58,37,W:B.30,21,w:q.57,42,W:N.5,26,w:b.42,27,W:N.21,49,w:q.37,19,W:B.26,62,w:b.36,28,W:P.49,56,w:q.61,52,W:-K.1,16,w:n.29,14,W:N.4,3,w:-k.45,21,W:Q.6,21,w:n.19,12,W:B')
expected_value  = immortal_game_moves

raise "Expected #{expected_value.inspect}, but got #{actual_value.inspect}" unless actual_value == expected_value
