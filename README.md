[![Build status](https://travis-ci.org/saucisson/lua-coronest.svg?branch=master)](https://travis-ci.org/saucisson/lua-coronest.svg?branch=master)
[![Chat](https://badges.gitter.im/saucisson/lua-coronest.svg)](https://gitter.im/saucisson/lua-coronest?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# Coroutines that allow nesting

Coroutines are a powerful notion to suspend and resume execution of
lightweight threads. It can be used for instance for scheduling,
as in [copas](http://keplerproject.github.io/copas/), or for
[iteration](http://www.lua.org/pil/9.3.html).

When mixing these two uses, a problem arises: there is no way to specify
which `coroutine.resume` should intercept a `coroutine.yield`.

This module provides a thin wrapper around the standard `coroutine`
module to allow the definition of complex behaviors with nested
coroutines.

## Install

This module is available in [luarocks](https://luarocks.org):

````sh
    luarocks install coronest
````

## Usage

Everywhere you are using the standard Lua `coroutine` module,
replace it with an instance of the nested coroutines:

```lua
    local coroutine = require "coroutine.make" ()
```

For an example, please look at `examples/usage.lua`.

## Compatibility and Testing

Nested coroutines should be compatible with any version of Lua supporting
coroutines (well, at least from `5.1`). As the module is written in pure Lua,
it also works with [LuaJIT](http://luajit.org/).

This module comes with some tests:

* `tests/nested.lua` are important checks on the behavior of nested coroutines;
* `tests/lua-5.*.lua` are tests imported from the [Lua testsuite](http://www.lua.org/tests/),
  but using `coroutine.make` instead of standard coroutines;
  they allow to check that nested coroutines do not break anything.

# Contributors

This module has been built after
[this discussion on StackOverflow](http://stackoverflow.com/questions/27123966).
Even if [Alban Linard (saucisson)](https://github.com/saucisson) owns this
repository, the main contributor is
[Philipp Janda (siffiejoe)](https://github.com/siffiejoe).
