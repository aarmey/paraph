// Digest tests. Expected vectors come from tests/reference.py (independent Python implementation).
#import "../lib.typ": *

#let vectors = (
  ("", "", "9cae535ed901c724f7e3abc6649b4347618c08a7f1ea878b3b871222654fa447"),
  ("abc", "", "f9ebf93e48c23190a55a537059f52e4df82af237ae19466bc5ea950afaf50cef"),
  (
    "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
    "",
    "cf3fd45b1be10847869c6d89540ed95ed97ac762d765159b27ed4fc5c6cb86b3",
  ),
  ("Grüße → ü", "", "ea2d5f4a985ddfaec344541dc4f7b0fd7131f56c0d9e40bf1f84bed2bd564039"),
  ("abc", "x", "727a18834cf81a300679731677127b7f02929259f780052b6ee7a60272fcf1a4"),
)
#for (m, salt, want) in vectors {
  assert.eq(digest-hex(digest(m, salt: salt)), want, message: "vector failed for " + repr(m))
}

// 32 bytes, all in range
#let d = digest("abc")
#assert.eq(d.len(), 32)
#assert(d.all(b => 0 <= b and b <= 255))

// str and equivalent bytes agree
#assert.eq(digest("Grüße"), digest(bytes("Grüße")))
// Different salt, different digest
#assert.ne(digest("abc"), digest("abc", salt: "y"))
// Long input stays within int range (no overflow panic)
#assert.eq(digest("x" * 5000).len(), 32)

// Bit helpers: MSB-first
#let e = (0b10110000,) + (0,) * 31
#assert.eq(bit-string(e, 0, 8), "10110000")
#assert.eq(bit(e, 0), 1)
#assert.eq(bit(e, 1), 0)
#assert.eq(bits(e, 0, 4), (1, 0, 1, 1))
#assert.eq(byte(d, 3), d.at(3))
#assert.eq(digest-hex((0, 15, 16, 255)), "000f10ff")

// Avalanche: flipping one character changes roughly half the 256 bits.
#let popcount(x) = range(8).map(i => x.bit-rshift(i).bit-and(1)).sum()
#for (a, b) in (("abc", "abd"), ("Dear Dr. Smith,", "Dear Dr. Smyth,"), ("a" * 100, "a" * 99 + "b")) {
  let da = digest(a)
  let db = digest(b)
  let diff = range(32).map(i => popcount(da.at(i).bit-xor(db.at(i)))).sum()
  assert(96 <= diff and diff <= 160, message: "avalanche for " + repr(a) + ": " + str(diff) + " bits differ")
}
digest tests ok
