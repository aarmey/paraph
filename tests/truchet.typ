#import "../lib.typ": *
#import "../src/seals/truchet.typ": cells, cell-count, grid-size

// --- bit budget -------------------------------------------------------------------
#assert.eq(cell-count, 208)       // exact count; also computed independently in Python
#assert(cell-count <= 256)        // fits in one digest
// cells come in reading order: rows top to bottom, columns left to right
#assert(cells.windows(2).all(p => p.at(0).at(1) < p.at(1).at(1) or (p.at(0).at(1) == p.at(1).at(1) and p.at(0).at(0) < p.at(1).at(0))))
// the grid is symmetric under 90-degree rotation, so the inclusion rule has no bias
#let has(c, r) = cells.contains((c, r))
#assert(cells.all(((c, r)) => has(15 - c, r) and has(c, 15 - r) and has(r, c)))
// corners of the 16x16 grid are excluded, the centre block is included
#assert(not has(0, 0) and not has(15, 15) and not has(0, 15) and not has(15, 0))
#assert(has(7, 7) and has(8, 8) and has(7, 8) and has(8, 7))
// first row has 6 cells (columns 5..10), the widest rows have 16
#assert.eq(cells.filter(c => c.at(1) == 0).len(), 6)
#assert.eq(cells.filter(c => c.at(1) == 7).len(), 16)
#assert.eq(grid-size, 16)

// --- builds with every option and input type ---------------------------------------------
#let d = "Dear Dr. Smith"
#truchet-seal(d)
#truchet-seal(d, size: 0.6in, rotation: 90deg)
#truchet-seal(d, paper: none)
#truchet-seal(d, ink: blue, strength: 0, stroke-scale: 3, background: luma(240), paper: luma(240), boundary: false, orientation: false)
#truchet-seal((sender: "A", body: [Hello *there*]))
#truchet-seal(bytes("raw"))
#context assert.eq(measure(truchet-seal(d, size: 2cm)).width, 2cm)
truchet tests ok
