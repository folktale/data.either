bin        = $(shell npm bin)
lsc        = $(bin)/lsc
browserify = $(bin)/browserify
groc       = $(bin)/groc
uglify     = $(bin)/uglifyjs
VERSION    = $(shell node -e 'console.log(require("./package.json").version)')


lib: src/*.ls
	$(lsc) -o lib -c src/*.ls

dist:
	mkdir -p dist

dist/monads.either.umd.js: compile dist
	$(browserify) lib/index.js --standalone Either > $@

dist/monads.either.umd.min.js: dist/monads.either.umd.js
	$(uglify) --mangle - < $^ > $@

# ----------------------------------------------------------------------
bundle: dist/monads.either.umd.js

minify: dist/monads.either.umd.min.js

compile: lib

documentation:
	$(groc) --index "README.md"                                              \
	        --out "docs/literate"                                            \
	        src/*.ls test/*.ls test/specs/**.ls README.md

clean:
	rm -rf dist build lib

test:
	$(lsc) test/tap.ls

package: compile documentation bundle minify
	mkdir -p dist/monads.either-$(VERSION)
	cp -r docs/literate dist/monads.either-$(VERSION)/docs
	cp -r lib dist/monads.either-$(VERSION)
	cp dist/*.js dist/monads.either-$(VERSION)
	cp package.json dist/monads.either-$(VERSION)
	cp README.md dist/monads.either-$(VERSION)
	cp LICENCE dist/monads.either-$(VERSION)
	cd dist && tar -czf monads.either-$(VERSION).tar.gz monads.either-$(VERSION)

publish: clean
	npm install
	npm publish

bump:
	node tools/bump-version.js $$VERSION_BUMP

bump-feature:
	VERSION_BUMP=FEATURE $(MAKE) bump

bump-major:
	VERSION_BUMP=MAJOR $(MAKE) bump


.PHONY: test
