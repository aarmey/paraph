// Public API: one entry point for every seal, plus placement on the page.
//
//   seal(source, kind: "ring", ..opts)         inline seal (optionally with a caption)
//   seal-at(source, kind:, alignment:, ..)     out-of-flow placement: never reflows text
//   seal-page(source, layer:, ..)              dictionary to spread into `set page(..)`
//   seal-digest(source)                        the hex digest behind a seal
//
// `source` is anything `message` accepts: str, bytes, content, array, dictionary.

#import "core.typ": defaults, with-opacity
#import "digest.typ": digest-hex
#import "input.typ": source-digest
#import "seals/ring.typ": ring-seal
#import "seals/phyllotaxis.typ": phyllotaxis-seal
#import "seals/truchet.typ": truchet-seal
#import "seals/rule30.typ": rule30-seal
#import "seals/chord.typ": chord-seal

/// The available seal kinds and their drawing functions.
#let kinds = (
  ring: ring-seal,
  phyllotaxis: phyllotaxis-seal,
  truchet: truchet-seal,
  rule30: rule30-seal,
  chord: chord-seal,
)

#let _check-kind(kind) = assert(
  type(kind) == str and kind in kinds,
  message: "paraph: unknown seal kind " + repr(kind) + ". Available: " + kinds.keys().join(", "),
)

/// Lowercase hex digest (64 characters) of `source`. This is what every seal encodes;
/// handy for printing or logging next to a letter.
#let seal-digest(source, salt: "") = digest-hex(source-digest(source, salt: salt))

/// An inline seal of the given `kind` ("ring", "phyllotaxis", "truchet", "rule30" or "chord").
/// All options of that seal pass through (`size`, `ink`, `strength`, `rotation`, ...).
/// Extra options here:
///  - `caption: true` prints the first 8 hex characters of the digest under the seal
///  - `caption-text`: replace the printed text (str or content)
///  - `caption-size` (default 5pt), `caption-font` (a monospace by default), `caption-gap`
#let seal(
  source,
  kind: "ring",
  caption: false,
  caption-text: auto,
  caption-size: 5pt,
  caption-font: ("DejaVu Sans Mono", "Menlo", "Courier New"),
  caption-gap: 2pt,
  ..opts,
) = {
  _check-kind(kind)
  assert(opts.pos().len() == 0, message: "paraph: seal options must be named")
  assert(type(caption) == bool, message: "paraph: caption must be true or false")
  let named = opts.named()
  let drawn = (kinds.at(kind))(source, ..named)
  if not caption { return drawn }

  let text-str = if caption-text == auto {
    seal-digest(source, salt: named.at("salt", default: "")).slice(0, 8)
  } else { caption-text }
  box(width: named.at("size", default: defaults.size), stack(
    dir: ttb,
    spacing: caption-gap,
    drawn,
    align(center, text(
      font: caption-font,
      size: caption-size,
      fill: with-opacity(named.at("ink", default: defaults.ink), 0.8, named.at("strength", default: 1.0)),
      text-str,
    )),
  ))
}

/// Does `pages` select physical page `n` of `total`? `pages` is "all", "first", "last",
/// an integer (1-based; negative counts from the end, so -1 is the last page), an array
/// of those, or a function from page number to bool.
#let page-ok(pages, n, total) = {
  if pages == "all" { true } else if pages == "first" { n == 1 } else if pages == "last" { n == total } else if type(pages) == int {
    n == if pages < 0 { total + 1 + pages } else { pages }
  } else if type(pages) == array { pages.any(p => page-ok(p, n, total)) } else if type(pages) == function { pages(n) == true } else {
    panic("paraph: pages must be \"all\", \"first\", \"last\", an integer, an array of those, or a function")
  }
}

#let _check-pages(pages) = {
  if type(pages) == array { for p in pages { _check-pages(p) } } else {
    assert(
      pages in ("all", "first", "last") or type(pages) in (int, function),
      message: "paraph: pages must be \"all\", \"first\", \"last\", an integer, an array of those, or a function",
    )
  }
}

/// A seal placed out of the flow, so it never reflows text. Where it ends up depends on where
/// you put the result:
///  - in `set page(foreground: ..)` or `background: ..`: relative to the full page, margins ignored
///  - in the document body: relative to the page's text area, on the page where it is called
/// `alignment` is a Typst alignment (e.g. `bottom + right`); `dx`/`dy` nudge it. `pages` limits which
/// pages show it (see `page-ok`); the page count it compares with is `counter(page).final()`,
/// so it assumes the page counter has not been reset.
/// All other options pass to `seal` (kind, size, ink, caption, ...).
#let seal-at(source, alignment: bottom + right, dx: 0pt, dy: 0pt, pages: "all", ..args) = {
  assert(type(alignment) == std.alignment, message: "paraph: alignment must be a Typst alignment, e.g. bottom + right")
  _check-pages(pages)
  let s = seal(source, ..args)
  context {
    if page-ok(pages, here().page(), counter(page).final().first()) {
      place(alignment, dx: dx, dy: dy, s)
    }
  }
}

/// Settings to spread into `set page(..)`: `#set page(..seal-page(source, ...))`.
/// `layer` is "foreground" (over the text) or "background" (under it). Remaining arguments
/// are those of `seal-at`. To stack several seals use `set page(foreground: seal-at(..) + seal-at(..))`.
#let seal-page(source, layer: "foreground", ..args) = {
  assert(layer in ("foreground", "background"), message: "paraph: layer must be \"foreground\" or \"background\"")
  ((layer): seal-at(source, ..args))
}
