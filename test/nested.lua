#!/usr/bin/env lua

package.path = "../src/?.lua;"..package.path
local inner = require( "coroutine.make" )()
local outer = require( "coroutine.make" )()
--outer = coroutine -- tagging inner yields should be sufficient

local function check( t, ... )
  print( "*", ... )
  local n = select( '#', ... )
  for i = 1, n do
    local a, b = select( i, ... ), t[ i ]
    if a ~= b then
      error( "mismatch at position "..i.." (expected '"..tostring( b )
             .."', got '"..tostring( a ).. "')", 2 )
    end
  end
  if n ~= #t then
    error( "number of values mismatch (expected "..#t..", got "..n..")", 2 )
  end
end

local function _____()
  print( string.rep( "_", 70 ) )
end


local function ifunc( ... )
  check( { "inner", "call" }, ... )
  check( { "inner", "resume", 1 }, inner.yield( "inner", "yield", 1 ) )
  check( { "inner", "resume", 2 }, inner.yield( "inner", "yield", 2 ) )
  check( { "outer", "resume", 1 }, outer.yield( "outer", "yield", 1 ) )
  check( { "outer", "resume", 2 }, outer.yield( "outer", "yield", 2 ) )
  check( { "inner", "resume", 3 }, inner.yield( "inner", "yield", 3 ) )
  return "inner", "return"
end

local function ofunc1()
  local co = inner.wrap( ifunc )
  check( { "inner", "yield", 1 }, co( "inner", "call" ) )
  check( { "inner", "yield", 2 }, co( "inner", "resume", 1 ) )
  check( { "inner", "yield", 3 }, co( "inner", "resume", 2 ) )
  check( { "inner", "return" }, co( "inner", "resume", 3 ) )
  return "outer", "return"
end

local function ofunc2()
  local co = inner.create( ifunc )
  check( { true, "inner", "yield", 1 }, inner.resume( co, "inner", "call" ) )
  check( { true, "inner", "yield", 2 }, inner.resume( co, "inner", "resume", 1 ) )
  check( { true, "inner", "yield", 3 }, inner.resume( co, "inner", "resume", 2 ) )
  check( { true, "inner", "return" }, inner.resume( co, "inner", "resume", 3 ) )
  return "outer", "return"
end

local function cr_test( f )
  local th = outer.create( f )
  check( { true, "outer", "yield", 1 }, outer.resume( th ) )
  check( { true, "outer", "yield", 2 }, outer.resume( th, "outer", "resume", 1 ) )
  check( { true, "outer", "return" }, outer.resume( th, "outer", "resume", 2 ) )
end

local function wr_test( f )
  local th = outer.wrap( f )
  check( { "outer", "yield", 1 }, th() )
  check( { "outer", "yield", 2 }, th( "outer", "resume", 1 ) )
  check( { "outer", "return" }, th( "outer", "resume", 2 ) )
end

cr_test( ofunc1 )
_____()
cr_test( ofunc2 )
_____()
wr_test( ofunc1 )
_____()
wr_test( ofunc2 )
print( "[ ok ]" )

