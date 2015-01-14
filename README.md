Coroutines that allow nesting
=============================

Coroutines are a powerful notion to suspend and resume execution of
lightweight threads. It can be used for instance for scheduling,
as in [copas](http://keplerproject.github.io/copas/), or for
[iteration](http://www.lua.org/pil/9.3.html).

When mixing these two uses, a problem arises: there is no way to specify
which `coroutine.resume` should intercept a `coroutine.yield`.

This module provides a thin wrapper around the standard `coroutine`
module to allow the definition of complex behaviors with nested
coroutines.

Usage
-----

Everywhere you are using the standard Lua `coroutine` module,
replace it with an instance of the nested coroutines:

```lua
    local coroutine = require "coroutine.make" ()
```

For an example, please look at
[the example](https://github.com/saucisson/nested-coroutines/tree/master/examples/usage.lua).

Contributors
------------

This module has been built after the [following discussion on StackOverflow](http://stackoverflow.com/questions/27123966/lua-nested-coroutines).
Even if [Alban Linard (saucisson)](https://github.com/saucisson) owns this repository,
the main contributor is [Philipp Janda (siffiejoe)](https://github.com/siffiejoe).
