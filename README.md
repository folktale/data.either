Data.Either
===========

[![Build Status](https://secure.travis-ci.org/folktale/data.either.png?branch=master)](https://travis-ci.org/folktale/data.either)
[![NPM version](https://badge.fury.io/js/data.either.png)](http://badge.fury.io/js/data.either)
[![Dependencies Status](https://david-dm.org/folktale/data.either.png)](https://david-dm.org/folktale/data.either)
[![stable](http://hughsk.github.io/stability-badges/dist/stable.svg)](http://github.com/hughsk/stability-badges)


The `Either(a, b)` structure represents the logical disjunction between `a` and
`b`. In other words, `Either` may contain either a value of type `a` or a value
of type `b`, at any given time. This particular implementation is biased on the
right value (`b`), thus projections will take the right value over the left
one.

A common use of this structure is to represent computations that may fail, when you
want to provide additional information on the failure. This can force failures
and their handling to be explicit, and avoid the problems associated with
throwing exceptions — non locality, abnormal exits, etc.

Furthermore, being a monad, `Either(a, b)` can be composed in manners similar
to other monads, by using the generic sequencing and composition operations
provided for the common interface in [Fantasy Land][].


## Example

```js
// Returns the contents of the file at `path`, if it exists.
//
//  read : String -> Either(Error, String)
function read(path) {
  return exists(path)?     Either.Right(fread(path))
  :      /* otherwise */   Either.Left("Non-existing file: " + path)
}

var intro = read('intro.txt')  // => Right(...)
var outro = read('outro.txt')  // => Right(...)
var nope  = read('nope.txt')   // => Left("Non-existing file: nope.txt")

// We can concatenate things without knowing if they exist at all, and
// failures are handled for us
intro.chain(function(a) {
  return outro.map(function(b) {
    return a + b
  })
}).orElse(logFailure)
// => Right(...)

intro.chain(function(a) {
  return nope.map(function(b) {
    return a + b
  })
})
// => Left("Non-existing file: nope.txt")
```


## Installing

The easiest way is to grab it from NPM. If you're running in a Browser
environment, you can use [Browserify][]

    $ npm install data.either


### Using with CommonJS

If you're not using NPM, [Download the latest release][release], and require
the `data.either.umd.js` file:

```js
var Either = require('data.either')
```


### Using with AMD

[Download the latest release][release], and require the `data.either.umd.js`
file:

```js
require(['data.either'], function(Either) {
  ( ... )
})
```


### Using without modules

[Download the latest release][release], and load the `data.either.umd.js`
file. The properties are exposed in the global `folktale.data.Either` object:

```html
<script src="/path/to/data.either.umd.js"></script>
```


### Compiling from source

If you want to compile this library from the source, you'll need [Git][],
[Make][], [Node.js][], and run the following commands:

    $ git clone git://github.com/folktale/data.either.git
    $ cd data.either
    $ npm install
    $ make bundle
    
This will generate the `dist/data.either.umd.js` file, which you can load in
any JavaScript environment.

    
## Documentation

You can [read the documentation online][docs] or build it yourself:

    $ git clone git://github.com/folktale/data.either.git
    $ cd data.either
    $ npm install
    $ make documentation

Then open the file `docs/index.html` in your browser.


## Platform support

This library assumes an ES5 environment, but can be easily supported in ES3
platforms by the use of shims. Just include [es5-shim][] :)


## Licence

Copyright (c) 2013 Quildreen Motta.

Released under the [MIT licence](https://github.com/folktale/data.either/blob/master/LICENCE).

<!-- links -->
[Fantasy Land]: https://github.com/fantasyland/fantasy-land
[Browserify]: http://browserify.org/
[Git]: http://git-scm.com/
[Make]: http://www.gnu.org/software/make/
[Node.js]: http://nodejs.org/
[es5-shim]: https://github.com/kriskowal/es5-shim
[docs]: http://docs.folktalejs.org/en/latest/api/data/either/index.html
<!-- [release: https://github.com/folktale/data.either/releases/download/v$VERSION/data.either-$VERSION.tar.gz] -->
[release]: https://github.com/folktale/data.either/releases/download/v1.5.1/data.either-1.5.1.tar.gz
<!-- [/release] -->
