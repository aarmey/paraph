// The paraph demonstration page. Built by Typst's HTML export (see site/build.sh and
// .github/workflows/pages.yml), so building it also proves that every seal and styling renders.
#import "../lib.typ": *
#import "../src/seals/truchet.typ": cell-count

#set document(title: "paraph: data seals for Typst letters")

#let css = "
:root{--ink:#3b2f22;--paper:#fbf8f3;--card:#fff;--line:#e4dccf;--muted:#6b6258;--accent:#684c2e}
*{box-sizing:border-box}
body{margin:0;background:var(--paper);color:var(--ink);font:16px/1.55 system-ui,-apple-system,'Segoe UI',sans-serif}
main{max-width:62rem;margin:0 auto;padding:2.5rem 1.25rem 4rem}
h1{font-size:2.6rem;margin:0 0 .25rem;letter-spacing:-.02em}
h2{margin:3rem 0 .4rem;border-bottom:1px solid var(--line);padding-bottom:.35rem}
h3{margin:1.6rem 0 .3rem}
p,li{max-width:46rem}
a{color:var(--accent)}
.lede{font-size:1.15rem;color:var(--muted)}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(9.2rem,1fr));gap:.8rem;margin:.9rem 0}
.wide{grid-template-columns:repeat(auto-fill,minmax(14rem,1fr))}
.card{background:var(--card);border:1px solid var(--line);border-radius:.6rem;padding:.7rem .5rem .5rem;text-align:center;display:flex;flex-direction:column;align-items:center;gap:.4rem}
.card svg{max-width:100%;height:auto}
.cap{font:12px/1.3 ui-monospace,Menlo,monospace;color:var(--muted)}
pre,code{font-family:ui-monospace,Menlo,monospace;font-size:.85rem}
pre{background:#fff;border:1px solid var(--line);border-radius:.5rem;padding:.8rem 1rem;overflow:auto}
.digest{font:13px ui-monospace,Menlo,monospace;word-break:break-all;color:var(--muted)}
.note{border-left:4px solid var(--accent);background:#fff;padding:.5rem 1rem;border-radius:0 .5rem .5rem 0}
img.page{max-width:100%;border:1px solid var(--line);border-radius:.4rem;background:#fff}
.links a{display:inline-block;margin:0 .8rem .4rem 0}
"
#html.elem("style", css)

// --- helpers -------------------------------------------------------------------
#let kinds = (
  (kind: "ring", name: "Ring code", bits: "200 bits on five tracks"),
  (kind: "phyllotaxis", name: "Phyllotaxis", bits: "256 bits on a golden-angle spiral"),
  (kind: "truchet", name: "Truchet", bits: str(cell-count) + " bits as quarter-arc tiles"),
  (kind: "rule30", name: "Rule 30 rosette", bits: "64 data bits grown by Rule 30"),
  (kind: "chord", name: "Chord wheel", bits: "59 rim bits plus verify-only chords"),
)

#let div(class, body) = html.elem("div", attrs: (class: class), body)
#let card(label, drawing) = div("card", {
  html.frame(drawing)
  div("cap", label)
})
// Truchet masks its edge with the `paper` colour: match it to any background we draw behind it.
#let seal-for(source, kind, opts) = {
  let o = opts
  if kind == "truchet" and "background" in o and "paper" not in o { o.insert("paper", o.background) }
  seal(source, kind: kind, size: 1.15in, ..o)
}

#let message = (
  sender: "Aaron Meyer",
  recipient: "Dr. J. Smith",
  date: "4 November 2026",
  body: "Thank you for the invitation to speak at the spring symposium.",
)
#let message-changed = (..message, body: "Thanx you for the invitation to speak at the spring symposium.")

// Variants shown for every kind: (label, options)
#let variants = (
  ("default", (:)),
  ("ink: blue", (ink: rgb("#1f4e8c"))),
  ("ink: green", (ink: rgb("#2f6b4f"))),
  ("ink: wine", (ink: rgb("#7a2a3a"))),
  ("ink: black", (ink: rgb("#1a1a1a"))),
  ("ink-off: red, strength 2", (ink: rgb("#1f4e8c"), ink-off: rgb("#b03030"), strength: 2)),
  ("strength: 0.6", (strength: 0.6)),
  ("strength: 1.6", (strength: 1.6)),
  ("stroke-scale: 1.7", (stroke-scale: 1.7)),
  ("rotation: 30deg", (rotation: 30deg)),
  ("rotation: 90deg", (rotation: 90deg)),
  ("background: disc", (background: rgb("#efe6d6"))),
  ("background: square", (background: rgb("#e3ecf4"), background-shape: "square")),
  ("no boundary / orientation", (boundary: false, orientation: false)),
  ("salt: \"b\"", (salt: "b")),
)

// --- page ----------------------------------------------------------------------
#html.elem("main")[
  #html.elem("h1")[paraph]
  #div("lede")[Data seals for Typst letters. A small circular mark is a visual fingerprint of your letter's text: change one character and every seal changes. Five styles, all vector.]

  #div("links")[
    #link("https://github.com/aarmey/paraph")[Source on GitHub]
    #link("pdf/letter.pdf")[Example letter (PDF)]
    #link("pdf/gallery.pdf")[Gallery (PDF)]
    #link("pdf/styling.pdf")[Styling (PDF)]
    #link("pdf/placement.pdf")[Placement (PDF)]
  ]

  #div("note")[paraph is *not cryptographic*. The hash is a simple non-secure function that maps text to 256 bits. A seal is a fingerprint, not a signature.]

  = One character changes everything
  The same letter, then the same letter with "Thank" changed to "Thanx".
  #for (label, source) in (("original", message), ("one character changed", message-changed)) [
    == #label
    #div("digest")[#seal-digest(source)]
    #div("grid")[
      #for k in kinds { card(k.name, seal-for(source, k.kind, (:))) }
    ]
  ]

  = Styling every seal
  Each kind below is shown with the same set of options. Every option works on every seal.
  #for k in kinds [
    == #k.name
    #k.bits.
    #div("grid")[
      #for (label, opts) in variants { card(label, seal-for(message, k.kind, opts)) }
    ]
  ]

  = Sizes
  Seals are vectors, so they scale. Here are all five at 1.1 in, 0.6 in and 0.35 in.
  #div("grid")[
    #for size in (1.1in, 0.6in, 0.35in) {
      for k in kinds {
        card(k.kind + ", " + repr(size), seal(message, kind: k.kind, size: size))
      }
    }
  ]

  = Placement
  `seal-page` and `seal-at` put a seal in a corner of a page without moving your text; `caption: true` prints the start of its digest. Here is the example letter, with a ring seal at the bottom right.
  #html.elem("p")[#html.elem("img", attrs: (class: "page", src: "img/letter.png", alt: "An example letter with a ring seal in the bottom-right corner", width: "420"))]
  ```typst
  #import "@local/paraph:0.1.0": *
  #set page(..seal-page(source, kind: "ring", alignment: bottom + right,
                        dx: -0.8in, dy: -0.6in, size: 1in, caption: true))
  ```

  = What can be sealed
  Anything that describes the text: a string, bytes, content, an array or a dictionary. Typeset content is flattened to its text first, so formatting does not change the seal:
  #div("grid wide")[
    #card("content: Dear *Dr.* Smith", seal([Dear *Dr.* Smith], kind: "ring", size: 1.15in))
    #card("string: Dear Dr. Smith", seal("Dear Dr. Smith", kind: "ring", size: 1.15in))
    #card("string: Dear Dr. Smyth", seal("Dear Dr. Smyth", kind: "ring", size: 1.15in))
  ]
  The first two seals are identical because the text is the same; the third differs by one letter.

  = Read the spec
  The full encoding specification (how to decode each seal) is in the #link("https://github.com/aarmey/paraph#encoding-specification")[README].
]
