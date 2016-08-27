function csv(file,callback)
  if file then io.input(file) end
  local space = "[ \t\r\n]"
  local sep   = "([^,]+)"
  local txt,n,names = io.read(),0,nil
  while txt ~= nil do
    txt = txt:gsub(space,"")
    if txt ~= "" then 
      local t = {}
      for s in string.gmatch(txt,sep) do t[#t+1]= s end
      if #t > 0 then
        n = n + 1
        if   n==1 then names = t else
          callback(n, t, t[#t], names)
      end end
      txt = io.read()
end end end

function inc3(t, x, y)
  local tx = t[x]
  if not tx then tx={}; t[x] = tx end
  local txy = tx[y]
  if not txy then txy=0; tx[y] = txy + 1 end
end
function rprint(x,pre,lvl)
  local function show(z)
    print(pre .. string.rep(" ",lvl) .. tostring(z))
  end
  lvl = lvl or 0
  if type(x) == 'table' then
    for a,b in pairs(x) do
      show(a)
      rprint(b,pre,lvl+1)
    end
  else
    show(x)
end end

function classify(t, w,what)
  local what, liked, like = nil,{}, -100000
  for h,nh in pairs(w.h) do
    print("h",h)
    local tmp = math.log(nh / w.total)
    for i,x in pairs(t) do
      if x ~= "?" then
        local f = t.h[h][i][x] or 0  -- prior counts
        local a = w.f[h] and #w.f[h][i] -- numeber of attributes
        tmp     = tmp + math.log( (f + 1) / (nh + a ) )
    end end
    liked[h] = tmp
    if tmp > like then
      like, what = tmp,h
  end end
  --print(t[#t],what)
  return what,liked
end

function nb(file) 
  local w={t={},h={}}
  local function worker(n, t, what, names)
    if n > 10 then
      classify(t,w,what)
    end
    w.total, w.names = n, names
    w.h[what]    = (w.h[what] or 0) + 1
    -- print("what",n,what,names[1],w.h[what])
    for i,x in  pairs(t) do
      if x ~= "?" then
        inc3(w.t, i, x) 
      end
    end
    rprint(w.t,">")
  end
  csv(file, worker)
end

nb('data/data101.csv') 

