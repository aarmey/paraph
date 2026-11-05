// Phyllotaxis code: 256 bits, one per seed of a golden-angle (Fibonacci) spiral.
//
// Layout (see issue #8)
//   - Seed i (0-based): radius r_i = c * sqrt(i + 4), angle theta_i = i * golden angle,
//     where theta is measured from +x (3 o'clock) and increases clockwise on screen
//     (the phyllotaxis convention, `polar-x`). c = 0.94R / sqrt(n + 4).
//   - Dot radius s_i = c * (0.30 + 0.10 * i / n). 1-bit: filled dot (opacity 0.62);
//     0-bit: stroked ring (stroke R/160, opacity 0.42). Bit order: bit(i) for seed i.
//   - Centre anchor: filled circle of radius 0.75c (opacity 0.70).
//   - Orientation mark (mandatory for decoding): a radial tick at theta = 0, i.e. pointing
//     to 3 o'clock in the same +x convention as the seeds, from 0.975R to 1.055R.
//     The spiral is otherwise readable from any rotation.
// There is no boundary ring, so the `boundary` option has no effect here.

#import "../core.typ": *
#import "../digest.typ": bit
#import "../geom.typ": polar-x
#import "../input.typ": source-digest

#let seeds = 256
#let golden-angle = calc.pi * (3 - calc.sqrt(5)) * 1rad

/// Centre offset coefficient c (as a fraction of R): c = 0.94 / sqrt(n + 4).
#let c-frac = 0.94 / calc.sqrt(seeds + 4)

/// `(radius, angle)` of seed `i`, with radius as a fraction of R and angle from +x.
#let seed-polar(i) = (c-frac * calc.sqrt(i + 4), i * golden-angle)

#let phyllotaxis-seal(source, ..opts) = {
  assert(opts.pos().len() == 0, message: "phyllotaxis-seal: options must be named")
  let o = resolve(opts.named())
  let d = source-digest(source, salt: o.salt)
  let c = c-frac * o.R

  canvas(o, {
    dot(o, o.cx, o.cy, 0.75 * c, 0.70)
    for i in range(seeds) {
      let (rf, theta) = seed-polar(i)
      let (x, y) = polar-x(o.cx, o.cy, rf * o.R, theta)
      let s = c * (0.30 + 0.10 * i / seeds)
      let b = bit(d, i)
      if b == 1 {
        dot(o, x, y, s, 0.62)
      } else {
        put(place(top + left, dx: x - s, dy: y - s, circle(
          radius: s,
          fill: none,
          stroke: stroke(paint: tinted(o, 0.42, bit: 0), thickness: sw(o, 1 / 160)),
        )))
      }
    }
    // Orientation tick at theta = 0 (+x), just outside the outermost seed.
    if o.orientation {
      let a = polar-x(o.cx, o.cy, 0.975 * o.R, 0deg)
      let b = polar-x(o.cx, o.cy, 1.055 * o.R, 0deg)
      put(line(start: a, end: b, stroke: stroke(paint: tinted(o, 0.55), thickness: sw(o, 1 / 90), cap: "butt")))
    }
  })
}
