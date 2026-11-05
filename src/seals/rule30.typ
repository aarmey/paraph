// Rule 30 rosette: a 64-bit seed ring grown outward by the elementary cellular
// automaton Rule 30 (with wrap-around).
//
// Layout (see issue #9)
//   - 64 cells per ring, 22 rings. Ring 0 = bits 0..63 of the digest, MSB-first;
//     ring g+1 = Rule 30 applied to ring g: new[i] = (30 >> (4*left + 2*centre + right)) & 1.
//   - Ring g occupies radii r0 + g*dr .. r0 + (g + 0.92)*dr, with r0 = 0.26R and
//     dr = (0.96R - r0) / 22. Cell i spans angles [i, i+1) * 360/64 from 12 o'clock.
//     Opacity of ring g is 0.52 - 0.012 g.
//   - Inner boundary circle at 0.82 r0; orientation tick from 0.98R to 1.08R at 12 o'clock.
// Only ring 0 carries data. The other rings are deterministic and let a decoder
// sanity-check its reading of ring 0.
//
// Performance: runs of adjacent live cells in a ring are drawn as ONE wedge, which
// also avoids hairline seams between neighbouring wedges.

#import "../core.typ": *
#import "../digest.typ": bit
#import "../geom.typ": wedge
#import "../input.typ": source-digest

#let width = 64
#let rings = 22

/// Next generation of `row` (array of 0/1) under Rule 30, with wrap-around.
#let step(row) = {
  let n = row.len()
  range(n).map(i => {
    let l = row.at(calc.rem(i - 1 + n, n))
    let c = row.at(i)
    let r = row.at(calc.rem(i + 1, n))
    (30).bit-rshift(4 * l + 2 * c + r).bit-and(1)
  })
}

/// All `count` rows (arrays of 0/1) starting from `seed`; row 0 is `seed` itself.
#let rule30-rows(seed, count: rings) = {
  let rows = (seed,)
  for _ in range(count - 1) { rows.push(step(rows.last())) }
  rows
}

/// Runs of live cells in a circular row as `(start, length)` pairs; `start` may
/// run past the end of the row (angles are periodic), so a run that wraps is one run.
/// A full row is `((0, n),)`.
#let runs(row) = {
  let n = row.len()
  let dead = row.position(c => c == 0)
  if dead == none { return ((0, n),) }
  let out = ()
  let start = none
  for k in range(1, n + 1) { // walk once around, starting just after a dead cell
    let i = dead + k
    let live = row.at(calc.rem(i, n)) == 1
    if live and start == none { start = i }
    if not live and start != none {
      out.push((start, i - start))
      start = none
    }
  }
  out
}

#let rule30-seal(source, ..opts) = {
  assert(opts.pos().len() == 0, message: "rule30-seal: options must be named")
  let o = resolve(opts.named())
  let d = source-digest(source, salt: o.salt)
  let rows = rule30-rows(range(width).map(i => bit(d, i)))

  let r0 = 0.26 * o.R
  let dr = (0.96 * o.R - r0) / rings
  let cell = 360deg / width
  canvas(o, {
    for (g, row) in rows.enumerate() {
      for (start, len) in runs(row) {
        put(wedge(
          o.cx,
          o.cy,
          r0 + g * dr,
          r0 + (g + 0.92) * dr,
          start * cell,
          (start + len) * cell,
          fill: tinted(o, 0.52 - 0.012 * g),
          stroke: none,
        ))
      }
    }
    boundary-ring(o, 0.82 * r0)
    orientation-tick(o, 0.98 * o.R, 1.08 * o.R)
  })
}
