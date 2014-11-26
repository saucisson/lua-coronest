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

  it ("", function ()
    local make = require "coroutine.make"
    local c1 = make ()
    local c2 = make ()
    local coro1 = c1.create (function ()
      c1.yield (1)
    end)
    local coro2 = c2.create (function ()
      local status, value = c1.resume (coro1)
      assert (status and value == 1)
      c2.yield (value)
    end)
    local status, value = c2.resume (coro2)
    assert (status and value == 1)
  end)

  it ("allows to pass values with resume/yield", function ()
    local make = require "coroutine.make"
    local coroutine = make ()
    local coro = coroutine.create (function (i)
      return coroutine.yield (coroutine.yield (i+1)+1)+1
    end)
    local s1, v1 = coroutine.resume (coro, 1)
    assert.is_true (s1)
    assert.are_equal (v1, 2)
    local s2, v2 = coroutine.resume (coro, v1)
    assert.is_true (s2)
    assert.are_equal (v2, 3)
    local s3, v3 = coroutine.resume (coro, v2)
    assert.is_true (s3)
    assert.are_equal (v3, 4)
  end)

  it ("should work for nested coroutines", function ()
    local make = require "coroutine.make"
    local c1 = make ()
    local c2 = make ()
    local coro1, coro2
    coro1 = c1.create (function ()
      local s1, v1 = c2.resume (coro2)
      print ("coro1", "s1", s1, "v1", v1)
      assert.is_true (s1)
      assert.are.equal (v1, 1)
      local s2, v2 = c2.resume (coro2)
      print ("coro1", "s2", s2, "v2", v2)
      assert.is_true (s2)
      assert.are.equal (v2, 3)
      return 4
    end)
    coro2 = c2.create (function ()
      c2.yield (1)
      c1.yield (2)
      print "resumed"
      c2.yield (3)
    end)
    local s1, v1 = c1.resume (coro1)
    print ("main", "s1", s1, "v1", v1)
    assert.is_true (s1)
    assert.are.equal (v1, 2)
    local s2, v2 = c1.resume (coro1)
    print ("main", "s2", s2, "v2", v2)
    assert.is_true (s2)
    assert.are.equal (v1, 4)
  end)

  pending "TODO"
end)
