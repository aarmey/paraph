// Truchet seal: a 16x16 grid of quarter-arc tiles clipped (by an inclusion rule) to a disc.
//
// Layout (see issue #10)
//   - Cell side s = 2 * 0.94R / 16; the grid is centred on the seal.
//   - A cell is included iff its centre is within 0.94R + 0.2s of the seal centre.
//     That is 208 of the 256 cells. Included cells are read row by row, top to bottom,
//     left to right, each consuming one digest bit, MSB-first (bits 0..207).
//   - Bit 1: arcs of radius s/2 centred on the top-left and bottom-right tile corners.
//     Bit 0: arcs centred on the top-right and bottom-left corners.
//   - Stroke 0.2 s, round caps, opacity 0.55. Boundary circle at 0.96R (stroke R/80, 0.5).
//   - Orientation: the pattern has none of its own, so a radial notch sits at 12 o'clock
//     outside the boundary (1.05R to 1.12R).
//   - Edge: Typst only clips to rectangles and, at larger sizes, unclipped tiles leave ragged
//     spikes outside the boundary ring. So everything outside the ring is covered by an
//     annulus of the `paper` colour. This seal's default is `paper: white`; if the letter
//     (or the seal's `background`) is not white, pass that colour as `paper`. `paper: none`
//     turns the mask off.

#import "../core.typ": *
#import "../digest.typ": bit
#import "../geom.typ": quarter, wedge
#import "../input.typ": source-digest

#let grid-size = 16

/// Included cells as `(col, row)` in reading order. Each consumes one bit.
#let cells = {
  // work in units of R: s = 2*0.94/16, limit = 0.94 + 0.2 s  (i.e. 8.2 cell sides)
  let limit2 = 8.2 * 8.2
  let out = ()
  for row in range(grid-size) {
    for col in range(grid-size) {
      let dx = col - 7.5
      let dy = row - 7.5
      if dx * dx + dy * dy <= limit2 { out.push((col, row)) }
    }
  }
  out
}
#let cell-count = cells.len() // 208

#assert(cell-count <= 256, message: "truchet: needs more than 256 bits")

#let truchet-seal(source, ..opts) = {
  assert(opts.pos().len() == 0, message: "truchet-seal: options must be named")
  let o = resolve(opts.named(), extras: (paper: white))
  let d = source-digest(source, salt: o.salt)

  let s = 2 * 0.94 * o.R / grid-size
  let w = 0.2 * s * o.stroke-scale
  canvas(o, {
    for (k, (col, row)) in cells.enumerate() {
      let x0 = o.cx + (col - grid-size / 2) * s
      let y0 = o.cy + (row - grid-size / 2) * s
      let st = stroke(paint: tinted(o, 0.55), thickness: w, cap: "round")
      if bit(d, k) == 1 {
        put(quarter(x0, y0, s / 2, "br", stroke: st)) // top-left corner
        put(quarter(x0 + s, y0 + s, s / 2, "tl", stroke: st)) // bottom-right corner
      } else {
        put(quarter(x0 + s, y0, s / 2, "bl", stroke: st)) // top-right corner
        put(quarter(x0, y0 + s, s / 2, "tr", stroke: st)) // bottom-left corner
      }
    }
    if o.paper != none {
      put(wedge(o.cx, o.cy, 0.96 * o.R + sw(o, 1 / 160), 0.5 * o.size, 0deg, 360deg, fill: o.paper, stroke: none))
    }
    boundary-ring(o, 0.96 * o.R, w: 1 / 80)
    orientation-tick(o, 1.05 * o.R, 1.12 * o.R, w: 1 / 40)
  })
}
