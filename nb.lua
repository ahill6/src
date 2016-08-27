function csv(f)
  if f then io.input(f) end
  local txt,n,names = io.read(),0,nil
  return function ()
    while txt ~= nil do
      txt = txt:gsub("[ \t\r\n]","")
      if txt == "" then contine end
      local t = {}
      for x in string.gmatch(txt,"([^,]+)") do t[#t+1]= x end
      txt = io.read()
      if #t > 0 then
        n = n + 1
        if n==1 then names = t else
          return n,t,t[#t],names
        end
      end
end end end

function inc3(t, x, y)
    local tx = t[x]
    if not tx then tx={}; t[x] = tx end
    local txy = tx[y]
    if not txy then txy={}; tx[y] = txy + 1 end
end

function attrs(t,x) return t[x] and #t[x] or 0 end

function train(f)
  local f,h,n={},{},nil
  for n0,t,what,names in csv(f) do
    n = n0
    h[what] = (h[what] or 0) + 1
    for i,x in ipairs(t) do
      inc3(f,names[i],val) 
  end end
  return f,h,n
end

function classify()
end

nb('data/data101.csv') 

