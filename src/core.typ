// Shared options, canvas and drawing utilities used by every seal.
//
// A seal function takes `..opts`, resolves them once with `resolve(...)`, draws
// into `canvas(o, ...)` using the helpers below, and never reads raw arguments again.
//
// Geometry: the seal is drawn in a square box of side `size`; centre is
// (size/2, size/2) and R = 0.40 * size is the nominal seal radius. Line widths
// are given as fractions of R and scaled by `stroke-scale`.

#import "geom.typ": polar

/// Default value of every shared option.
#let defaults = (
  size: 1.1in, // box side
  ink: rgb("#684c2e"), // main colour (a plain colour; gradients are not supported)
  ink-off: auto, // colour for 0-bits / "empty" marks; auto = same as ink
  strength: 1.0, // global opacity multiplier (effective opacity is clamped to 1)
  stroke-scale: 1.0, // multiplies every line width
  paper: none, // colour for masking marks (used by Truchet); none = no masking
  rotation: 0deg, // rotate the whole seal; the orientation mark rotates with it
  orientation: true, // draw the orientation mark (decoders need it)
  boundary: true, // draw boundary ring(s) where the seal has them
  background: none, // fill behind the seal: none or a colour
  background-shape: "disc", // "disc" or "square"
  salt: "", // mixed into the digest so the same text gives a different seal
)

#let _is-number(x) = type(x) in (int, float)

// Returns none if `o` (a complete options dictionary) is valid, else an error message.
#let check(o) = {
  if type(o.size) != length or o.size <= 0pt { return "size must be a positive length, e.g. 1.1in" }
  if type(o.ink) != color { return "ink must be a colour" }
  if o.ink-off != auto and type(o.ink-off) != color { return "ink-off must be a colour or auto" }
  if not _is-number(o.strength) or o.strength < 0 { return "strength must be a number >= 0" }
  if not _is-number(o.stroke-scale) or o.stroke-scale <= 0 { return "stroke-scale must be a number > 0" }
  if o.paper != none and type(o.paper) != color { return "paper must be a colour or none" }
  if type(o.rotation) != angle { return "rotation must be an angle, e.g. 15deg" }
  if type(o.orientation) != bool { return "orientation must be true or false" }
  if type(o.boundary) != bool { return "boundary must be true or false" }
  if o.background != none and type(o.background) != color { return "background must be a colour or none" }
  if o.background-shape not in ("disc", "square") { return "background-shape must be \"disc\" or \"square\"" }
  if type(o.salt) != str { return "salt must be a string" }
  none
}

/// Merge user options over the defaults and validate. `opts` is a dictionary
/// (usually `args.named()`); `extras` holds the seal's own options with their
/// defaults. Unknown names panic, so typos are caught. Adds derived values:
/// `R` (nominal radius), `cx`, `cy` (centre).
#let resolve(opts, extras: (:)) = {
  let known = defaults + extras
  for key in opts.keys() {
    assert(key in known, message: "paraph: unknown option `" + key + "`. Known options: " + known.keys().join(", "))
  }
  let o = known + opts
  let err = check(o)
  assert(err == none, message: "paraph: " + if err == none { "" } else { err })
  o + (R: 0.40 * o.size, cx: o.size / 2, cy: o.size / 2)
}

/// `base` opacity times the global `strength`, clamped to [0, 1]; applied to colour `c`.
/// Works on top of any alpha the colour already has.
#let with-opacity(c, base, strength) = {
  let a = calc.min(1.0, calc.max(0.0, base * strength))
  c.transparentize((1 - a) * 100%)
}

/// Colour for a mark with the given bit: `ink` for 1, `ink-off` (or `ink`) for 0.
#let ink-for(o, bit) = if bit == 1 or o.ink-off == auto { o.ink } else { o.ink-off }

/// Colour at opacity `base * strength`; pass a bit to pick `ink` / `ink-off`.
#let tinted(o, base, bit: 1) = with-opacity(ink-for(o, bit), base, o.strength)

/// Line width from a fraction of R, scaled by `stroke-scale`.
#let sw(o, frac-of-R) = o.R * frac-of-R * o.stroke-scale

/// Place `body` at the canvas origin (top-left). Seal geometry is in absolute canvas coordinates.
#let put(body) = place(top + left, body)

/// The fixed-size box a seal draws into. Optionally fills a background (not
/// rotated), then rotates the drawing about the centre. `body` is content
/// built from `put(...)` calls.
#let canvas(o, body) = box(width: o.size, height: o.size, {
  if o.background != none {
    if o.background-shape == "disc" {
      put(circle(radius: o.size / 2, fill: o.background, stroke: none))
    } else {
      put(rect(width: o.size, height: o.size, fill: o.background, stroke: none))
    }
  }
  rotate(o.rotation, origin: center + horizon, box(width: o.size, height: o.size, body))
})

/// Radial line from radius `r0` to `r1` at angle `theta` (clockwise from 12 o'clock).
/// `w` is a fraction of R; `op` is the base opacity.
#let tick(o, r0, r1, theta, w, op, bit: 1, cap: "butt") = put(line(
  start: polar(o.cx, o.cy, r0, theta),
  end: polar(o.cx, o.cy, r1, theta),
  stroke: stroke(paint: tinted(o, op, bit: bit), thickness: sw(o, w), cap: cap),
))

/// The orientation mark: a radial tick at 12 o'clock from `r0` to `r1` (absolute
/// lengths). Drawn only if `orientation` is on.
#let orientation-tick(o, r0, r1, w: 1 / 90, op: 0.55) = if o.orientation {
  tick(o, r0, r1, 0deg, w, op)
}

/// A boundary circle of radius `r` (absolute), drawn only if `boundary` is on.
#let boundary-ring(o, r, w: 1 / 90, op: 0.5) = if o.boundary {
  put(place(
    top + left,
    dx: o.cx - r,
    dy: o.cy - r,
    circle(radius: r, stroke: stroke(paint: tinted(o, op), thickness: sw(o, w))),
  ))
}

/// A small filled dot of radius `r` (absolute) at `(x, y)`.
#let dot(o, x, y, r, op, bit: 1) = put(place(
  top + left,
  dx: x - r,
  dy: y - r,
  circle(radius: r, fill: tinted(o, op, bit: bit), stroke: none),
))
