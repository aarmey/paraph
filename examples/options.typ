// Every shared option applied to a demo seal. Check each cell by eye:
// the orientation tick must stay at 12 o'clock of the (rotated) seal.
#import "_demo-seal.typ": demo-seal
#set page(width: 17cm, height: 11cm, margin: 0.5cm)
#set text(size: 7pt)

#let cell(label, ..opts) = box(width: 3.1cm, inset: (bottom: 5pt), align(center)[
  #demo-seal(..((size: 2cm) + opts.named())) \
  #label
])

#grid(
  columns: 5,
  row-gutter: 6pt,
  cell("default"),
  cell("strength 0.5", strength: 0.5),
  cell("strength 2.0", strength: 2.0),
  cell("stroke-scale 2", stroke-scale: 2),
  cell("stroke-scale 0.5", stroke-scale: 0.5),
  cell("ink blue", ink: blue.darken(30%)),
  cell("ink-off red", ink-off: red),
  cell("rotation 30deg", rotation: 30deg),
  cell("rotation -90deg", rotation: -90deg),
  cell("orientation false", orientation: false),
  cell("boundary false", boundary: false),
  cell("background disc", background: luma(235)),
  cell("background square", background: luma(235), background-shape: "square"),
  cell("salt \"x\"", salt: "x"),
  cell("size 0.6in", size: 0.6in),
)
