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

dist/data.either.umd.js: compile dist
	$(browserify) lib/index.js --standalone folktale.data.Either > $@

dist/data.either.umd.min.js: dist/data.either.umd.js
	$(uglify) --mangle - < $^ > $@

# ----------------------------------------------------------------------
bundle: dist/data.either.umd.js

minify: dist/data.either.umd.min.js

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
	mkdir -p dist/data.either-$(VERSION)
	cp -r docs/literate dist/data.either-$(VERSION)/docs
	cp -r lib dist/data.either-$(VERSION)
	cp dist/*.js dist/data.either-$(VERSION)
	cp package.json dist/data.either-$(VERSION)
	cp README.md dist/data.either-$(VERSION)
	cp LICENCE dist/data.either-$(VERSION)
	cd dist && tar -czf data.either-$(VERSION).tar.gz data.either-$(VERSION)

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
