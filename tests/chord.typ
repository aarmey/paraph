#import "../lib.typ": *
#import "../src/seals/chord.typ": chords, tick-length, points, chord-count

#assert.eq(points, 60)
#assert.eq(chord-count, 24)

// --- cross-check against the independent Python reference (tests/reference.py) ------------
// digest of the message "abc" (including the paraph tag)
#let d = source-digest("abc")
#assert.eq(chords(d), (
  (39, 35), (22, 36), (51, 29), (9, 1), (34, 2), (12, 23), (23, 36), (5, 22),
  (47, 4), (59, 22), (17, 7), (37, 10), (25, 19), (44, 15), (46, 55), (8, 19),
  (14, 29), (20, 38), (35, 58), (18, 33), (45, 12), (4, 30), (6, 48), (44, 32),
))
#assert.eq(bit-string(d, 1, 60), "11000110101001000110011010001010010001010000100010100110111")

// --- chord invariants: endpoints always valid and at least 3 points apart --------------------
#for msg in ("a", "b", "Dear Dr. Smith", "x" * 50) {
  let cs = chords(source-digest(msg))
  assert.eq(cs.len(), 24)
  for (a, b) in cs {
    assert(0 <= a and a < 60 and 0 <= b and b < 60)
    let gap = calc.rem(b - a + 60, 60)
    assert(3 <= gap and gap <= 56, message: "chord gap " + str(gap))
  }
}

// --- tick lengths ------------------------------------------------------------------------------
#assert.eq(tick-length(0, 0), 0.20)
#assert.eq(tick-length(0, 1), 0.20) // orientation tick ignores the bit
#assert.eq(tick-length(1, 1), 0.13)
#assert.eq(tick-length(59, 0), 0.06)

// --- builds with every option and input type -------------------------------------------------------
#let m = "Dear Dr. Smith"
#chord-seal(m)
#chord-seal(m, size: 0.6in, rotation: 90deg)
#chord-seal(m, ink: blue, ink-off: red, strength: 0, stroke-scale: 3, background: luma(240), boundary: false, orientation: false)
#chord-seal((sender: "A", body: [Hello *there*]))
#chord-seal(bytes("raw"))
#context assert.eq(measure(chord-seal(m, size: 2cm)).width, 2cm)
chord tests ok
