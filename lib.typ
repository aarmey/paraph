// paraph: data seals for Typst letters.
// Public API is re-exported from here as issues land (see README / issue #1).

#let paraph-version = "0.1.0"

#import "src/digest.typ": digest, digest-hex, bit, bits, bit-string, byte
#import "src/input.typ": message, source-digest, content-text, normalize-text
#import "src/geom.typ": polar, polar-x, arc-path, arc-segments, wedge, quarter
