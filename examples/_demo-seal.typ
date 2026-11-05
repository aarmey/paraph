// A throwaway "seal" (ring of cells + tick + boundary + dot) that exercises every
// shared option. Not part of the public API; used by tests and examples/options.typ.
#import "../lib.typ": *

#let demo-seal(source: "demo", ..opts) = {
  assert(opts.pos().len() == 0, message: "demo-seal takes named options only")
  let o = resolve(opts.named())
  let d = source-digest(source, salt: o.salt)
  let n = 24
  let r = 0.6 * o.R
  canvas(o, {
    for i in range(n) {
      let b = bit(d, i)
      let a0 = i * 360deg / n + 2deg
      let a1 = (i + 1) * 360deg / n - 2deg
      put(arc-path(o.cx, o.cy, r, a0, a1, stroke: stroke(
        paint: tinted(o, if b == 1 { 0.6 } else { 0.08 }, bit: b),
        thickness: sw(o, 0.12),
        cap: "butt",
      )))
    }
    boundary-ring(o, 0.98 * o.R)
    orientation-tick(o, 0.98 * o.R, 1.08 * o.R)
    dot(o, o.cx, o.cy, 0.10 * o.R, 0.55)
  })
}
