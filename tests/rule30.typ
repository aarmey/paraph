#import "../lib.typ": *
#import "../src/seals/rule30.typ": rule30-rows, runs, step, width, rings

#let s(row) = row.map(str).join()

// --- Rule 30 from a single cell (textbook rows), on a ring wide enough not to wrap ---
#let single = (0,) * 10 + (1,) + (0,) * 10
#let rows = rule30-rows(single, count: 5)
#assert.eq(s(rows.at(1)).slice(9, 12), "111")
#assert.eq(s(rows.at(2)).slice(8, 13), "11001")
#assert.eq(s(rows.at(3)).slice(7, 14), "1101111")
#assert.eq(s(rows.at(4)).slice(6, 15), "110010001")

// --- wrap-around: a live cell at index 0 influences cell 63 and 1 ----------------------
#let edge = (1,) + (0,) * 63
#assert.eq(step(edge).at(63), 1)
#assert.eq(step(edge).at(0), 1)
#assert.eq(step(edge).at(1), 1)
#assert.eq(step(edge).sum(), 3)

// --- cross-check against the independent Python reference (tests/reference.py) ---------
// seed = first 64 bits of the digest of the message "abc" (including the paraph tag)
#let d = source-digest("abc")
#let seed = range(64).map(i => bit(d, i))
#let all = rule30-rows(seed)
#assert.eq(all.len(), rings)
#assert.eq(s(all.at(0)), "0110001101010010001100110100010100100010100001000101001101111101")
#assert.eq(s(all.at(5)), "0001010100100101010000011001000011010100011000011000011010100101")
#assert.eq(s(all.at(21)), "0100011000100011000010110000101101110101001011100010100010000011")
#assert.eq(all.map(r => r.sum()).sum(), 683)

// --- run merging ----------------------------------------------------------------------------------
#assert.eq(runs((0, 0, 0, 0)), ())
#assert.eq(runs((1, 1, 1, 1)), ((0, 4),))
#assert.eq(runs((0, 1, 1, 0, 1, 0)), ((1, 2), (4, 1)))
#assert.eq(runs((1, 1, 0, 0, 0, 1)), ((5, 3),))   // wraps around the end into one run
#assert.eq(runs((1, 0, 1, 0)), ((2, 1), (4, 1)))
// the runs always cover exactly the live cells
#for row in all {
  assert.eq(runs(row).map(((_, l)) => l).sum(default: 0), row.sum())
}

// --- builds with every option and input type -------------------------------------------------------
#rule30-seal("Dear Dr. Smith")
#rule30-seal("Dear Dr. Smith", size: 0.6in, rotation: 90deg)
#rule30-seal("Dear Dr. Smith", ink: blue, strength: 0, stroke-scale: 3, background: luma(240), boundary: false, orientation: false)
#rule30-seal((sender: "A", body: [Hello *there*]))
#rule30-seal(bytes("raw"))
#context assert.eq(measure(rule30-seal("x", size: 2cm)).width, 2cm)
rule30 tests ok
