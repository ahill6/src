--[=[
Test functions for lib.lua
--]=]

require "lib"

-- Test for max:

function _max()
  assert(max(1,2) == 2)
  assert(max(6,3) == 3)
  assert(max(23, 24) == 24)
  assert(max('a','b' == 'b'))
  assert(max(42.4, 42.51) == 42.51)
end

-- Test for min:

function _min()
  assert(min(1,2) == 1)
  assert(min(6,3) == 3)
  assert(min(23, 24) == 23)
  assert(min('a','b') == 'a')
  assert(min(42.4, 42.51) == 42.4)
end

-- Test for abs:

function _abs()
  assert(abs(5) == 5)
  assert(abs(-6) == 6)
  assert(abs(0) == 0)
end


