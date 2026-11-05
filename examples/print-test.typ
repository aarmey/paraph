// Print-test sheet (issue #16). Print at 100% scale (no "fit to page"), on the real printer and paper.
// Page 1: all five seals at 1.1in for strength 0.8, 1.0 and 1.4. Page 2: the same at 0.6in.
// Check the 1-inch scale bar with a ruler to confirm the print is not scaled.
// Procedure and the results table: docs/print-test.md
#import "../lib.typ": *

#set page(paper: "us-letter", margin: (x: 0.75in, y: 0.7in))
#set text(size: 9pt)

#let msg = "Dear Dr. Smith, thank you for the invitation."
#let kinds = ("ring", "phyllotaxis", "truchet", "rule30", "chord")
#let strengths = (0.8, 1.0, 1.4)

#let sheet(size, title) = {
  [= #title]
  grid(
    columns: (0.9in, 1fr, 1fr, 1fr),
    row-gutter: 10pt,
    align(horizon, [*seal*]), ..strengths.map(s => align(center)[*strength #s*]),
    ..kinds.map(k => (
      align(horizon)[#k],
      ..strengths.map(s => align(center + horizon, seal(msg, kind: k, size: size, strength: s))),
    )).flatten(),
  )
  v(1fr)
  // A 1-inch bar: measure it after printing.
  grid(
    columns: (1in, auto),
    column-gutter: 8pt,
    align: horizon,
    line(length: 1in, stroke: 0.8pt),
    [this bar must measure exactly 1 inch]
  )
}

#sheet(1.1in, "Print test: 1.1 in seals")
#pagebreak()
#sheet(0.6in, "Print test: 0.6 in seals")
