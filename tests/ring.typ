#import "../lib.typ": *
#import "../src/seals/ring.typ": cells-in, track-start, total-bits, tracks

// Layout: 24 + 32 + 40 + 48 + 56 = 200 bits, tracks packed consecutively
#assert.eq(tracks, 5)
#assert.eq(range(5).map(cells-in), (24, 32, 40, 48, 56))
#assert.eq(total-bits, 200)
#assert.eq(range(5).map(track-start), (0, 24, 56, 96, 144))
#assert.eq(track-start(4) + cells-in(4), 200) // reads exactly the first 200 of 256 digest bits

// Builds at default size, small size, all rotations, with every option
#let d = "Dear Dr. Smith"
#ring-seal(d)
#ring-seal(d, size: 0.6in, rotation: 90deg)
#ring-seal(d, ink: blue, ink-off: red, strength: 0, gap: 0, stroke-scale: 3, background: luma(240), boundary: false, orientation: false)
#ring-seal((sender: "A", body: [Hello *there*]))
#ring-seal(bytes("raw"))

// Size is exactly the box requested
#context assert.eq(measure(ring-seal(d, size: 2cm)).width, 2cm)
ring tests ok
