# paraph

Data seals for Typst letters: a small circular mark that is a visual fingerprint of your letter's text. Change a character and the seal changes.

> **Status:** under construction. See the [tracking issue](https://github.com/aarmey/paraph/issues/1).
>
> paraph is **not** cryptographic. Its hash is a simple non-secure function that only maps text to 256 bits.

## Development

Requires Typst 0.14 or newer (developed on 0.15.1; check with `typst --version`).

Examples and tests import the package directly:

```typst
#import "../lib.typ": *
```

To use it from other documents as a local package, link it into Typst's data directory:

```bash
mkdir -p "$HOME/Library/Application Support/typst/packages/local/paraph"
ln -s "$PWD" "$HOME/Library/Application Support/typst/packages/local/paraph/0.1.0"
```

(On Linux the directory is `~/.local/share/typst/packages/local/paraph/0.1.0`.) Then `#import "@local/paraph:0.1.0": *`.

Compile everything CI does:

```bash
mkdir -p out && for f in tests/*.typ examples/*.typ; do typst compile --root . "$f" "out/$(basename "$f" .typ).pdf"; done
```

## License

MIT-0
