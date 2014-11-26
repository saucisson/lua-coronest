package = "coroutine"
version = "master-1"

source = {
   url = "git://github.com/saucisson/nested-coroutine",
}

description = {
  summary     = "",
  detailed    = [[
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
