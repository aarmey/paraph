#import "../lib.typ": *

// --- defaults and derived values --------------------------------------------
#let o = resolve((:))
#assert.eq(o.size, 1.1in)
#assert.eq(o.strength, 1.0)
#assert.eq(o.orientation, true)
#assert.eq(o.R, 0.40 * 1.1in)
#assert.eq(o.cx, 0.55in)
#assert.eq(o.cy, 0.55in)
#assert.eq(check(defaults), none)

// --- overrides and per-seal extras ---------------------------------------------
#let o2 = resolve((size: 2cm, ink: blue, gap: 0.3), extras: (gap: 0.16, tracks: 5))
#assert.eq(o2.size, 2cm)
#assert.eq(o2.R, 0.8cm)
#assert.eq(o2.gap, 0.3)    // extra overridden
#assert.eq(o2.tracks, 5)   // extra default kept
#assert.eq(o2.ink, blue)

// --- validation messages (resolve panics with these) -----------------------------------
#let bad(key, value) = check(defaults + ((key): value))
#assert.eq(bad("size", 0pt), "size must be a positive length, e.g. 1.1in")
#assert.eq(bad("size", 12), "size must be a positive length, e.g. 1.1in")
#assert.eq(bad("ink", "brown"), "ink must be a colour")
#assert.eq(bad("ink-off", "red"), "ink-off must be a colour or auto")
#assert.eq(bad("strength", -1), "strength must be a number >= 0")
#assert.eq(bad("stroke-scale", 0), "stroke-scale must be a number > 0")
#assert.eq(bad("paper", 3), "paper must be a colour or none")
#assert.eq(bad("rotation", 15), "rotation must be an angle, e.g. 15deg")
#assert.eq(bad("orientation", "yes"), "orientation must be true or false")
#assert.eq(bad("boundary", 1), "boundary must be true or false")
#assert.eq(bad("background", "grey"), "background must be a colour or none")
#assert.eq(bad("background-shape", "star"), "background-shape must be \"disc\" or \"square\"")
#assert.eq(bad("salt", 7), "salt must be a string")
// valid alternatives
#assert.eq(bad("ink-off", red), none)
#assert.eq(bad("strength", 0), none)
#assert.eq(bad("paper", white), none)
#assert.eq(bad("rotation", -45deg), none)

// --- opacity ---------------------------------------------------------------------------
#let red = rgb("#ff0000")
#assert.eq(with-opacity(red, 1.0, 1).to-hex(), "#ff0000")
#assert.eq(with-opacity(red, 0.6, 2).to-hex(), "#ff0000")          // clamped to 1
#assert.eq(with-opacity(red, 0.5, 1).to-hex(), red.transparentize(50%).to-hex())
#assert.eq(with-opacity(red, 0.25, 2).to-hex(), red.transparentize(50%).to-hex())  // strength multiplies
#assert.eq(with-opacity(red, 0.5, 0).to-hex(), red.transparentize(100%).to-hex())  // strength 0 = invisible
#assert.eq(with-opacity(red.transparentize(50%), 0.5, 1).to-hex(), red.transparentize(75%).to-hex()) // stacks on existing alpha

// --- ink choice and widths ---------------------------------------------------------------
#let both = resolve((ink: blue, ink-off: red))
#assert.eq(ink-for(both, 1), blue)
#assert.eq(ink-for(both, 0), red)
#assert.eq(ink-for(o, 0), o.ink)    // ink-off: auto falls back to ink
#assert.eq(tinted(both, 1.0, bit: 0).to-hex(), red.to-hex())
#assert.eq(sw(resolve((size: 1in)), 0.1), 0.4in * 0.1)
#assert.eq(sw(resolve((size: 1in, stroke-scale: 2)), 0.1), 0.4in * 0.2)

// --- drawing helpers build at every rotation and size --------------------------------------------
#for rot in (0deg, 33deg, -90deg, 360deg) {
  let o = resolve((size: 1in, rotation: rot, background: luma(240)))
  canvas(o, {
    boundary-ring(o, o.R)
    orientation-tick(o, o.R, 1.1 * o.R)
    tick(o, 0.2 * o.R, 0.5 * o.R, 45deg, 0.02, 0.5)
    dot(o, o.cx, o.cy, 2pt, 0.5)
  })
}
#context {
  assert.eq(measure(canvas(o, [])).width, 1.1in)
  assert.eq(measure(canvas(o, [])).height, 1.1in)
}
core tests ok
