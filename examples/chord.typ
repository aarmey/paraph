#import "../lib.typ": *
#set page(width: 17cm, height: 8cm, margin: 0.5cm)
#set text(size: 7pt)

#let cell(label, source, ..opts) = box(width: 3.1cm, inset: (bottom: 6pt), align(center)[
  #chord-seal(source, ..opts) \
  #label
])

#grid(
  columns: 5,
  row-gutter: 8pt,
  cell("Dear Dr. Smith", "Dear Dr. Smith"),
  cell("Dear Dr. Smyth", "Dear Dr. Smyth"),
  cell("0.6in", "Dear Dr. Smith", size: 0.6in),
  cell("ink-off + strength 1.5", "Dear Dr. Smith", ink-off: red.darken(20%), strength: 1.5),
  cell("rotation 20deg", "Dear Dr. Smith", rotation: 20deg),
  cell("orientation false", "Dear Dr. Smith", orientation: false),
  cell("ink blue", "Dear Dr. Smith", ink: blue.darken(30%)),
  cell("stroke-scale 2", "Dear Dr. Smith", stroke-scale: 2),
  cell("background", "Dear Dr. Smith", background: luma(240)),
  cell("salt \"b\"", "Dear Dr. Smith", salt: "b"),
)
