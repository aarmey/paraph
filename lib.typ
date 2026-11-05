// paraph: data seals for Typst letters.
// Public API is re-exported from here as issues land (see README / issue #1).

#let paraph-version = "0.1.0"

#import "src/digest.typ": digest, digest-hex, bit, bits, bit-string, byte
#import "src/input.typ": message, source-digest, content-text, normalize-text
#import "src/geom.typ": polar, polar-x, arc-path, arc-segments, wedge, quarter
#import "src/core.typ": defaults, resolve, check, with-opacity, ink-for, tinted, sw, put, canvas, tick, orientation-tick, boundary-ring, dot
#import "src/seals/ring.typ": ring-seal
#import "src/seals/phyllotaxis.typ": phyllotaxis-seal
#import "src/seals/rule30.typ": rule30-seal
#import "src/seals/truchet.typ": truchet-seal
