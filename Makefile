.PHONY: all build publish watch clean check

all: build

build: site
	./site build

site: site.hs
	ghc --make -threaded site.hs

publish: build
	./publish.sh "$(m)"

watch: build
	./site watch

check: build
	./site check
