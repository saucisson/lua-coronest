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

local select      = select
local create      = coroutine.create
local isyieldable = coroutine.isyieldable
local resume      = coroutine.resume
local running     = coroutine.running
local status      = coroutine.status
local wrap        = coroutine.wrap
local yield       = coroutine.yield

return function (tag)
  local coroutine = {
    isyieldable = isyieldable,
    running     = running,
    status      = status,
  }
  tag = tag or {}

  local function for_wrap (co, ...)
    if tag == ... then
      return select (2, ...)
    else
      return for_wrap (co, co (yield (...)))
    end
  end

  local function for_resume (co, status, ...)
    if not status then
      return status, ...
    elseif tag == ... then
      return status, select (2, ...)
    else
      return for_resume (co, resume (co, yield (...)))
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

  function coroutine.wrap (f)
    local co = wrap (function (...)
      return tag, f (...)
    end)
    return function (...)
      return for_wrap (co, co (...))
    end
  end

  function coroutine.yield (...)
    return yield (tag, ...)
  end

  return coroutine
end
