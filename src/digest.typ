// Simple 256-bit NON-CRYPTOGRAPHIC digest. Maps any text/bytes to 32 bytes.
// Not secure: collisions are easy to construct on purpose. Used only so that
// each letter gets its own visual fingerprint.
//
// Scheme: 32-bit FNV-1a followed by a small finalizer, run 8 times with a
// different salt byte-prefix each time (8 x 32 = 256 bits).
//
// Typst ints are 64-bit signed and overflow is an error, so every product here
// must stay below 2^63: FNV prime (~2^24) x 32-bit state < 2^56, and the
// finalizer multiplier (73244475 ~ 2^26.1) x 32-bit state < 2^59.

#let _mask32 = 4294967296

#let _fnv-offset = 2166136261
#let _fnv-prime = 16777619
#let _mix-mult = 73244475

/// One 32-bit word. `data` is an array of ints 0..255; `run` distinguishes the
/// eight words; `salt` is a user string mixed into every word.
#let _hash32(data, run, salt) = {
  let h = _fnv-offset
  let prefix = array(bytes(str(run) + "|" + salt + "|"))
  for b in prefix + data {
    h = calc.rem(h.bit-xor(b) * _fnv-prime, _mask32)
  }
  // Finalizer: plain FNV-1a leaves the low bits weakly mixed.
  for _ in range(2) {
    h = h.bit-xor(h.bit-rshift(16))
    h = calc.rem(h * _mix-mult, _mask32)
  }
  h.bit-xor(h.bit-rshift(16))
}

/// 256-bit digest of `input` (a `str` or `bytes`) as an array of 32 ints (0-255).
/// `salt` (a string) is mixed into every word so the same input can give a
/// different digest.
#let digest(input, salt: "") = {
  assert(type(input) in (str, bytes), message: "digest: input must be str or bytes, got " + str(type(input)))
  assert(type(salt) == str, message: "digest: salt must be a string")
  let data = array(bytes(input))
  range(8)
    .map(run => {
      let w = _hash32(data, run, salt)
      (24, 16, 8, 0).map(sh => w.bit-rshift(sh).bit-and(255))
    })
    .flatten()
}

/// Bit `i` (0..255) of digest `d`; MSB-first within each byte.
#let bit(d, i) = {
  assert(0 <= i and i < d.len() * 8, message: "bit: index " + str(i) + " out of range")
  d.at(calc.quo(i, 8)).bit-rshift(7 - calc.rem(i, 8)).bit-and(1)
}

/// Bits `from` up to (not including) `to`, as an array of 0/1.
#let bits(d, from, to) = range(from, to).map(i => bit(d, i))

/// Bits as a "0101..." string (for tests and bit dumps).
#let bit-string(d, from, to) = bits(d, from, to).map(str).join()

/// Byte `i` (0..31) of digest `d`.
#let byte(d, i) = {
  assert(0 <= i and i < d.len(), message: "byte: index " + str(i) + " out of range")
  d.at(i)
}

/// Lowercase hex string of the digest.
#let digest-hex(d) = d.map(b => {
  let h = "0123456789abcdef"
  h.at(calc.quo(b, 16)) + h.at(calc.rem(b, 16))
}).join()
