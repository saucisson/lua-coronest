package = "coroutine"
version = "master-1"

source = {
  url = "git://github.com/saucisson/nested-coroutines",
}

description = {
  summary     = "Coroutines that allow nesting",
  detailed    = [[
Coroutines are a powerful notion to suspend and resume execution of
lightweight threads. They can be used for instance for scheduling,
or for iteration.

When mixing these two uses, a problem arises: there is no way to specify
which `coroutine.resume` should intercept a `coroutine.yield`.

This module provides a thin wrapper around the standard `coroutine`
module to allow the definition of complex behaviors with nested
coroutines.
  ]],
  license     = "MIT/X11",
  maintainer  = "Alban Linard <alban@linard.fr>",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type    = "builtin",
  modules = {
    ["coroutine.make"] = "src/coroutine/make.lua",
  },
}
