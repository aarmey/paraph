// Geometry tests: numeric accuracy of the Bézier arcs and basic conventions.
#import "../lib.typ": *
#import "../src/geom.typ": _arc-data

#let close(a, b, tol: 1e-6) = calc.abs(a.pt() - b.pt()) <= tol
#let pt-close(p, q, tol: 1e-6) = close(p.at(0), q.at(0), tol: tol) and close(p.at(1), q.at(1), tol: tol)

// --- polar conventions -------------------------------------------------------
#let c = (100pt, 100pt)
#assert(pt-close(polar(..c, 10pt, 0deg), (100pt, 90pt)))      // 12 o'clock is up
#assert(pt-close(polar(..c, 10pt, 90deg), (110pt, 100pt)))    // 3 o'clock is right
#assert(pt-close(polar(..c, 10pt, 180deg), (100pt, 110pt)))   // 6 o'clock is down
#assert(pt-close(polar(..c, 10pt, 270deg), (90pt, 100pt)))
#assert(pt-close(polar-x(..c, 10pt, 0deg), (110pt, 100pt)))   // phyllotaxis: +x
#assert(pt-close(polar-x(..c, 10pt, 90deg), (100pt, 110pt)))  // ...then clockwise on screen

// --- Bézier accuracy: sample every segment, check distance to centre -----------
#let bez(p0, s, t) = {
  let (c1, c2, p3) = s
  range(2).map(i => (
    (1 - t) * (1 - t) * (1 - t) * p0.at(i).pt() + 3 * (1 - t) * (1 - t) * t * c1.at(i).pt() + 3 * (1 - t) * t * t * c2.at(i).pt() + t * t * t * p3.at(i).pt()
  ))
}
#let max-radial-error(r, a0, a1) = {
  let segs = _arc-data(c.at(0), c.at(1), r, a0, a1)
  let p = polar(c.at(0), c.at(1), r, a0)
  let worst = 0
  for s in segs {
    for i in range(0, 41) {
      let q = bez(p, s, i / 40)
      let d = calc.sqrt(calc.pow(q.at(0) - c.at(0).pt(), 2) + calc.pow(q.at(1) - c.at(1).pt(), 2))
      worst = calc.max(worst, calc.abs(d - r.pt()))
    }
    p = s.at(2)
  }
  worst / r.pt()
}
#let tol = 3e-4 // textbook bound for 90-degree cubic arcs is ~2.7e-4
#for (a0, a1) in ((0deg, 360deg), (0deg, 90deg), (30deg, 200deg), (10deg, 11deg), (270deg, 0deg), (360deg, 0deg), (45deg, -300deg)) {
  let e = max-radial-error(50pt, a0, a1)
  assert(e < tol, message: "arc " + repr(a0) + ".." + repr(a1) + " radial error " + str(e))
}

// --- segment counts and endpoints ------------------------------------------------
#assert.eq(_arc-data(..c, 10pt, 0deg, 360deg).len(), 4)
#assert.eq(_arc-data(..c, 10pt, 0deg, 90deg).len(), 1)
#assert.eq(_arc-data(..c, 10pt, 0deg, 90.5deg).len(), 2)
#assert.eq(_arc-data(..c, 10pt, 0deg, 0deg).len(), 0)
#assert.eq(_arc-data(..c, 10pt, 90deg, 0deg).len(), 1)        // backwards
#assert(pt-close(_arc-data(..c, 10pt, 0deg, 360deg).last().at(2), (100pt, 90pt)))  // closes on itself
#assert(pt-close(_arc-data(..c, 10pt, 20deg, 200deg).last().at(2), polar(..c, 10pt, 200deg)))

// --- elements build without error -------------------------------------------------
#let s = 40pt
#box(width: s, height: s)[
  #place(top + left, arc-path(20pt, 20pt, 15pt, 0deg, 360deg, stroke: 1pt))
  #place(top + left, wedge(20pt, 20pt, 5pt, 10pt, 10deg, 80deg, fill: red))
  #place(top + left, wedge(20pt, 20pt, 5pt, 10pt, 0deg, 360deg, fill: blue.transparentize(80%))) // full ring
  #place(top + left, wedge(20pt, 20pt, 5pt, 10pt, 30deg, 30deg, fill: green)) // degenerate
  #for q in ("tr", "br", "bl", "tl") { place(top + left, quarter(20pt, 20pt, 6pt, q, stroke: 0.5pt)) }
]
#assert(true)
geometry tests ok
