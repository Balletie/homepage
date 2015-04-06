.PHONY: all build publish watch clean check

all: build

build: site
	./site build

site: site.hs
	ghc --make -threaded site.hs

watch: build
	./site watch

check: build
	./site check
