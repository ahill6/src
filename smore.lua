require "lib"

local IGNORE = "?"    -- marks which columns or cells to ignore

local _ID = 0
local function ID()
  _ID = _ID + 1;
  return _ID
end 

local function SYM()
  return {n=0, counts={}, most=0,   mode=nil } end

local function NUM()
  return {n=0,  mu=0, m2=0,up=-1e32, lo=1e32 } end

local function nump(x)
  return x.mu ~= nil end

local function ROW(t)
  return {id=ID(),   cells=t,   normy={}, normx={}} end

local function TBL(t) return {
    things={}, _rows={}, less={}, ynums={}, xnums={},n=0,
    more={}, spec=t, outs={}, ins={}, syms={}, xsyms={}, nums={}}
end

local function RANGE(t) return {
    label=t.label, score=t.score, x=t.x, y=t.y, has=t.has,
    n=t.n, id=t.id, lo=t.lo, up=t.up}
end

local function RANGES(t) return plus(
    {label=1, x=first, y=last, verbose=false,
     trivial=1.05, cohen=0.3, tiny=nil,
     enough=nil},t)
end

local function NWHERE(t) return plus(
    {verbose=false, cull=0.5, stop=20}, t)
end

local function DICHOTOMIZE(t) return plus(
    {min=5}, t)
end

local function NODE(rows,spec,best,keys) return {
    id=ID(), _tbl = rows2tbl(rows,spec) ,  best=best, keys= keys, kids={}} end

----------------------------------------------------------------
local function sym1(i,one)
  if one ~= IGNORE then
    i.n = i.n + 1
    local old = i.counts[one]
    local new = old and old + 1 or 1
    i.counts[one] = new
    if new > i.most then
      i.most, i.mode = new,one
end end end

local function num1(i,one)
  if one ~= IGNORE then
    i.n = i.n + 1
    if one < i.lo then i.lo = one end
    if one > i.up then i.up = one end
    local delta = one - i.mu
    i.mu = i.mu + delta / i.n
    i.m2 = i.m2 + delta * (one - i.mu)
end end

function unnum(i, one)
  if one ~= IGNORE then
    i.n  = i.n - 1
    local delta = one - i.mu
    i.mu = i.mu - delta/i.n
    i.m2 = i.m2 - delta*(one - i.mu) -- untrustworthy for very small n and z
end end

function unsym(i, one)
  if one ~= IGNORE then
    i.n  = i.n - 1
    i.most,i.mode = 0,nil
    i.counts[one] = i.counts[one] - 1
end end

local function thing1(i,one)   return (nump(i) and num1  or sym1 )(i,one) end
local function unthing1(i,one) return (nump(i) and unnum or unsym)(i,one) end

local function sym0(inits) return maps(inits, SYM(), sym1) end
local function num0(inits) return maps(inits, NUM(), num1) end

local function sd(i)
  return i.n <= 1 and 0 or (i.m2 / (i.n - 1))^0.5
end

local function norm(i,x)
  if x==IGNORE then return x end
  return (x - i.lo) / (i.up - i.lo + 1e-32)
end

local function smallEffect(i,j, small)
  local small = small or  0.38 -- less severe=0.38. strict=0.17
  local num   = (i.n - 1)*sd(i)^2 + (j.n - 1)*sd(j)^2
  local denom = (i.n - 1) + (j.n - 1)
  local sp    = ( num / denom )^0.5
  local delta = abs(i.mu - j.mu) / sp  
  local c     = 1 - 3.0 / (4*(i.n + j.n - 2) - 1)
  return delta * c < small
end

local function different(i,j,    conf)
  local function threshold(df, conf)
    conf = conf or 99
    local xs = {     1,     2,     5,    10,    15,
                    20,    25,    30,    60,   100}
    local ys = {}
    ys[0.90] = { 3.078, 1.886, 1.476, 1.372, 1.341,
                 1.325, 1.316, 1.31 , 1.296, 1.29 }
    ys[0.95] = { 6.314, 2.92,  2.015, 1.812, 1.753,
                 1.725, 1.708, 1.697, 1.671, 1.66 } 
    ys[0.99] = {31.821, 6.965, 3.365, 2.764, 2.602,
                 2.528, 2.485, 2.457, 2.39,  2.364}
    return xtend(df,xs,ys[conf])
  end
  conf = conf or 0.9
  local denom, nom = 1, i.mu - j.mu
  local s1, s2 = sd(i), sd(j)
  if s1+s2 > 0 then denom = (s1^2/i.n + s2^2/j.n)^0.5 end
  local df =  math.floor(0.5 +
                (  s1^2/i.n               +    s2^2/j.n)^2  /
                ( (s1^2/i.n)^2 / (i.n -1) + ( (s2^2/j.n)^2 / (j.n - 1))))
  local diff    = threshold(df, conf) > nom/denom
  local trivial = smallEffect(i,j)
  return diff and not trivial
end

local function bdom(t1,t2)
  local n = 0
  for i,x in pairs(t1.less) do
    local y = t2.less[i]
    if different(x,y) then
      if x.mu < y.mu then n= n+1 else return false end end end
  for i,x in pairs(t1.more) do
    local y = t2.more[i]
    if different(x, y) then
      if x.mu > y.mu then n= n+1 else return false end end end 
  return n > 0 
end

function _different()
  local max=100
  for i=1,max,6 do
    local n1,n2 = num0(), num0()
    for _= 1,200 do
      num1(n1,r())
      num1(n2,1.2*r())
    end
    print{i=i,conc=different(n1,n2),
          mu1=f3(n1.mu), mu2=f3(n2.mu),
          sd1=f3(sd(n1)),sd2=f3(sd(n2))}
end end

local function ent(i)
  local e = 0
  for _,f in pairs(i.counts) do
    e = e + (f/i.n) * math.log((f/i.n), 2)
  end
  return -1*e
end

local function ke(i)
  local e,k = 0,0
  for _,f in pairs(i.counts) do
    e = e + (f/i.n) * math.log((f/i.n), 2)
    k = k + 1
  end
  e = -1*e
  return k,e,k*e
end


----------------------------------------------------------------
local function csv(f)
  local sep      = "([^,]+)"       -- cell seperator
  local dull     = "['\"\t\n\r]*"  -- white space, quotes
  local padding  = "%s*(.-)%s*"    -- space around words
  local comments = "#.*"           -- comments
  if f then io.input(f) end  
  local first,line = true, io.read()
  local cache,use  = {},{}
  return function ()
    while line ~= nil do
      local row = {}
      line = line:gsub(padding,"%1")
	         :gsub(dull,"")
	         :gsub(comments,"")       
      if line ~= "" then
	cache[#cache + 1] = line
	if string.sub(line,-1) ~= "," then
	  local lines = table.concat(cache)
	  local col   = 0
	  for word in string.gmatch(lines,sep) do
	    col = col + 1
	    if first then
	      use[col] = string.find(word,IGNORE) == nil
	    end
	    if use[col] then
	      word = tonumber(word) or word
	      row[#row+1] = word
	      assert(type(word) ~= 'function')
	      
	    end
	  end	  
	  first, cache = false, {}
      end end
      line = io.read()
      if #row > 0 then return row end
end end end

----------------------------------------------------------------
local function row1(t, cells)
  local function whoWheres(cell,t)
    local spec =  { 
      {what= "%$", who= num0, wheres= {t.things, t.ins,  t.nums, t.xnums  }},
      {what= "<",  who= num0, wheres= {t.things, t.outs, t.nums, t.less, t.ynums}},
      {what= ">",  who= num0, wheres= {t.things, t.outs, t.nums, t.more, t.ynums}},
      {what= "=",  who= sym0, wheres= {t.things, t.outs, t.syms  }},
      {what= "",   who= sym0, wheres= {t.things, t.ins,  t.syms, t.xsyms }}}
    for _,want in pairs(spec) do
      if string.find(cell,want.what) ~= nil then
	return want.who, want.wheres
  end end end
  ------------------------------
  local function header(t)
    for col,cell in ipairs(cells) do
      local who, wheres = whoWheres(cell,t)
      local thing = who()
      thing.col = col
      thing.txt = cell
      for _,where in ipairs(wheres) do
	where[ #where + 1 ] = thing
    end end
    return t
  end
  ------------------------------
  local function data(t,row) 
    t._rows[row.id] = row
    t.n = t.n + 1
    for _,thing in pairs(t.things) do
      local passed,err = pcall(function () thing1(thing, cells[thing.col]) end)
      if not passed then
	print('read fail>', thing.txt, thing.col, cells[thing.col], err)
      end
    end
    return t
  end
  -----------------------------
  return t and data(t, ROW(cells)) or header(TBL(cells))
end

function csv2tbl(f,     t)
  for row in csv(f) do t = row1(t,row) end
  return t
end

function rows2tbl(rows, spec, t)
  t = row1(t, spec)
  for _,row in pairs(rows) do
    t = row1(t, copy(row.cells)) end
  return t
end
  
function _csv()   
  local n=0
  for line in csv('data/weather.csv') do
    n= n+1
    if line then
      print(n,#line, table.concat(line,","))
end end end

---- why an i getting functions in my trees?

function normys(t)
  for _,row in pairs(t._rows) do
    for _,thing in pairs(t.ynums) do
      row.normy[#row.normy+1] =
         norm(thing, row.cells[thing.col]) end end
  return t
end

function z(t)
  for i,pop in pairs(t) do
    if pop== nil then
      print(">>",i)
end end end

function nwhere(all,t) return nwhering(all, NWHERE(t)) end

function nwhering( all, o)
  o.enough = max((#all)^o.cull,o.stop)
  ------------------------------------------------------
  local function  dist(r1,r2)
    local sum, n = 0,  0
    for i, y1 in pairs(r1.normy) do
      local y2 = y1,r1.normy[i]
      if not (y1== IGNORE and y2== IGNORE) then
	if y1== IGNORE then y1= y2 > 0.5 and 0 or 1 end
	if y2== IGNORE then y2= y1 > 0.5 and 0 or 1 end
	sum = sum + (y1 -  y2)^2
	n   = n + 1
    end end
    return sum^0.5 / n^0.5
  end
  ------------------------------------------------------
  local function furthest(r1, items)
    local out,most=r1,0
    for _,r2 in pairs(items) do
      local d = dist(r1,r2)
      if d > most then
	out,most = r2,d end end
    return out
  end
  ------------------------------------------------------
  local function split(items, mid,west,east,redo)
    redo= redo or 20
    assert(redo > 0,"max depth exceeded")
    local cos = function (a,b,c)
                   return (a*a + c*c - b*b) / (2*c + 0.0001) end 
    local west = west or furthest(any(items),items)
    local east = east or furthest(west, items)
    while east.id == west.id do
      east = any(items)
    end
    local c  = dist(west,east)
    local xs = {}
    for n,item in pairs(items) do
      local a = dist(item,west)
      local b = dist(item,east)
      xs[ item.id ] = cos(a,b,c)
      if a > c then
	dot(">".. n.." ")
	return split(items, mid, west, item, redo-1)
      elseif b > c then
	dot("<"..n.." ")
	return split(items, mid, item, east, redo-1)
    end end
    table.sort(items,function (r1,r2) return xs[r1.id] < xs[r2.id] end)
    return west, east, sub(items,1,mid), sub(items,mid+1)
  end
  ------------------------------------------------------
  local function cluster(items,out,lvl)
    lvl = lvl or 1
    if o.verbose then
      print(s5(#items)..nstr("|..",lvl-1)) end
    if #items < o.enough then
      out[#out+1] = items
    else
      local west,east,left,right = split(items, math.floor(#items/2))
      cluster(left,  out, lvl+1)
      cluster(right, out, lvl+1)
    end
    return out
  end
  ------------------------------------------------------
  return cluster(copy(all), {})
end

function _row()
  local t = csv2tbl('data/autos.arff')
  print("\n----| NUMBERS |---------------------------")
  for _,thing in pairs(t.nums) do
    print(thing.txt, {mu=f5(thing.mu), sd=f5(sd(thing)), lo=thing.lo,up=thing.up})
  end
  print("\n----| SYMBOLS |---------------------------")
  for _,thing in pairs(t.syms) do
    print(thing.txt, {mode=thing.mode, most=thing.most,
  		      ent=f5(ent(thing))},thing.counts)
  end
end

function _nwhere()
  local t= csv2tbl('data/autos.arff')
  normys(t)
  print("======")
  for i,rows in pairs(nwhere(t._rows,{verbose=true})) do
    print(i,#rows)
    for _,row in pairs(rows) do
      row.cluster = i end end
end

function ranges(items,t) return ranging(items, RANGES(t)) end
 
function ranging(items,o)
  o.tiny   = o.tiny   or sd(num0(collect(items,o.x))) * o.cohen
  o.enough = o.enough or (#items)^0.5
  local function xpect(l,r,n) return l.n/n*ent(l) + r.n/n*ent(r) end
  local function divide(items,out,lvl,cut)
    local xlhs, xrhs   = num0(), num0(collect(items,o.x))
    local ylhs, yrhs   = sym0(), sym0(collect(items,o.y))
    local score,score1 = ent(yrhs), nil
    local k0,e0,ke0    = ke(yrhs) 
    local reportx       = copy(xrhs)
    local reporty      = copy(yrhs)
    local n            = #items
    local start, stop  = o.x(first(items)), o.x(last(items))
    for i,new in pairs(items) do
      local x1 = o.x(new)
      local y1 = o.y(new)
      if x1 ~= IGNORE then
	num1( xlhs,x1); sym1( ylhs,y1)  -- the code giveth
	unnum(xrhs,x1); unsym(yrhs,y1)  -- the code taketh away
	if xrhs.n < o.enough then
	  break
	else
	  if xlhs.n >= o.enough then
	    if x1 - start > o.tiny then
	      if stop - x1 > o.tiny then
		if x1 < o.x(items[i+1])  then
		  local score1 = xpect(ylhs,yrhs,n)
		  if score1 * o.trivial < score then
		    local gain       = e0 - score1
		    local k1,e1, ke1 = ke(yrhs) -- k1,e1 not used
		    local k2,e2, ke2 = ke(ylhs) -- k2,e2 not used
		    local delta      = math.log(3^k0 - 2,2) - (ke0 - ke1 - ke2)
		    local border     = (math.log(n-1,2)  + delta) / n
		    if gain > border then
		      cut,score = i,score1 end end end end end end end end
    end -- for loop
    if o.verbose then
      print(s5(n),nstr('|..',lvl)) end
    if cut then
      divide( sub(items,1,   cut), out, lvl+1)
      divide( sub(items,cut+1), out, lvl+1)
    else
      out[#out+1] = RANGE{label=o.label,score=score,x=reportx,y=reporty,
			  n=n, id=#out, lo=start, up=stop, _has=items}
    end
    return out
  end
  -----------------------------------
  
  local items1 = select(items, function(z) return o.x(z) ~= IGNORE end)
  table.sort(items1, function (z1,z2) return o.x(z1) < o.x(z2) end)
  return divide(items1, {}, 0)
end

local function thingScore(rows,x,y)
  local syms, splits,keys = {},{},{}
  for  _,row in pairs(rows) do
    local x1 = x(row)
    if syms[x1] == nil then
      syms[x1] = sym0()
      splits[x1] = {}
      keys[#keys+1] = x1
    end
    sym1(syms[x1],y(row))
    local v = splits[x1]
    v[#v + 1] = row
    splits[x1] = v 
  end
  table.sort(keys)
  local xpect = 0
  for x,sym in pairs(syms) do
    xpect = xpect + sym.n/#rows * ent(sym)
  end
  return xpect,splits,keys
end

function bestThing(rows,t)
  local score,best,splits,keys = 1e31,nil,{},nil
  for _,thing in pairs(t.xsyms) do
    local tmp,some,keys0 = thingScore(
      rows,
      function (row) return row.cells[thing.col] end,
      function (row) return row.cluster end)
    if tmp < score then
      score, best, splits, keys = tmp, thing, some,keys0
    end
  end
  return best,splits,keys
end

function dichotomize(t,all)
  return dichotomize_(t,DICHOTOMIZE(),all) end
function dichotomize_(t,o,all)
  return dichotomizing(t._rows,t,o,all) end

function dichotomizing(rows,t,o, all, lvl, here)
  lvl = lvl or 0
  all = all or {}
  assert(lvl < 20)
  if #rows >= o.min then
    local best, splits, keys = bestThing(rows,t)
    here = NODE(rows, t.spec, best, keys)
    all[#all + 1] = here._tbl
    for i=1,#keys do
      local k    = keys[i]
      local subs = splits[k]
      if #subs < #rows then
        here.kids[k]  = dichotomizing(subs,t,o,all, lvl+1)
    end end end
  return here
end

function treeshow(node,lvl)
  lvl = lvl or 0
  if node then
    for i=1,#node.keys do
      local k    = node.keys[i]
      local subs = node.kids[k]
      if subs  then
        local n = subs._tbl.n
        local str = nstr('|.. ',lvl) .. node.best.txt ..  "=" .. k
        io.write(str .. nstr(" ", 50-#str),"|",n,"\n")
        treeshow(subs, lvl+1)
      end end end end
    
function _ranges1()
  local a,b,c="a","b","c"
  local t={}
  local n = 1000
  for i= 1,n,1      do t[#t+1] = {i- n + n*2*r(), a} end
  for i= n+1,n+n,1  do t[#t+1] = {i- n + n*2*r(), b} end
  for i= 2*n+1,3*n,1 do t[#t+1]= {i- n + n*2*r(), c} end
  local t1 = shuffle(t)
  print("===")
  for _,r in pairs(ranges_(t1,RANGES{verbose=true})) do
    print(r,ent(r.y))
  end
end

function _dich()
  rseed(1)
  print("")
  local t= csv2tbl('data/autos.arff')
  s=function(t,n) return pround(norm(t,n)) end
  normys(t)
  local clusters={}
  for i,rows in pairs(nwhere(t._rows)) do
    for _,row in pairs(rows) do
      t._rows[row.id].cluster  = i end
    clusters[i] = rows
  end
  local all= {}
  treeshow(dichotomize(t,all))
  for i,t1 in pairs(all) do
    for j,t2 in pairs(all) do
      if i ~= j then
        if bdom(t1,t2) then
          print(i,j) end end end end

--  xx=row1(nil,t.spec)
  --for _,row in pairs(clusters[1]) do
    --xx  = row1(xx,row.cells)
  --end
end

function summary(t,rows)
  local tmp,out={},{}
  for _,thing in pairs(t.ynums) do tmp[thing] = num0() end
  for _,row in pairs(rows) do
    for thing,num in pairs(tmp) do
      num1(num, row.cells[thing.col]) end end
  for thing,num in pairs(tmp) do
    out[thing.txt] = pround(norm(thing, num.mu))     end
  return out
end
-- xxx everything not adding sys to non-syjs
--- ranges needs repportx and reporty.
--- looke like tostring is eating all numberic idenxes

function _ranges2()
  local t= csv2tbl('data/autos.arff')
  normys(t)
  print("======")
  for i,rows in pairs(nwhere(t._rows,{verbose=true})) do
    for _,row in pairs(rows) do
      t._rows[row.id].cluster  = "C"..i end end
  for _,thing in pairs(t.xnums) do
    local rs = ranges_(t._rows,
		      RANGES{x=function (z) return z.cells[thing.col] end,
			     y=function (z) return z.cluster end
                            })
    if #rs > 1 then
      print("\nnum",thing.txt,thing.col,#rs)
      for _,r in pairs(rs) do
	print(r.lo, r.up, ent(r.y))
      end
    end    
  end
end


function _demos()
  for k,v in pairs(_G) do
    if type(v) == 'function' and
      string.find(k,'^_') ~= nil and
      k ~= '_tostring' and
      k ~= '_demos' 
    then
      print(string.format("\n---| %s |-------\n",k))
      pcall(v)
end end end

if arg[1]=='--run' then
  loadstring(arg[2] .. '()')()
end


rogue()
