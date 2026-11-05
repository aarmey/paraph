// All five seals for one message, then for the same message with a single character changed.
// Run: typst compile examples/gallery.typ
#import "../lib.typ": *
#import "../src/seals/truchet.typ": cell-count

#set page(paper: "us-letter", margin: 0.75in)
#set text(size: 9pt)
#show raw: set text(size: 7.5pt)

#let body = read("body.txt")
#let make-source(body) = (sender: "Aaron Meyer", recipient: "Dr. J. Smith", date: "4 November 2026", body: body)
#let original = make-source(body)
// One character different: "Thank" -> "Thanx" in the first word of the body.
#let changed = make-source(body.replace("Thank", "Thanx", count: 1))

#let kinds = (
  (kind: "ring", name: "Ring code", bits: "200 bits", note: "decodable"),
  (kind: "phyllotaxis", name: "Phyllotaxis", bits: "256 bits", note: "decodable"),
  (kind: "truchet", name: "Truchet", bits: str(cell-count) + " bits", note: "decodable"),
  (kind: "rule30", name: "Rule 30 rosette", bits: "64 bits (seed ring)", note: "decodable; outer rings are a check"),
  (kind: "chord", name: "Chord wheel", bits: "59 rim bits + 24 chords", note: "rim decodable; chords verify-only"),
)

#let row(source, label) = {
  [*#label* \ #raw(seal-digest(source))]
  v(4pt)
  grid(
    columns: (1fr,) * 5,
    row-gutter: 6pt,
    ..kinds.map(k => align(center, seal(source, kind: k.kind, size: 1.25in))),
    ..kinds.map(k => align(center)[*#k.name* \ #k.bits \ #text(size: 7pt, fill: luma(90))[#k.note]]),
  )
}

= Paraph seal gallery

#row(original, "Original message")
#v(1.2em)
#row(changed, "One character changed (Thank → Thanx)")

#v(1.2em)
Bit counts are fixed by each seal's geometry. The Truchet count (#cell-count) is the number of grid
cells inside the disc. Every seal reads its bits from the same 256-bit digest, so the first row and
the second row differ throughout.
