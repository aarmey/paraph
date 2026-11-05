#import "../lib.typ": *

// --- digest --------------------------------------------------------------------------
#assert.eq(seal-digest("abc"), "635233452284537d6b77c59d19e0e2440e149b8a69f406e00c0f4a788483ff63") // from tests/reference.py
#assert.eq(seal-digest("abc").len(), 64)
#assert.eq(seal-digest("abc"), seal-digest([abc]))
#assert.ne(seal-digest("abc"), seal-digest("abc", salt: "s"))
#assert.eq(seal-digest("abc", salt: "s").slice(0, 8), "4a2dc3c2")

// --- kinds and dispatch ------------------------------------------------------------------
#assert.eq(seal-kinds.keys(), ("ring", "phyllotaxis", "truchet", "rule30", "chord"))
#for kind in seal-kinds.keys() {
  assert.eq(seal("abc", kind: kind), (seal-kinds.at(kind))("abc")) // seal() draws exactly what the kind function draws
}
#assert.eq(seal("abc"), ring-seal("abc")) // default kind is ring
#assert.eq(seal("abc", kind: "truchet", paper: none), truchet-seal("abc", paper: none)) // options pass through

// --- captions --------------------------------------------------------------------------------
#context {
  let plain = measure(seal("abc", size: 1in))
  let cap = measure(seal("abc", size: 1in, caption: true))
  assert.eq(plain.width, 1in)
  assert.eq(cap.width, 1in) // caption does not widen the box
  assert(cap.height > plain.height) // ...but adds a line below
  let custom = measure(seal("abc", size: 1in, caption: true, caption-text: "x"))
  assert(custom.height > plain.height)
}

// --- page selection ----------------------------------------------------------------------------
#assert(page-ok("all", 3, 5))
#assert(page-ok("first", 1, 5) and not page-ok("first", 2, 5))
#assert(page-ok("last", 5, 5) and not page-ok("last", 4, 5))
#assert(page-ok(2, 2, 5) and not page-ok(2, 3, 5))
#assert(page-ok(-1, 5, 5) and page-ok(-2, 4, 5) and not page-ok(-1, 4, 5))
#assert(page-ok((1, "last"), 1, 5) and page-ok((1, "last"), 5, 5) and not page-ok((1, "last"), 3, 5))
#assert(page-ok(n => calc.even(n), 4, 5) and not page-ok(n => calc.even(n), 3, 5))

// --- placement builds in every position (visual check: examples/placement.typ) --------------------------
#set page(
  ..seal-page("abc", kind: "chord", pages: "first", alignment: top + right),
  background: seal-at("abc", kind: "rule30", pages: (1, "last"), alignment: bottom + left, dx: 1cm, dy: -1cm),
)
#seal-at("abc", kind: "truchet", alignment: center + horizon, dx: 5pt, dy: -5pt, caption: true)
body text that must not move
#pagebreak()
second page
api tests ok
