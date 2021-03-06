--[=[

<img align=right  src="https://upload.wikimedia.org/wikipedia/en/0/04/Duracell_Bunny.png">

# lib.lua

LUA is a "batteries not included" language so LUA programmers usually store
their favorite _batteries_ their own special library file.

Hence, I include below, my batteries.



## Maths Functions 

### Basic Stuff

--]=]

function max(a,b) return a > b and a or b end
function min(a,b) return a < b and a or b end
function abs(x)   return x >= 0 and x or -1*x end

-- ### Rounding
-- `rnd` is the simplest, sends it to the nearest integer;

function rnd(x) return math.floor(x + 0.5) end

-- `pround` does the same, but multiplies by 100;

function pround(num) return math.floor(100*num+0.5) end

-- `round` is the most complex. Rounded to some factor `f`.

function round(num,f)
  if f and f>0 then
    local mult = 10^f
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

-- ## Lists
-- ### Basic Stuff

function first(x) return x[1]  end
function last(x)  return x[#x] end

-- ### shuffle(table)
-- `Shuffle` randomly reorganizes the slots in  table.

function shuffle( t )
  for i= 1,#t do
    local j = i + math.floor((#t - i) * r() + 0.5)
    t[i],t[j] = t[j], t[i]
  end
  return t
end

-- Test for shuffle:

function _shuffle() 
  for i=1,40 do
    local t = shuffle{1,2,3,4,5,6}
    local t1={}
    for i,_ in pairs(t) do
      t1[#t1+1] = i
    end
    print(t, t1)
  end
end

-- ### any(table) 
-- Any item in a table.

function any(t)
  local pos =  math.floor(0.5 + r() * #t)
  return t[ min(#t,max(1,pos)) ]
end

-- ## String Functions
-- ### dot(thing)
-- Write to screen, no new line.

function dot(x)  io.write(x); io.flush() end

-- ### Sub(table, first [,last])
-- Returns the subtable from index `first` to `last`
-- (and if `last` is omitted, go to end of table

function sub(t, first, last)
  last = last or #t
  local out = {}
  if last < first then last = first end
  for i = first,last do
    out[#out+1] = t[i]
  end
  return out
end

--[=[ 

## Random Numbers

Lua's random number generator gives different results when
run on different platforms. So here is one that works the
same on any computer.

The high-level interface is

- `rseed(integer)` : reset the random number seed to `integer` or,
  if omitted, to the magic value of `seed0`.
- `r()` returns a random number between zero and one.

--]=]

do
  local seed0     = 10013
  local seed      = seed0
  local modulus   = 2147483647
  local multipler = 16807
  local function park_miller_randomizer()
    seed = (multipler * seed) % modulus
    return seed / modulus
  end
  function rseed(n) seed = n or seed0               end
  function r()      return park_miller_randomizer() end
end


-------------------------------------------------------
function map(t,f)
  if t then
    for i,v in pairs(t) do f(v)
end end end

function maps(t,i,f)
  if t then
    for _,v in pairs(t) do f(i,v) end
  end
  return i
end

function collect(t,f)
  local out={}
  if t then  
    for i,v in pairs(t) do out[i] = f(v) end end
  return out
end 

function select(t,f)
  local out={}
  if t then  
    for i,v in pairs(t) do
      if f(v) then
	out[#out + 1] = v  end end end
  return out
end 


function plus(old,new)
  if new ~= nil then
    for k,v in pairs(new) do
      old[k] = v
  end end
  return old
end



function copy(t)        return type(t) ~= 'table' and t or collect(t,copy) end
function shallowCopy(t) return map(t,same) end
function same(x) return x end

function member(x,t)
  for _,y in pairs(t) do
    if x== y then return true end end
  return false
end

function f3(x) return string.format('%.3f',x) end
function f5(x) return string.format('%.5f',x) end

function s3(x) return string.format('%3s',x) end
function s5(x) return string.format('%5s',x) end

function nstr(x,n) return string.rep(x,n) end

--[=[

## String

--]=]


------------------------------------------------------
function args(settings,ignore, updates)
  updates = updates or arg
  ignore = ignore or {}
  local i = 1
  while updates[i] ~= nil  do
    local flag = updates[i]
    local b4   = #flag
    flag = flag:gsub("^[-]+","")
    if not member(flag,ignore) then
      if settings[flag] == nil then
        error("unknown flag '" .. flag .. "'")
      else
        if b4 - #flag == 2 then
          settings[flag] = true
        elseif b4 - #flag == 1 then
          local a1 = updates[i+1]
          local a2 = tonumber(a1)
          settings[flag] = a2  or a1
          i = i + 1
        end end end
    i = i + 1
  end
  return settings
end

function _args()
  if arg[1] == "--args" then
    print(args({a=1,c=false,kkk=22},{"args"})) end
end

--[=[

## String

--]=]


-------------------------------------------------------
function rogue()
  local tmp={}
  local builtin ={ "The","jit", "bit", "true","math",
		  "package","table","coroutine",
		  "os","io","bit32","string","arg",
		  "debug","_VERSION","_G"}
  for k,v in pairs( _G ) do
    if type(v) ~= 'function' then
      if not member(k, builtin) then
	table.insert(tmp,k) end end end
  table.sort(tmp)
  if #tmp > 0 then
    print("-- Globals: ")
    for i,v in pairs(tmp) do
      print("    ",i,v)
end end end

--[=[

## String

--]=]

-------------------------------------------------------
-- print table contents
-- print tables in sorted key order
-- dont print private keys (starting with "_")
-- block recursive infinite loops
_tostring = tostring

local function stringkeys(t)
  for key,_ in pairs(t) do
    if type(key) ~= "string" then return false end
  end
  return true
end

function keys(t)
  local ks={}
  for k,_ in pairs(t) do ks[#ks+1] = k end
  table.sort(ks)
  local i = 0
  return function ()
   if i < #ks then
      i = i + 1
      return ks[i],t[ks[i]] end end
end

function ordered(t)
  local n,tmp= 1,{}
  for k,v in pairs(t) do
    tmp[#tmp+1] = {_tostring(k),k,v} end
  table.sort(tmp,function (x,y) return first(x) < first(y) end)
  local i = 0
  return function()
    if i < #tmp then
      i = i+1
      local _,k,v = tmp[i]
      return k,v end end end


function eman(x)
  for k,v in pairs(_G) do
    if v==x then return k end
end end

function tostring(t,seen)
  -- if type(t) == 'number' then return f3(t) end
  if type(t) == 'function' then return "FUNC(".. (eman(t) or "") ..")" end
  if type(t) ~= 'table'    then return _tostring(t) end 
  seen = seen or {}
  if seen[t] then return "..." end
  seen[t] = t
  local out,sep= {'{'},""
  if stringkeys(t) then
    for k,v in keys(t) do
      if k:sub(1,1) ~= "_" then
	for _,v in pairs{sep,k,"=",tostring(v,seen)} do
	  out[#out+1] =v
	end
	sep=", "
      end
    end
  else
    for _,item in pairs(t) do
      for _,v in pairs{sep,k,"",tostring(item,seen)} do
	  out[#out+1] =v
      end
      sep=", "
  end end
  out[#out+1] = "}"
  return table.concat(out)
end

--[=[

## String

--]=]

do
  local y,n = 0,0
  -------------------------------
  local function report()
    print(string.format(
	    ":PASS %s :FAIL %s :percentPASS %s%%",
	    y,n,math.floor(0.5 + 100*y/(0.001+y+n)))) end
  -------------------------------
  local function test(s,x)
    print("\n",string.rep("-",20))
    print("-- test:", s,eman(x))
    y = y + 1
    local passed,err = pcall(x)
    if not passed then
      n = n + 1
      print("Failure: ".. err) end end
  -------------------------------
  function ok(t)
    if   not t then report()
    else for s,x in pairs(t) do test(s,x) end
         report() end end
end

--[=[

## String

--]=]

function xtend(x,xs,ys,  x1,y1)
  local function out(x,x0,y0,x1,y1)
    return y0 + (x - x0) / (x1 - x0)*(y1 - y0) end
  local x0,y0 = xs[1],ys[1]
  if x < x0  then
    return out(x,xs[1], ys[1], xs[2], ys[2]) end
  if x > xs[#xs] then
    return out(x, xs[#xs-1], ys[#ys-1], xs[#xs], ys[#ys]) end
  for i=1,#xs do
    x1,y1 = xs[i],ys[i]
    if x0<=x and x<x1 then break end
    x0,y0 = x1,y1
  end
  return out(x,x0,y0,x1,y1)
end



