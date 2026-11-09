# type `make` to render every markdown file into html next to it.
SITE_URL := https://kppashin-code.github.io

MD   := index.md $(wildcard p/*.md)
HTML := $(MD:.md=.html)

all: $(HTML) redirects sitemap.xml

%.html: %.md template.html site.yml style.css
	pandoc $< --from markdown --to html5 --standalone \
	  --template template.html --metadata-file site.yml \
	  --metadata cssv=$(shell md5 -q style.css) --metadata pagepath=$(patsubst index.html,,$@) -o $@

# each line of the redirects file becomes a tiny meta-refresh page.
redirects: redirects.txt
	@grep -v '^\s*#' redirects.txt | grep -v '^\s*$$' | while read name url; do \
	  mkdir -p r/$$name; \
	  printf '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=%s"><link rel="canonical" href="%s"><a href="%s">%s</a>\n' "$$url" "$$url" "$$url" "$$url" > r/$$name/index.html; \
	done

sitemap.xml: $(HTML)
	@{ echo '<?xml version="1.0" encoding="UTF-8"?>'; \
	   echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'; \
	   for f in $(HTML); do \
	     loc=$$(echo $$f | sed 's/index\.html$$//'); \
	     echo "  <url><loc>$(SITE_URL)/$$loc</loc><lastmod>$$(date -r $$f +%Y-%m-%d)</lastmod></url>"; \
	   done; echo '</urlset>'; } > $@

serve: all
	python3 -m http.server 8000

clean:
	rm -rf $(HTML) sitemap.xml r

.PHONY: all redirects serve clean
