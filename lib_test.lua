--[=[
Test functions for lib.lua
--]=]

require "lib"

-- Test for max:

function max_test()
  assert(max(1, 2) == 2)
  assert(max(6, 3) == 6)
  assert(max(23, 24) == 24)
  assert(max('a', 'b') == 'b')
  assert(max(42.4, 42.51) == 42.51)
  assert(max(9.9, 10) ~= 9.9)
end

-- Test for min:

function min_test()
  assert(min(1, 2) == 1)
  assert(min(6, 3) == 3)
  assert(min(23, 24) == 23)
  assert(min('a', 'b') == 'a')
  assert(min(42.4, 42.51) == 42.4)
  assert(min(9.9, 10) ~= 10)
end

-- Test for abs:

function abs_test()
  assert(abs(5) == 5)
  assert(abs(-6) == 6)
  assert(abs(0) == 0)
end

-- Test for rnd:

function rnd_test()
  assert(rnd(4.2) == 4)
  assert(rnd(5.5) == 6)
  assert(rnd(9) == 9)
  assert(rnd(-5.1) == -5)
  assert(rnd(-11) == -11)
  assert(rnd(-1.5) == -1)
end

-- Test for pround:

function pround_test()
  assert(pround(.41) == 41)
  assert(pround(.901) == 90)
  assert(pround(.019) == 2)
  assert(pround(.595) == 60)
  assert(pround(0) == 0)
  assert(pround(.915345) == 92)
end

-- Test for round:

function round_test()
  assert(round(15.29, 0) == 15)
  assert(round(15.29, 1) == 15.3)
  assert(round(15.29, 2) == 15.29)
  assert(round(1.123456789, 3) == 1.123)
  assert(round(1.123456789, 7) == 1.1234568)
  assert(round(-3.333, 1) == -3.3)
end

