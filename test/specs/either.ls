# # Specification for Either

/** ^
 * Copyright (c) 2013 Quildreen Motta
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

spec = (require 'hifive')!
Either = require '../../lib/'
{for-all, data: {Any:BigAny, Int}, sized} = require 'claire'
{ok, throws} = require 'assert'

{Left, Right} = Either

Any = sized (-> 10), BigAny
k   = (a, b) --> a


module.exports = spec 'Either' (o, spec) ->

  spec 'Constructors' (o) ->
    o 'Left' do
       for-all(Any).satisfy (a) ->
         Left(a).is-left and not Left(a).is-right
       .as-test!
    o 'Right' do
       for-all(Any).satisfy (a) ->
         Right(a).is-right and not Right(a).is-left
       .as-test!
    o 'from-nullable' do
       for-all(Any).satisfy (a) ->
         | a? => Either.from-nullable(a).is-right
         | _  => Either.from-nullable(a).is-left
       .classify (a) ->
         | a? => 'Not null'
         | _  => 'Null'
       .as-test!

  o 'of should always return a Right' do
     for-all(Any).satisfy (a) ->
       Either.of(a).is-equal Right(a)
     .as-test!

  o 'x.ap(b) should keep x for Lefts' do
     for-all(Int).satisfy (a) ->
       Left((a) -> a + 1).ap(Right(a)).is-left
     .as-test!

  o 'map(f) should keep Lefts unchanged' do
     for-all(Any).satisfy (a) ->
       Left(a).map((_) -> [a,a]).is-equal Left(a)
     .as-test!

  o 'chain(f) should keep Lefts unchanged' do
     for-all(Any).satisfy (a) ->
       Left(a).chain((_) -> Right(a)).is-equal Left(a)
     .as-test!

  o 'Left.concat(Right) should keep the Left side' do
     for-all(Any).satisfy (a) ->
       Left(a).concat(Right(a)).is-equal Left(a)
     .as-test!

  o 'Right.concat(Left) should keep the Left side' do
     for-all(Any).satisfy (a) ->
       Right(a).concat(Left(a)).is-equal Left(a)
     .as-test!

  o 'Left.concat(Left) should keep the first Left' do
     for-all(Any).satisfy (a, b) ->
       Left(a).concat(Left(b)).is-equal Left(a)
     .as-test!

  spec 'to-string()' (o) ->
    o 'Right' do
       for-all(Int).satisfy (a) ->
         Right(a).to-string! is "Either.Right(#a)"
       .as-test!
    o 'Left' do
       for-all(Int).satisfy (a) ->
         Left(a).to-string! is "Either.Left(#a)"
       .as-test!

  spec 'is-equal(b)' (o) ->
    o 'Rights are always equivalent to Rights, but not Lefts' do
       for-all(Any).satisfy (a) ->
         Right(a).is-equal(Right(a)) and not Right(a).is-equal(Left(a))
       .as-test!
    o 'Rights are never equal Rights with different values' do
       for-all(Any, Any).given (!==) .satisfy (a, b) ->
         not Right(a).is-equal(Right(b))
       .as-test!

  spec 'get()' (o) ->
    o 'For rights should return the value.' do
       for-all(Any).satisfy (a) ->
         Right(a).get! is a
       .as-test!
    o 'For lefts should throw a type error' do
       for-all(Any).satisfy (a) ->
         throws (-> Left(a).get!), TypeError
         true
       .as-test!

  spec 'get-or-else(a)' (o) ->
    o 'For rights should return the value.' do
       for-all(Any, Any).satisfy (a, b) ->
         Right(a).get-or-else(b) is a
       .as-test!
    o 'For lefts should return the alternative.' do
       for-all(Any, Any).satisfy (a, b) ->
         Left(a).get-or-else(b) is b
       .as-test!

  spec 'or-else(f)' (o) ->
    o 'For rights should return itself' do
       for-all(Any, Any).satisfy (a, b) ->
         Right(a).or-else((-> Left(b))).is-equal Right(a)
       .as-test!
    o 'For lefts should return the Either f returns' do
       for-all(Any, Any).given (!==) .satisfy (a, b) ->
         Left(a).or-else((-> Right(b))).is-equal Right(b)
       .as-test!

  o 'merge() should return any value' do
     for-all(Any).satisfy (a) ->
       Right(a).merge! is Left(a).merge!
     .as-test!

  spec 'fold(f, g)' (o) ->
    o 'For lefts, should call f' do
       for-all(Any, Any, Any).given (!==) .satisfy (a, b, c) ->
         Left(a).fold(k Right(b); k Left(c)).is-equal Right(b)
       .as-test!
    o 'For rights, should call g' do
       for-all(Any, Any, Any).given (!==) .satisfy (a, b, c) ->
         Right(a).fold(k Right(b); k Left(c)).is-equal Left(c)
       .as-test!

  o 'swap()' do
     for-all(Any).satisfy (a) ->
       Right(a).swap!is-equal(Left(a)) and Left(a).swap!is-equal(Right(a))
     .as-test!

  spec 'bimap(f, g)' (o) ->
    o 'For lefts should return a new left mapped by f' do
       for-all(Any, Any, Any)
       .given ((a, b, c) -> a !== b and b !== c)
       .satisfy (a, b, c) ->
         Left(a).bimap(k b; k c).is-equal Left(b)
       .as-test!
    o 'For rights should return a new right mapped by f' do
       for-all(Any, Any, Any)
       .given ((a, b, c) -> a !== c and b !== c)
       .satisfy (a, b, c) ->
         Right(a).bimap(k b; k c).is-equal Right(c)
       .as-test!

  spec 'left-map(f)' (o) ->
    o 'For lefts should return a new left mapped by f' do
       for-all(Any, Any).given (!==) .satisfy (a, b) ->
         Left(a).left-map(k b).is-equal Left(b)
       .as-test!
    o 'For rights should return itself' do
       for-all(Any, Any).given (!==) .satisfy (a, b) ->
         Right(a).left-map(k b).is-equal Right(a)
       .as-test!

  spec 'cata(p)' (o) ->
    o 'For lefts, should apply Left' do
       for-all(Any).satisfy (a) ->
         Left(a).cata(Left: ((x) -> [x, x]), Right: ((x) -> [x])) === [a, a]
       .as-test!
    o 'For rights, should apply Right' do
       for-all(Any).satisfy (a) ->
         Right(a).cata(Left: ((x) -> [x, x]), Right: ((x) -> [x])) === [a]
       .as-test!
    
