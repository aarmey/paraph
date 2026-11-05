// Ring code: 200 bits on 5 concentric tracks (24, 32, 40, 48, 56 cells).
//
// Layout (see issue #7). Angles clockwise from 12 o'clock, MSB-first bit order.
//   - Track t has n_t = 24 + 8t cells; bit index k = (cells in earlier tracks) + i.
//   - Track centrelines run from 0.36R to 0.92R in 5 equal-width bands.
//   - A 1-bit is a dark arc, a 0-bit a faint arc (so the empty grid stays visible).
//   - Boundary circle at 0.98R, orientation tick from 0.98R to 1.08R at 12 o'clock,
//     centre dot of radius 0.10R.

#import "../core.typ": *
#import "../digest.typ": bit
#import "../geom.typ": arc-path
#import "../input.typ": source-digest

#let tracks = 5
#let cells-in(t) = 24 + 8 * t
#let total-bits = range(tracks).map(cells-in).sum() // 200

/// Index of the first bit of track `t`.
#let track-start(t) = range(t).map(cells-in).sum(default: 0)

/// Ring code seal for `source` (str, bytes, content, array or dictionary).
/// Shared options: see core.typ. Extra option: `gap` (fraction of a cell left
/// empty between neighbours, default 0.16).
#let ring-seal(source, ..opts) = {
  assert(opts.pos().len() == 0, message: "ring-seal: options must be named")
  let o = resolve(opts.named(), extras: (gap: 0.16))
  assert(type(o.gap) in (int, float) and 0 <= o.gap and o.gap < 1, message: "ring-seal: gap must be a number in [0, 1)")
  let d = source-digest(source, salt: o.salt)

  let inner = 0.36 * o.R
  let tw = (0.92 * o.R - inner) / tracks
  canvas(o, {
    for t in range(tracks) {
      let n = cells-in(t)
      let r = inner + tw * (t + 0.5)
      let cell = 360deg / n
      let g = o.gap * cell
      for i in range(n) {
        let b = bit(d, track-start(t) + i)
        put(arc-path(
          o.cx,
          o.cy,
          r,
          i * cell + g / 2,
          (i + 1) * cell - g / 2,
          stroke: stroke(
            paint: tinted(o, if b == 1 { 0.60 } else { 0.08 }, bit: b),
            thickness: 0.58 * tw * o.stroke-scale,
            cap: "butt",
          ),
        ))
      }
    }
    boundary-ring(o, 0.98 * o.R)
    orientation-tick(o, 0.98 * o.R, 1.08 * o.R)
    dot(o, o.cx, o.cy, 0.10 * o.R, 0.55)
  })
}
