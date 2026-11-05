// Graphical options on every seal kind. Each row changes one option; columns are the five kinds.
#import "../lib.typ": *

#set page(paper: "us-letter", flipped: true, margin: 0.5in)
#set text(size: 8pt)

#let msg = "Dear Dr. Smith, thank you for the invitation."
#let kinds = ("ring", "phyllotaxis", "truchet", "rule30", "chord")

#let styled-row(label, ..opts) = (
  align(horizon + right)[#label],
  ..kinds.map(k => align(center, seal(msg, kind: k, size: 0.58in, ..opts))),
)

#grid(
  columns: (1.6in,) + (1fr,) * 5,
  row-gutter: 3pt,
  align(horizon + right)[*option*], ..kinds.map(k => align(center)[*#k*]),
  ..styled-row("defaults"),
  ..styled-row("ink: blue", ink: rgb("#1f4e8c")),
  ..styled-row("ink-off: red (strength 3)", ink: rgb("#1f4e8c"), ink-off: rgb("#b03030"), strength: 3),
  ..styled-row("strength: 0.6", strength: 0.6),
  ..styled-row("strength: 2.0", strength: 2.0),
  ..styled-row("stroke-scale: 1.8", stroke-scale: 1.8),
  ..styled-row("rotation: 35deg", rotation: 35deg),
  ..styled-row("background: tint", background: luma(236), paper: luma(236)),
  ..styled-row("no boundary / orientation", boundary: false, orientation: false),
  ..styled-row("size: 0.35in", size: 0.35in),
  ..styled-row("salt: \"B\"", salt: "B"),
)
