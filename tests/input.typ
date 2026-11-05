#import "../lib.typ": *

#let hex(m) = digest-hex(digest(m))

// --- normalization -------------------------------------------------------
#assert.eq(normalize-text("a  \r\nb\t\rc\n\n\n\nd\n"), "a\nb\nc\n\nd")
#assert.eq(normalize-text("  lead and trail  "), "lead and trail")

// --- message tag and equivalence between source types -------------------
#assert.eq(message("abc"), bytes("paraph-v1\nabc"))
#assert.eq(message(bytes("abc")), message("abc"))                      // bytes == same str
#assert.eq(message("abc\r\n"), message("abc"))                         // normalization applies to str
#assert.ne(message("abc\r\n", normalize: "none"), message("abc"))      // ...unless disabled
#assert.eq(message(bytes("abc\r\n")), bytes("paraph-v1\nabc\r\n"))     // bytes always raw
#assert.eq(source-digest("abc"), digest(bytes("paraph-v1\nabc")))
#assert.ne(source-digest("abc"), source-digest("abc", salt: "s"))

// --- content flattening --------------------------------------------------
#assert.eq(content-text([Hello *bold* and _em_.]), "Hello bold and em.")
#assert.eq(content-text([It's "quoted".]), "It's \"quoted\".")      // smartquotes -> ' and "
#assert.eq(content-text([a#linebreak()b]), "a\nb")
#assert.eq(content-text([a\ b]), "a\n b")
#assert.eq(content-text([x

y]), "x\n\ny")
#assert.eq(content-text([= Title]), "Title\n")
#assert.eq(content-text([- one\n- two]).contains("one"), true)
#assert.eq(content-text([/ Term: description]), "Term description\n")  // terms keep both parts
#assert.eq(content-text([#link("https://x.org")[site]]), "site")
#assert.eq(content-text([$a^2$]), "a2")
#assert.eq(content-text([see #footnote[note]]), "see note")
#assert.eq(content-text(none), "")
// Unknown/non-text elements are skipped and reported in debug mode
#assert.eq(content-text([a #h(1em) b #box(width: 1em)], debug: true).skipped, ("h", "box"))

// Same words typeset as content or given as a string give the same message
#assert.eq(message([Dear *Dr.* Smith, thanks.]), message("Dear Dr. Smith, thanks."))
#assert.eq(message([Hello

World]), message("Hello\n\nWorld"))
// ...and are different from different words
#assert.ne(message([Dear Dr. Smith]), message([Dear Dr. Smyth]))

// --- arrays and dictionaries ---------------------------------------------
#assert.ne(message(("a b",)), message(("a", "b")))          // element boundaries matter
#assert.ne(message(("a", "b")), message("a\nb"))            // ...and differ from plain newlines
#assert.eq(message(("a", [b], bytes("c"))), message(("a", "b", bytes("c"))))
#assert.ne(message((sender: "A", body: "x")), message((sender: "x", body: "A")))
#assert.ne(message((a: "1")), message((b: "1")))            // keys matter
#assert.eq(message((:)), bytes("paraph-v1\n"))

// --- the realistic pattern: body.txt used for both display and hash ----------
#let body = "First paragraph.\r\n\r\nSecond paragraph.\r\n"
#assert.eq(
  message((sender: "Aaron Meyer", recipient: "J. Smith", date: "2026-11-04", body: body)),
  message((sender: "Aaron Meyer", recipient: "J. Smith", date: "2026-11-04", body: "First paragraph.\n\nSecond paragraph.")),
)

input tests ok
