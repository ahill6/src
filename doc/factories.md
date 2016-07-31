# Factories #

## Overview ##

SMORE does not use classes (since the open
nature of Lua's "class" system can be problematic). Instead,
SMORE uses factory functions to generated Lua tables
that correspond to some standard structure.

My factory system uses four kinds
of functions: _templates_, _creators_, _update_, and
_overrides_:

- _Template_ functions are all in upper case;
- _Create_ function names end with `0`;
- _Update_ functions update data;
- _Override_ functions allow for the overriding of defauls.

For example:

### Template Functions ###

For example, when tracking a series of numbers,
we use a `NUM` _template_ function
that defines slots for the `n` amount of numbers seen
to date, the `lo`wer and `up`per value seen so far,
and some other details:

    function NUM()
      return {n=0,  mu=0, m2=0,up=-1e32, lo=1e32 }
    end

### Update Functions ###

Such `NUM`s can be updated using the `num1` _update_ function
that updates the slots (e.g. increments `n` by one,
perhaps updates the `lo` and `up` values, etc.

    function num1(i,one)
      i.n = i.n + 1
      if one < i.lo then i.lo = one end
      if one > i.up then i.up = one end
      local delta = one - i.mu
      i.mu = i.mu + delta / i.n
      i.m2 = i.m2 + delta * (one - i.mu)
    end

Note that:

- In the above, the `NUM` arrives as the first
  function argument called `i`.
- The `i.m2` variable is part of Knuth's recommended
method for incrementally computing standard deviation
  (see below: the `sd` function).


### Create Functions ###

Such `NUM`s are created by a `num0` _create_ function
which calls `NUM` to get a template, then runs over
`init`ilization values (calling `num1` each time to update
the `NUM`:

    function num0(inits)
      return maps(inits, NUM(), num1)
    end
    
    function maps(t,i,f)
      if t then
        for _,v in pairs(t) do f(i,v) end
      end
      return i
    end

### In Use ###

Once we have some updates to our `NUM`, we can use them to define some useful
services; e.g. compute the standard deviation or normalize some number `x` in the range zero to one:

    function sd(i)
      return i.n <= 1 and 0 or (i.m2 / (i.n - 1))^0.5
    end
    
    function norm(i,x)
      return (x - i.lo) / (i.up - i.lo + 1e-32)
    end


