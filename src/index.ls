# # Monad: Either(a, b)
#
# The `Either(a, b)` structure represents the logical disjunction between
# `a` and `b`. In other words, `Either` may contain either a value of
# type `a` or a value of type `b`, at any given time. This particular
# implementation is biased on the right value (`b`), thus projections
# will take the right value over the left one.


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

# This class models two different cases: `Left a` and `Right b`, and can
# hold one of the cases at any given time. The projections are, none the
# less, biased for the `Right` case, thus a common use case for this
# structure is to hold the results of computations that may fail, when you
# want to store additional information on the failure (instead of
# throwing an exception).
#  
# Furthermore, the values of `Either(a, b)` can be combined and
# manipulated by using the expressive monadic operations. This allows
# safely sequencing operations that may fail, and safely composing
# values that you don't know whether they're present or not, failing
# early (returning a `Left a`) if any of the operations fail.
#  
# While this class can certainly model input validations, the
# [Validation][] structure lends itself better to that use case, since it
# can naturally aggregate failures — monads shortcut on the first
# failure.
#  
# [Validation]: https://github.com/folktale/data.validation

# ## Class: Either(a, b)
#
# The `Either(a, b)` monad.
#  
# + type: Either(a, b) <: Applicative, Functor, Chain, Show, Eq
class Either
  ->

  # ### Constructors ###################################################

  # #### Function: Left
  #
  # Constructs a new `Either(a, b)` monad holding a `Left` value. This
  # usually represents a failure due to the right-bias of this monad.
  #  
  # + type: a -> Either(a, b)
  Left: (a) -> new Left(a)

  # #### Function: Right
  #
  # Constructs a new `Either(a, b)` monad holding a `Right` value. This
  # usually represents a successful value due to the right-bias of this
  # monad.
  #  
  # + type: b -> Either(a, b)
  Right: (b) -> new Right(b)

  # #### Function: from-nullable
  #
  # Constructs a new `Either(a, b)` from a nullable type. Takes the
  # `Left` case if the value is `null` or `undefined`. Takes the `Right`
  # case otherwise.
  #
  # + type: a -> Either(a, a)
  from-nullable: (a) ->
    | a? => new Right(a)
    | _  => new Left(a)


  # ### Predicates #####################################################

  # #### Field: is-left
  #
  # True if the `Either(a, b)` contains a `Left` value.
  #
  # + type: Boolean
  is-left: false

  # #### Field: is-right
  #
  # True if the `Either(a, b)` contains a `Right` value.
  #
  # + type: Boolean
  is-right: false


  # ### Applicative ####################################################

  # #### Function: of
  #
  # Creates a new `Either(a, b)` instance holding the `Right` value
  # `b`.
  #  
  # `b` can be any value, including `null`, `undefined` or another
  # `Either(a, b)` monad.
  #  
  # + type: b -> Either(a, b)
  of: (b) -> new Right(b)

  # #### Function: ap
  #
  # Applies the function inside the `Right` case of the `Either(a, b)`
  # monad to another applicative type.
  #
  # The `Either(a, b)` monad should contain a function value, otherwise
  # a `TypeError` is thrown.
  #
  # + type: (@Either(a, b -> c), f:Applicative) => f(b) -> f(c)
  ap: (_) -> ...


  # ### Functor ########################################################

  # #### Function: map
  #
  # Transforms the `Right` value of the `Either(a, b)` monad using a
  # regular unary function.
  #  
  # + type: (@Either(a, b)) => (b -> c) -> Either(a, c)
  map: (_) -> ...


  # ### Chain ##########################################################

  # #### Function: chain
  #
  # Transforms the `Right` value of the `Either(a, b)` monad using an
  # unary function to a monad of the same type.
  #  
  # + type: (@Either(a, b)) => (b -> Either(a, c)) -> Either(a, c)
  chain: (_) -> ...


  # ### Show ###########################################################

  # #### Function: to-string
  #
  # Returns a textual representation of the `Either(a, c)` monad.
  #  
  # + type: (@Either(a, b)) => Unit -> String
  to-string: -> ...


  # ### Eq #############################################################

  # #### Function: is-equal
  #
  # Tests if an `Either(a, b)` monad is equal to another `Either(a, b)`
  # monad.
  #
  # + type: (@Either(a, b)) => Either(a, b) -> Boolean
  is-equal: (_) -> ...


  # ### Extracting and Recovering ######################################

  # #### Function: get
  #
  # Extracts the `Right` value out of the `Either(a, b)` monad, if it
  # exists. Otherwise throws a `TypeError`.
  #  
  # + see: get-or-else — A getter that can handle failures.
  # + see: merge — Returns the convergence of both values.
  # + type: (@Either(a, b), *throws) => Unit -> b
  # + throws: TypeError — if the monad doesn't have a `Right` value.
  get: -> ...

  # #### Function: get-or-else
  #
  # Extracts the `Right` value out of the `Either(a, b)` monad. If
  # the monad doesn't have a `Right` value, returns the given default.
  #
  # + type: (@Either(a, b)) => b -> b
  get-or-else: (_) -> ...

  # #### Function: or-else
  #
  # Transforms a `Left` value into a new `Either(a, b)` monad. Does
  # nothing if the monad contains a `Right` value.
  #
  # + type: (@Either(a, b)) => (a -> Either(c, b)) -> Either(c, b)
  or-else: (_) -> ...

  # #### Function: merge
  #
  # Returns the value of whichever side of the disjunction that is
  # present.
  #
  # + type: (@Either(a, a)) => Unit -> a
  merge: -> @value


  # ### Folds and Extended Transformations #############################

  # #### Function: fold
  #
  # Catamorphism. Takes two functions, applies the leftmost one to the
  # `Left` value and the rightmost one to the `Right` value, depending
  # on which one is present.
  #
  # + type: (@Either(a, b)) => (a -> c) -> (b -> c) -> c
  fold: (f, g) --> ...

  # #### Function: swap
  #
  # Swaps the disjunction values.
  #  
  # + type: (@Either(a, b)) => Unit -> Either(b, a)
  swap: -> ...

  # #### Function: bimap
  #
  # Maps both sides of the disjunction.
  #
  # + type: (@Either(a, b)) => (a -> c) -> (b -> d) -> Either(c, d)
  bimap: (f, g) --> ...
  
  # #### Function: left-map
  #
  # Maps the left side of the disjunction.
  #  
  # + type: (@Either(a, b)) => (a -> c) -> Either(c, b)
  left-map: (f) -> ...


# ## Class: Right(a)
#
# Represents the `Right` side of the disjunction.
class Right extends Either
  (@value) ->
  is-right: true
  ap: (b) -> b.map @value
  map: (f) -> @of (f @value)
  chain: (f) -> f @value
  to-string: -> "Either.Right(#{@value})"
  is-equal: (a) -> a.is-right and (a.value is @value)
  get: -> @value
  get-or-else: (_) -> @value
  or-else: (_) -> this
  fold: (_, g) -> g @value
  swap: -> new Left(@value)
  bimap: (_, g) -> new Right(g @value)
  left-map: (_) -> this
  

# ## Class: Left(a)
#
# Represents the `Left` side of the disjunction.
class Left extends Either
  (@value) ->
  is-left: true
  ap: (b) -> b
  map: (_) -> this
  chain: (_) -> this
  to-string: -> "Either.Left(#{@value})"
  is-equal: (a) -> a.is-left and (a.value is @value)
  get: -> throw new TypeError("Can't extract the value of a Left(a)")
  get-or-else: (a) -> a
  or-else: (f) -> f @value
  fold: (f, _) -> f @value
  swap: -> new Right(@value)
  bimap: (f, _) -> new Left(f @value)
  left-map: (f) -> new Left(f @value)


# ## Exports
module.exports = new Either
