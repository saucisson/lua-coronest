-- Coroutines that allow nesting
-- =============================
--
-- Coroutines are a powerful notion to suspend and resume execution of
-- lightweight threads. It can be used for instance for scheduling in
-- [copas](http://keplerproject.github.io/copas/, or for
-- [iteration](http://www.lua.org/pil/9.3.html).
--
-- When mixing these two uses, a problem arises: there is no way to specify
-- which `coroutine.resume` should intercept a `coroutine.yield`.
-- See: http://stackoverflow.com/questions/27123966/lua-nested-coroutines
--
-- This module provides a thin wrapper around the standard `coroutine`
-- module to allow the definition of complex behaviors with nested
-- coroutines.

local create  = coroutine.create
local resume  = coroutine.resume
local running = coroutine.running
local status  = coroutine.status
--local wrap    = coroutine.wrap
local yield   = coroutine.yield

return function (tag)
  local coroutine = {}
  tag = tag or {}

  local function for_wrap (status, t, ...)
    if not status then
      error (t, ...)
    else
      return ...
    end
  end

  local function for_resume (co, status, t, ...)
    if not status then
      return status, t, ...
    end
    if tag == t then
      return status, ...
    else
      yield (t, ...)
      return coroutine.resume (co, ...)
    end
  end

  function coroutine.create (f)
    return create (function (...)
      return tag, f (...)
    end)
  end

  function coroutine.resume (co, ...)
    return for_resume (co, resume (co, ...))
  end

  function coroutine.running ()
    return running ()
  end

  function coroutine.status (co)
    return status (co)
  end

  function coroutine.wrap (f)
    local co = coroutine.create (f)
    return function (...)
       return for_wrap (coroutine.resume (co, ...))
    end
  end

  function coroutine.yield (...)
    return yield (tag, ...)
  end

  return coroutine
end
