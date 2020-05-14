# frozen_string_literal: true

require_relative '../../test_helper'

immortal_game_moves = [
  [[52, 36, 'C:P', nil]],
  [[12, 28, 'c:p', nil]],
  [[53, 37, 'C:P', nil]],
  [[28, 37, 'c:p', nil]],
  [[61, 34, 'C:B', nil]],
  [[3, 39, 'c:q', nil]],
  [[60, 61, 'C:-K', nil]],
  [[9, 25, 'c:p', nil]],
  [[34, 25, 'C:B', nil]],
  [[6, 21, 'c:n', nil]],
  [[62, 45, 'C:N', nil]],
  [[39, 23, 'c:q', nil]],
  [[51, 43, 'C:P', nil]],
  [[21, 31, 'c:n', nil]],
  [[45, 39, 'C:N', nil]],
  [[23, 30, 'c:q', nil]],
  [[39, 29, 'C:N', nil]],
  [[10, 18, 'c:p', nil]],
  [[54, 38, 'C:P', nil]],
  [[31, 21, 'c:n', nil]],
  [[63, 62, 'C:R', nil]],
  [[18, 25, 'c:p', nil]],
  [[55, 39, 'C:P', nil]],
  [[30, 22, 'c:q', nil]],
  [[39, 31, 'C:P', nil]],
  [[22, 30, 'c:q', nil]],
  [[59, 45, 'C:Q', nil]],
  [[21, 6, 'c:n', nil]],
  [[58, 37, 'C:B', nil]],
  [[30, 21, 'c:q', nil]],
  [[57, 42, 'C:N', nil]],
  [[5, 26, 'c:b', nil]],
  [[42, 27, 'C:N', nil]],
  [[21, 49, 'c:q', nil]],
  [[37, 19, 'C:B', nil]],
  [[26, 62, 'c:b', nil]],
  [[36, 28, 'C:P', nil]],
  [[49, 56, 'c:q', nil]],
  [[61, 52, 'C:-K', nil]],
  [[1, 16, 'c:n', nil]],
  [[29, 14, 'C:N', nil]],
  [[4, 3, 'c:-k', nil]],
  [[45, 21, 'C:Q', nil]],
  [[6, 21, 'c:n', nil]],
  [[19, 12, 'C:B', nil]]
]

actual_value    = PortableMoveNotation.load('52,36,C:P.12,28,c:p.53,37,C:P.28,37,c:p.61,34,C:B.3,39,c:q.60,61,C:-K.9,25,c:p.34,25,C:B.6,21,c:n.62,45,C:N.39,23,c:q.51,43,C:P.21,31,c:n.45,39,C:N.23,30,c:q.39,29,C:N.10,18,c:p.54,38,C:P.31,21,c:n.63,62,C:R.18,25,c:p.55,39,C:P.30,22,c:q.39,31,C:P.22,30,c:q.59,45,C:Q.21,6,c:n.58,37,C:B.30,21,c:q.57,42,C:N.5,26,c:b.42,27,C:N.21,49,c:q.37,19,C:B.26,62,c:b.36,28,C:P.49,56,c:q.61,52,C:-K.1,16,c:n.29,14,C:N.4,3,c:-k.45,21,C:Q.6,21,c:n.19,12,C:B')
expected_value  = immortal_game_moves

raise "Expected #{expected_value.inspect}, but got #{actual_value.inspect}" unless actual_value == expected_value
