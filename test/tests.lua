local assert = require "luassert"

describe ("Nested coroutines", function ()

  it ("can be required", function ()
    assert.has.no.error (function ()
      local make = require "coroutine.make"
    end)
  end)

  it ("can be instantiated with no tag", function ()
    local make = require "coroutine.make"
    assert.has.no.error (function ()
      local instance = make ()
    end)
  end)
  it ("can be instantiated with a tag", function ()
    local make = require "coroutine.make"
    assert.has.no.error (function ()
      local instance = make "tag"
    end)
  end)

  pending "TODO"
end)
