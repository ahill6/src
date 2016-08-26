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

-- Test for first:

function first_test()
  assert(first({1, 2}) == 1)
  assert(first({1, 2, 3, 4, 5}) == 1)
  assert(first({32, 16, 8, 4, 2}) == 32)
  assert(first({9, 7, 53.2, 0}) == 9)
  assert(first({11}) == 11)
end

-- Test for last:

function last_test()
  assert(last({1,2}) == 2)
  assert(last({1, 2, 3, 4, 5}) == 5)
  assert(last({32, 16, 8, 4, 2}) == 2)
  assert(last({9, 7, 53.2, 0}) == 0)
  assert(last({11}) == 11)
end

-- Test for shuffle:

function shuffle_test()
  rseed(42) -- ensure same outcome each test

  local origlist = {1, 2, 3, 4, 5} -- for this test, needs unique values
  local allsame = true

  for i=1,20 do
    local testlist = {1, 2, 3, 4, 5} -- same as origlist
    local seen = {}

    local result = shuffle(testlist)
    assert(#result == #origlist)

    for k, v in pairs(result) do -- make sure that every value is seen exactly once
      assert(seen[v] == nil)
      seen[v] = true
      if origlist[k] ~= v then -- Check that the order changed at least once
        allsame = false
  end end end
  assert(not allsame)
  assert((shuffle{99})[1] == 99)
  assert(#(shuffle{}) == 0)
end

-- Test for any:

function any_test()
  rseed(42) -- ensure same outcome each test

  local testlist = {1, 2, 3, 4, 5}
  for i=1,20 do
    local result = any(testlist)
    local inlist = false
    for k, v in pairs(testlist) do
      if v == result then
        inlist = true
        break
    end end
    assert(inlist)
  end
  assert(any{50} == 50)
end

