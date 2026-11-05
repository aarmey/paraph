// Placement: a seal in the bottom-right of page 1 (page-anchored, ignores margins), a different
// seal on the last page only, and an in-body seal anchored to the text area.
#import "../lib.typ": *
#let msg = "Dear Dr. Smith, this is the letter body."
#set page(
  paper: "a5",
  margin: 2cm,
  ..seal-page(msg, kind: "ring", pages: "first", alignment: bottom + right, dx: -1cm, dy: -0.8cm, caption: true, size: 1.1in),
  background: seal-at(msg, kind: "phyllotaxis", pages: "last", alignment: bottom + left, dx: 0.8cm, dy: -0.8cm, size: 0.8in),
)
#set text(size: 9pt)

#lorem(150)

#pagebreak()
#lorem(40)
#seal-at(msg, kind: "chord", pages: 2, alignment: bottom + center, size: 0.9in, caption: true, caption-text: "p. 2 only")

#pagebreak()
Last page. #lorem(30)
