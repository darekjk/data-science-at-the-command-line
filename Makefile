.PHONY: clean 1e 2e redirects live publish-draft publish-production sync-atlas asciidoc
.SUFFIXES:

.ONESHELL:
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -e

clean:
	rm book/2e/book.md

live:
	cd www && hugo server --disableFastRender

2e: book/2e/*.Rmd
	cd book/2e && rm -f book.md && Rscript --vanilla -e 'bookdown::render_book("index.Rmd", encoding = "UTF-8", clean = FALSE)'

1e: www/static/1e/index.html

redirects: www/static/_redirects

www/static/1e/index.html: book/1e/*
	cd book/1e && Rscript --vanilla -e 'bookdown::render_book("index.Rmd", encoding = "UTF-8")'


www/static/_redirects:
	curl -sL datascienceatthecommandline.com/1e | \
	grep -Eo 'href="(.*)\.html"' | \
	grep -v 'index' |	\
	cut -d\" -f 2 | \
	sort -n | \
	uniq | \
	sed -E "s|(.*)|/\1 /1e/\1|" > $@


publish-draft:
	(cd www && hugo) && netlify deploy --dir www/public

publish-production:
	(cd www && hugo) && netlify deploy --prod --dir www/public

book/2e/%.utf8.md: book/2e/%.Rmd
	cd book/2e && Rscript --vanilla -e 'bookdown::render_book("$*.Rmd", encoding = "UTF-8", preview = TRUE, clean = FALSE)'


ch01: book/2e/01.utf8.md
ch02: book/2e/02.utf8.md
ch03: book/2e/03.utf8.md
ch04: book/2e/04.utf8.md
ch05: book/2e/05.utf8.md
ch06: book/2e/06.utf8.md
ch11: book/2e/11.utf8.md

ch%: book/2e/%.utf8.md

book/2e/atlas/ch%.asciidoc: book/2e/%.utf8.md
	< $< book/2e/bin/atlas.sh > $@

asciidoc: book/2e/atlas/ch00.asciidoc book/2e/atlas/ch01.asciidoc book/2e/atlas/ch02.asciidoc book/2e/atlas/ch03.asciidoc book/2e/atlas/ch04.asciidoc book/2e/atlas/ch06.asciidoc book/2e/atlas/ch11.asciidoc

sync-atlas: asciidoc
	@cp -v book/2e/atlas/*.asciidoc ../../atlas/data-science-at-the-command-line-2e/
	@cp -v book/2e/images/* ../../atlas/data-science-at-the-command-line-2e/images
	@echo "Syncing Asciidoc files to Atlas"

docker-run:
	docker run -it --rm -v $$(pwd)/book/2e/data:/data -p 8000:8000 datasciencetoolbox/dsatcl2e:latest

update-cache:
	cd book/2e/data/cache && \
  curl -sL 'https://github.com/r-dbi/RSQLite/raw/master/inst/db/datasets.sqlite' -O && \
  ls -lAshF

attach:
	tmux set-option window-size manual &&\
	tmux attach -t knitractive_console
