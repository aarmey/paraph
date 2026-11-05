// Chord wheel: 59 data bits on a ring of rim ticks, plus 24 decorative chords.
//
// Layout (see issue #11). Angles clockwise from 12 o'clock.
//   - 60 points on a circle of radius 0.80R; point 0 at 12 o'clock, 6 degrees apart.
//   - Rim ticks start at 0.86R and point outward. Tick 0 is the orientation mark, always
//     0.20R long (omitted if `orientation` is false). Tick i >= 1 is 0.13R long if bit(i) = 1
//     and 0.06R long if bit(i) = 0. So the data bits are digest bits 1..59 (bit 0 is unused).
//   - 24 chords, k = 0..23: a = byte(k) mod 60; b = (a + 3 + byte(k + 8) mod 54) mod 60.
//     Each is a quadratic Bézier from point a to point b whose control point is the chord
//     midpoint pulled to 35% of its distance from the centre.
//
// The chords are VERIFY-ONLY: the modulo steps discard information and the direction
// a -> b is ambiguous when read from a scan, so they can confirm a known message
// but cannot be decoded into one. Only the rim ticks are decodable.
// There is no boundary ring, so the `boundary` option has no effect here.

#import "../core.typ": *
#import "../digest.typ": bit, byte
#import "../geom.typ": polar
#import "../input.typ": source-digest

#let points = 60
#let chord-count = 24

/// `(a, b)` rim-point indices of the 24 chords for digest `d`.
#let chords(d) = range(chord-count).map(k => {
  let a = calc.rem(byte(d, k), points)
  let b = calc.rem(a + 3 + calc.rem(byte(d, k + 8), 54), points)
  (a, b)
})

/// Tick length (fraction of R) for rim point `i`: orientation tick 0.20, else 0.13 / 0.06 by bit.
#let tick-length(i, b) = if i == 0 { 0.20 } else if b == 1 { 0.13 } else { 0.06 }

#let chord-seal(source, ..opts) = {
  assert(opts.pos().len() == 0, message: "chord-seal: options must be named")
  let o = resolve(opts.named())
  let d = source-digest(source, salt: o.salt)
  let rim = 0.80 * o.R
  let pt(i) = polar(o.cx, o.cy, rim, i * 360deg / points)

  canvas(o, {
    // chords first, so ticks and dots sit on top
    for (a, b) in chords(d) {
      let (pa, pb) = (pt(a), pt(b))
      let ctrl = (
        o.cx + 0.35 * ((pa.at(0) + pb.at(0)) / 2 - o.cx),
        o.cy + 0.35 * ((pa.at(1) + pb.at(1)) / 2 - o.cy),
      )
      put(curve(
        stroke: stroke(paint: tinted(o, 0.32), thickness: sw(o, 1 / 160), cap: "round"),
        curve.move(pa),
        curve.quad(ctrl, pb),
      ))
    }
    for i in range(points) {
      dot(o, ..pt(i), o.R / 75, 0.55)
      let b = if i == 0 { 1 } else { bit(d, i) }
      if i > 0 or o.orientation {
        tick(o, 0.86 * o.R, (0.86 + tick-length(i, b)) * o.R, i * 360deg / points, 1 / 110, 0.6, bit: b)
      }
    }
  })
}
