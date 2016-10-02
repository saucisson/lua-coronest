local select      = select
local create      = coroutine.create
local isyieldable = coroutine.isyieldable
local resume      = coroutine.resume
local running     = coroutine.running
local status      = coroutine.status
local wrap        = coroutine.wrap
local yield       = coroutine.yield

local depth = 1
local maxdepth = math.huge -- Change this to change max coroutine depth --

local function prep(f) -- Prepare function environment --
  if getfenv and setfenv and setmetatable then
    local tbo = getfenv(f)
    local tba = setmetatable({coroutine = coronest()},{__index = tbo, __newindex = tbo})
    setfenv(f,tba)
  elseif debug and debug.getupvalue and debug.setupvalue and setmetatable then
    local tbo = debug.getupvalue(f,1)
    local tba = setmetatable({coroutine = coronest()},{__index = tbo, __newindex = tbo})
    debug.setupvalue(f,1,tba)
  end
  return f
end

local coronest
coronest = function (tag)
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

  local function for_resume (co, st, ...)
    if not st then
      return st, ...
    elseif tag == ... then
      return st, select (2, ...)
    else
      return for_resume (co, resume (co, yield (...)))
    end
  end

  function coroutine.create (fa)
    local f = prep(fa)
    return create (function (...)
      return tag, f (...)
    end)
  end

  function coroutine.resume (co, ...)
    if depth >= maxdepth then
      return false, "Maximum coroutine depth ".. maxdepth .." reached!"
    end
    depth = depth + 1
    return for_resume (co, resume (co, ...))
  end

  function coroutine.wrap (fa)
    local f = prep(fa)
    local co = wrap (function (...)
      return tag, f (...)
    end)
    return function (...)
      return for_wrap (co, co (...))
    end
  end

  function coroutine.yield (...)
    depth = depth - 1
    return yield (tag, ...)
  end

  return coroutine
end
return coronest
