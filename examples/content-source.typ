// Passing `content` (not a string) as the seal source, and why a string is safer.
#import "../lib.typ": *
#set page(width: 12cm, height: 7cm, margin: 0.6cm)
#set text(size: 8pt)

#let as-content = [Dear *Dr.* Smith, thank you for the _kind_ invitation.]
#let as-string = "Dear Dr. Smith, thank you for the kind invitation."

// Formatting is ignored: the content is flattened to its text first, so both forms agree.
#grid(
  columns: 3,
  column-gutter: 8pt,
  align(center)[#seal(as-content, kind: "ring", size: 1.4in) \ content],
  align(center)[#seal(as-string, kind: "ring", size: 1.4in) \ string],
  align(center)[#seal(as-string + "!", kind: "ring", size: 1.4in) \ one character added],
)
#assert.eq(seal-digest(as-content), seal-digest(as-string))

#v(4pt)
*Caveat.* Flattening `content` depends on how Typst represents elements, which may change
between compiler versions, so the same `content` could give a different seal after an upgrade.
For a seal that must stay the same, pass a `str` (or `bytes`, e.g. `read("body.txt")`).
