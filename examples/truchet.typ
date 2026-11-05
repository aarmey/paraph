#import "../lib.typ": *
#set page(width: 17cm, height: 8cm, margin: 0.5cm)
#set text(size: 7pt)

#let cell(label, source, ..opts) = box(width: 3.1cm, inset: (bottom: 6pt), align(center)[
  #truchet-seal(source, ..opts) \
  #label
])

#grid(
  columns: 5,
  row-gutter: 8pt,
  cell("Dear Dr. Smith", "Dear Dr. Smith"),
  cell("Dear Dr. Smyth", "Dear Dr. Smyth"),
  cell("0.6in", "Dear Dr. Smith", size: 0.6in),
  cell("paper: none (no mask)", "Dear Dr. Smith", paper: none),
  cell("rotation 20deg", "Dear Dr. Smith", rotation: 20deg),
  cell("no boundary/orientation", "Dear Dr. Smith", boundary: false, orientation: false),
  cell("ink blue", "Dear Dr. Smith", ink: blue.darken(30%)),
  cell("stroke-scale 0.6", "Dear Dr. Smith", stroke-scale: 0.6),
  cell("background + paper", "Dear Dr. Smith", background: luma(235), paper: luma(235)),
  cell("salt \"b\"", "Dear Dr. Smith", salt: "b"),
)
