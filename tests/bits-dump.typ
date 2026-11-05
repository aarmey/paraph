// Bit dump: exactly which bits each seal consumed for a fixed sample message, as text.
//
// It is also machine-readable. `typst query tests/bits-dump.typ "<bits-dump>" --field value --one`
// prints the same data as JSON, and tests/check_dump.py compares that with the independent Python
// implementation in tests/reference.py. A future decoder can be checked against this dump.
#import "../lib.typ": *
#import "../src/seals/truchet.typ": cell-count
#import "../src/seals/rule30.typ": rule30-rows
#import "../src/seals/chord.typ": chords

// The sample message from the README (issue #14).
#let sample = (sender: "Aaron Meyer", recipient: "J. Smith", date: "2026-11-04", body: "Test.")
#let d = source-digest(sample)
#let s(row) = row.map(str).join()
// Long bit strings wrapped at 64 characters per line so they fit the page.
#let wrapped(str-bits) = {
  let lines = range(0, str-bits.len(), step: 64).map(i => str-bits.slice(i, calc.min(i + 64, str-bits.len())))
  raw(lines.join("\n"), lang: none)
}

#let dump = (
  digest: digest-hex(d),
  // Ring code: bits 0..199, track by track (24, 32, 40, 48, 56 cells).
  ring: bit-string(d, 0, 200),
  // Phyllotaxis: bit i for seed i, 256 bits.
  phyllotaxis: bit-string(d, 0, 256),
  // Truchet: one bit per included cell, reading order (count in `truchet-cells`).
  truchet: bit-string(d, 0, cell-count),
  truchet-cells: cell-count,
  // Rule 30: ring 0 is the data (bits 0..63); all 22 rings are listed so a decoder can check its reading.
  rule30: rule30-rows(range(64).map(i => bit(d, i))).map(s),
  // Chord wheel: rim ticks 1..59 read digest bits 1..59 (bit 0 unused); chords are verify-only.
  chord-rim: bit-string(d, 1, 60),
  chord-chords: chords(d).map(((a, b)) => (a, b)),
)
#metadata(dump) <bits-dump>

#set page(width: 21cm, height: auto, margin: 1.2cm)
#set text(size: 8pt)
#show raw: set text(size: 7pt)

= Bit dump for the sample message

#raw(repr(sample), lang: none)

*Digest* (256 bits): #raw(dump.digest)

*First 16 bits each seal reads*

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.3pt + luma(180),
  [*seal*], [*bits*], [*first 16 bits*],
  [ring], [200], raw(dump.ring.slice(0, 16)),
  [phyllotaxis], [256], raw(dump.phyllotaxis.slice(0, 16)),
  [truchet], [#cell-count], raw(dump.truchet.slice(0, 16)),
  [rule30 (ring 0)], [64], raw(dump.rule30.at(0).slice(0, 16)),
  [chord rim], [59], raw(dump.chord-rim.slice(0, 16)),
)

*Ring code*, tracks of 24, 32, 40, 48, 56 cells:

#{
  let start = 0
  for n in (24, 32, 40, 48, 56) {
    raw(dump.ring.slice(start, start + n))
    linebreak()
    start += n
  }
}

*Phyllotaxis* (seed 0 first):

#wrapped(dump.phyllotaxis)

*Truchet* (#cell-count cells, row by row):

#wrapped(dump.truchet)

*Rule 30 rings* (ring 0 = data, then each generation):

#for (g, row) in dump.rule30.enumerate() [
  #raw((if g < 10 { " " } else { "" }) + str(g) + "  " + row) \
]

*Chord rim bits* (ticks 1 to 59): #raw(dump.chord-rim)

*Chords* (point a to point b): #raw(dump.chord-chords.map(((a, b)) => str(a) + "-" + str(b)).join("  "))
