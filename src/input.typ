// Turn whatever the user hands us (str, bytes, content, arrays, dictionaries)
// into one canonical `bytes` message for the digest.
//
// Stability note: flattening `content` depends on Typst's element structure,
// which may differ between compiler versions. For seals that must stay the same
// forever, pass a `str` or `bytes`.

#import "digest.typ": digest

/// Prefix of every message. Bump when the canonical form changes, so a new
/// encoding can never silently collide with seals made under an old one.
#let message-tag = "paraph-v1\n"

// Separators for arrays/dictionaries. Control characters never appear in
// ordinary text, so ("a b",) and ("a", "b") stay distinct.
#let _rec-sep = "\u{1e}"
#let _key-sep = "\u{1f}"

// Fields of an element that can carry text, in a fixed order, so the same
// content always flattens the same way.
#let _text-fields = (
  "text", "base", "tl", "t", "tr", "bl", "b", "br", // text, math attachments
  "num", "denom", "child", "term", "description", "body", "children", "caption",
)

// Elements that end a block; followed by a newline so words don't run together.
#let _block-like = ("heading", "item", "figure", "list.item", "enum.item", "terms.item")

/// Flatten content to plain text. Returns `(text, skipped)`: `skipped` lists
/// the names of elements that contributed nothing (images, spacing, ...).
#let _walk(c) = {
  if c == none { return ("", ()) }
  if type(c) == str { return (c, ()) }
  if type(c) == array {
    let parts = c.map(_walk)
    return (parts.map(p => p.at(0)).join(""), parts.map(p => p.at(1)).flatten())
  }
  assert(type(c) == content, message: "paraph: cannot flatten a " + str(type(c)))

  let name = repr(c.func())
  let f = c.fields()
  if name == "space" { return (" ", ()) }
  if name == "linebreak" { return ("\n", ()) }
  if name == "parbreak" { return ("\n\n", ()) }
  if name == "smartquote" { return (if f.at("double", default: true) { "\"" } else { "'" }, ()) }

  let out = ""
  let skipped = ()
  let found = false
  for key in _text-fields {
    if key in f {
      found = true
      let (t, s) = _walk(f.at(key))
      out += t
      skipped += s
      if key == "term" { out += " " } // keep a term apart from its description
    }
  }
  if not found { skipped.push(name) }
  if name in _block-like { out += "\n" }
  (out, skipped)
}

/// Plain text of `c` (see `_walk`). With `debug: true`, returns a dictionary
/// `(text: .., skipped: ..)` that also lists elements that were ignored.
#let content-text(c, debug: false) = {
  let (t, s) = _walk(c)
  if debug { (text: t, skipped: s.dedup()) } else { t }
}

/// Normalize a string: CRLF and lone CR become LF, leading and trailing
/// whitespace is stripped from every line, runs of 3+ newlines collapse to a
/// blank line, and blank space around the whole text is removed (so
/// `read("body.txt")` and the same text typeset agree more often).
/// Unicode normalization is NOT done; supply NFC text.
#let normalize-text(s) = {
  s
    .replace(regex("\r\n?"), "\n")
    .split("\n")
    .map(l => l.trim())
    .join("\n")
    .replace(regex("\n{3,}"), "\n\n")
    .trim()
}

// One source -> normalized string (or raw bytes).
#let _part(source, normalize) = {
  if type(source) == bytes { return source }
  let s = if type(source) == str { source } else if type(source) == content { content-text(source) } else {
    panic("paraph: unsupported source type " + str(type(source)) + " (use str, bytes, content, array or dictionary)")
  }
  if normalize == "text" { normalize-text(s) } else { s }
}

#let _join-bytes(parts, sep) = {
  let sep = bytes(sep)
  let out = bytes(())
  for (i, p) in parts.enumerate() {
    if i > 0 { out += sep }
    out += if type(p) == bytes { p } else { bytes(p) }
  }
  out
}

/// The canonical message (`bytes`) for any supported source:
///  - `str`: normalized text (unless `normalize: "none"`)
///  - `bytes`: used raw
///  - `content`: flattened to text, then normalized
///  - `array`: each element handled as above, joined with a record separator
///  - `dictionary`: like an array of key/value pairs, in insertion order
/// Every message starts with `message-tag`.
#let message(source, normalize: "text") = {
  assert(normalize in ("text", "none"), message: "paraph: normalize must be \"text\" or \"none\"")
  let body = if type(source) == array {
    _join-bytes(source.map(x => _part(x, normalize)), _rec-sep)
  } else if type(source) == dictionary {
    _join-bytes(
      source.pairs().map(((k, v)) => _join-bytes((k, _part(v, normalize)), _key-sep)),
      _rec-sep,
    )
  } else {
    _part(source, normalize)
  }
  bytes(message-tag) + (if type(body) == bytes { body } else { bytes(body) })
}

/// Digest of any supported source: `digest(message(source), salt: salt)`.
#let source-digest(source, salt: "", normalize: "text") = digest(message(source, normalize: normalize), salt: salt)
