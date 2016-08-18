package = "coronest-env"
version = "master-1"

source = {
  url    = "git+https://github.com/saucisson/lua-coronest.git",
  branch = "master",
}

description = {
  summary     = "Development environment for coronest",
  detailed    = [[]],
  license     = "MIT/X11",
  homepage    = "https://github.com/saucisson/lua-coronest",
  maintainer  = "Alban Linard <alban@linard.fr>",
}

dependencies = {
  "lua >= 5.1",
  "busted",
  "cluacov",
  "luacheck",
  "luacov",
  "luacov-coveralls",
}

build = {
  type    = "builtin",
  modules = {},
}
