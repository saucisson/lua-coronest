#!/usr/bin/env lua

package.path = "../src/?.lua;"..package.path
local inner = require( "coroutine.make" )()
local outer = coroutine -- tagging inner yields should be sufficient
--outer = require( "coroutine.make" )()

local L = table.pack or function( ... )
  return { n = select( '#', ... ), ... }
end

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
  if n ~= t.n then
    error( "number of values mismatch (expected "..t.n..", got "..n..")", 2 )
  end
end

local function _____()
  print( string.rep( "_", 70 ) )
end


local function ifunc( ... )
  check( L( "inner", "call" ), ... )
  check( L( "inner", "resume", 1 ), inner.yield( "inner", "yield", 1 ) )
  check( L( "inner", "resume", 2 ), inner.yield( "inner", "yield", 2 ) )
  check( L( "outer", "resume", 1 ), outer.yield( "outer", "yield", 1 ) )
  check( L( "outer", "resume", 2 ), outer.yield( "outer", "yield", 2 ) )
  check( L( "outer", "resume", 3 ), outer.yield() ) -- yield with no args
  check( L( "inner", "resume", 3 ), inner.yield( "inner", "yield", 3 ) )
  return "inner", "return"
end

local function ofunc1( ... )
  check( L( "outer", "call" ), ... )
  local co = inner.wrap( ifunc )
  check( L( "inner", "yield", 1 ), co( "inner", "call" ) )
  check( L( "inner", "yield", 2 ), co( "inner", "resume", 1 ) )
  check( L( "inner", "yield", 3 ), co( "inner", "resume", 2 ) )
  check( L( "inner", "return" ), co( "inner", "resume", 3 ) )
  return "outer", "return"
end

local function ofunc2( ... )
  check( L( "outer", "call" ), ... )
  local co = inner.create( ifunc )
  check( L( true, "inner", "yield", 1 ), inner.resume( co, "inner", "call" ) )
  check( L( true, "inner", "yield", 2 ), inner.resume( co, "inner", "resume", 1 ) )
  check( L( true, "inner", "yield", 3 ), inner.resume( co, "inner", "resume", 2 ) )
  check( L( true, "inner", "return" ), inner.resume( co, "inner", "resume", 3 ) )
  return "outer", "return"
end

local function cr_test( f )
  local th = outer.create( f )
  check( L( true, "outer", "yield", 1 ), outer.resume( th, "outer", "call" ) )
  check( L( true, "outer", "yield", 2 ), outer.resume( th, "outer", "resume", 1 ) )
  check( L( true ), outer.resume( th, "outer", "resume", 2 ) )
  check( L( true, "outer", "return" ), outer.resume( th, "outer", "resume", 3 ) )
end

local function wr_test( f )
  local th = outer.wrap( f )
  check( L( "outer", "yield", 1 ), th( "outer", "call" ) )
  check( L( "outer", "yield", 2 ), th( "outer", "resume", 1 ) )
  check( L(), th( "outer", "resume", 2 ) )
  check( L( "outer", "return" ), th( "outer", "resume", 3 ) )
end

cr_test( ofunc1 )
_____()
cr_test( ofunc2 )
_____()
wr_test( ofunc1 )
_____()
wr_test( ofunc2 )
print( "[ ok ]" )

