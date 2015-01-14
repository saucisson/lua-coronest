-- The Problem
-- ===========

-- Suppose that you have a list of threads (implemented using coroutines).
-- A scheduler is just a bit more than an iterator over the threads to run.
-- For simplicity, our scheduler handles only one thread.

local function schedule (thread)
  while coroutine.status (thread) ~= "dead" do
    print ("Running thread: " .. tostring (thread))
    coroutine.resume (thread)
  end
end

-- All threads have the same behavior: they iterate over a set of data.
-- They use a custom iterator: `iter`. This one sometimes returns control
-- to the scheduler (for instance to represent non blocking network
-- communications).

local function iter (data)
  return coroutine.wrap (function ()
    for k, v in pairs (data) do
      if v % 2 == 1 then
        coroutine.yield (true) -- yield for scheduler
      end
      coroutine.yield (k, v) -- yield for iterator
    end
  end)
end

-- The problem is: how do we know the receiver of each `yield`?
-- Using the coroutines in Lua, this is not possible. We have to write
-- a dedicated handling in the thread behavior, as below.

local function work (data)
  for k, v in iter (data) do
    if k == true then
      coroutine.yield (true)
    else
      print ("k: " .. tostring (k), "v: " .. tostring (v))
      -- use `k` and `v`
    end
  end
end

-- This solution is not perfect, as a problem occurs if the data contains
-- the `true` key. We can replace it with a specific table value to avoid
-- collisions.

-- Now we can test our program:

local data = {}
for i = 1, 5 do
  data [i] = i
end

schedule (coroutine.create (function ()
  work (data)
end))

-- It works!

-- This might be quite simple, but becomes difficult when the problem
-- arises in third-party libraries
-- For instance, we had trouble using two libraries that
-- were not intended to work together:
-- [copas](https://github.com/keplerproject/copas/) and
-- [redis-lua](https://github.com/nrk/redis-lua).

-- Nested Coroutines
-- =================

-- Instead of handling ourselves the different yields, we can use the
-- nested coroutines module, with only slight changes in our code.

-- First, import a factory for coroutine modules:
coroutine.make = require "coroutine.make"

-- Create a coroutine module instance specific to the scheduler:
local scheduler_coroutine = coroutine.make ()

-- And use it within the scheduler:
local function schedule (thread)
  while scheduler_coroutine.status (thread) ~= "dead" do
    print ("Running thread: " .. tostring (thread))
    scheduler_coroutine.resume (thread)
  end
end

-- Create a coroutine module instance specific to the iterator:
local iterator_coroutine = coroutine.make ()

-- And use it within the iterator. Depending on the `yield` target,
-- we use a different coroutine module. It ensures that the `yield`s
-- will be caught by the correct `resume`.
local function iter (data)
  return iterator_coroutine.wrap (function ()
    for k, v in pairs (data) do
      if v % 2 == 1 then
        scheduler_coroutine.yield (true) -- yield for scheduler
      end
      iterator_coroutine.yield (k, v) -- yield for iterator
    end
  end)
end

-- Now, the `work` function becomes as simple as possible.
-- It does not need to even know of the different coroutine modules
-- that are used.
local function work (data)
  for k, v in iter (data) do
    print ("k: " .. tostring (k), "v: " .. tostring (v))
    -- use `k` and `v`
  end
end

-- Now we can test our program:

schedule (scheduler_coroutine.create (function ()
  work (data)
end))

-- It works!

-- The only change with a source code that only uses the `coroutine` module
-- is to add one line for module instantiation!
