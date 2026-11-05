#!/bin/sh
# Build the demonstration site into _site/ (index.html, pdf/, img/). Run from the repository root:
#   sh site/build.sh
# Needs Typst with HTML export (`--features html`). Building everything also checks that every
# seal, styling and example compiles.
set -eu
out=_site
rm -rf "$out"
mkdir -p "$out/pdf" "$out/img"

typst compile --root . --features html --format html site/index.typ "$out/index.html"

for f in letter gallery styling placement content-source; do
  typst compile --root . "examples/$f.typ" "$out/pdf/$f.pdf"
done
typst compile --root . examples/letter.typ "$out/img/letter.png" --ppi 110

echo "site built in $out/ ($(du -sh "$out" | cut -f1))"
