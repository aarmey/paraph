// Geometry helpers. Typst has no arc primitive, so arcs are built from cubic
// Béziers (at most 90 degrees each; max radial error ~0.027% of the radius).
//
// Conventions
//  - All coordinates are absolute lengths in the seal's canvas, origin top-left,
//    y pointing DOWN. Draw results by placing them at the canvas origin
//    (`place(top + left, ..)`), see core.typ.
//  - `polar` angles are measured CLOCKWISE from 12 o'clock (so 90deg = 3 o'clock).
//  - The phyllotaxis code uses a different convention (angle from +x, 3 o'clock);
//    that lives in `polar-x` so the two are never mixed up by accident.

/// Point at radius `r` and angle `theta` from centre `(cx, cy)`; angle clockwise from 12 o'clock.
#let polar(cx, cy, r, theta) = (cx + r * calc.sin(theta), cy - r * calc.cos(theta))

/// Phyllotaxis convention: angle from +x (3 o'clock), increasing clockwise on screen.
#let polar-x(cx, cy, r, theta) = (cx + r * calc.cos(theta), cy + r * calc.sin(theta))

// Cubic segments ((c1, c2, end), ...) approximating the arc from a0 to a1
// (either direction; a1 < a0 sweeps counter-clockwise). Empty if a0 == a1.
#let _arc-data(cx, cy, r, a0, a1) = {
  let sweep = a1 - a0
  let n = calc.ceil(calc.abs(sweep) / 90deg - 1e-9)
  if n == 0 { return () }
  let step = sweep / n
  let k = 4 / 3 * calc.tan(step / 4) * r
  range(n).map(i => {
    let a = a0 + step * i
    let b = a + step
    let p0 = polar(cx, cy, r, a)
    let p3 = polar(cx, cy, r, b)
    (
      (p0.at(0) + k * calc.cos(a), p0.at(1) + k * calc.sin(a)),
      (p3.at(0) - k * calc.cos(b), p3.at(1) - k * calc.sin(b)),
      p3,
    )
  })
}

/// `curve` components continuing along the arc from a0 to a1. The pen must
/// already be at `polar(cx, cy, r, a0)`.
#let arc-segments(cx, cy, r, a0, a1) = _arc-data(cx, cy, r, a0, a1).map(s => curve.cubic(..s))

/// An open arc as a `curve` element (stroke/fill and other `curve` options
/// pass through `..style`). Angles clockwise from 12 o'clock; `a1 < a0` sweeps backwards.
#let arc-path(cx, cy, r, a0, a1, ..style) = curve(
  ..style,
  curve.move(polar(cx, cy, r, a0)),
  ..arc-segments(cx, cy, r, a0, a1),
)

/// Annular wedge between radii `r-in` and `r-out` spanning a0..a1: outer arc
/// a0->a1, straight edge inward, inner arc a1->a0, close. `..style` passes to `curve`.
#let wedge(cx, cy, r-in, r-out, a0, a1, ..style) = curve(
  ..style,
  curve.move(polar(cx, cy, r-out, a0)),
  ..arc-segments(cx, cy, r-out, a0, a1),
  curve.line(polar(cx, cy, r-in, a1)),
  ..arc-segments(cx, cy, r-in, a1, a0),
  curve.close(),
)

// Start/end angles (clockwise from 12) of the quarter circle lying in each
// direction from its centre.
#let _quadrants = (
  tr: (0deg, 90deg),
  br: (90deg, 180deg),
  bl: (180deg, 270deg),
  tl: (270deg, 360deg),
)

/// Quarter circle of radius `r` centred at `(cx, cy)` that extends toward the
/// given quadrant: "tr", "br", "bl" or "tl" (top/bottom, left/right on screen).
/// For Truchet tiles the centre is a tile corner and the quadrant points into the tile.
#let quarter(cx, cy, r, quadrant, ..style) = {
  assert(quadrant in _quadrants, message: "quarter: quadrant must be one of tr, br, bl, tl")
  let (a0, a1) = _quadrants.at(quadrant)
  arc-path(cx, cy, r, a0, a1, ..style)
}
