#import "../lib.typ": *
#import "../src/seals/phyllotaxis.typ": seeds, seed-polar, c-frac, golden-angle

#let near(a, b, tol: 1e-9) = calc.abs(a - b) < tol

#assert.eq(seeds, 256)
// golden angle ~ 137.5078 degrees
#assert(near(golden-angle.deg(), 137.50776405, tol: 1e-6))
// c = 0.94 / sqrt(260); seed 0 sits at radius 2c, angle 0
#assert(near(c-frac, 0.94 / calc.sqrt(260)))
#let (r0, t0) = seed-polar(0)
#assert(near(r0, 2 * c-frac))
#assert.eq(t0, 0deg)
// last seed sits just inside 0.94R, angle 255 * golden angle
#let (r255, t255) = seed-polar(255)
#assert(near(r255, 0.94 * calc.sqrt(259 / 260)))
#assert(near(t255.deg(), 255 * golden-angle.deg(), tol: 1e-6))
// radii strictly increase (spiral never doubles back)
#assert(range(1, 256).all(i => seed-polar(i).at(0) > seed-polar(i - 1).at(0)))
// the outermost seed's outer edge stays clear of the orientation tick at 0.975R
#assert(r255 + c-frac * 0.40 < 0.975)

// Builds with every option and input type
#let d = "Dear Dr. Smith"
#phyllotaxis-seal(d)
#phyllotaxis-seal(d, size: 0.6in, rotation: 90deg)
#phyllotaxis-seal(d, ink: blue, ink-off: red, strength: 0, stroke-scale: 3, background: luma(240), orientation: false)
#phyllotaxis-seal((sender: "A", body: [Hello *there*]))
#phyllotaxis-seal(bytes("raw"))
#context assert.eq(measure(phyllotaxis-seal(d, size: 2cm)).width, 2cm)
phyllotaxis tests ok
