// A realistic letter with a data seal.
//
// The seal covers the sender, recipient, date and the body of the letter. The body lives in
// body.txt and is used twice: once as the text that is hashed, and once typeset into the page.
// Edit any of them and the seal changes.
#import "../lib.typ": *

#let sender = "Aaron Meyer"
#let recipient = "Dr. J. Smith"
#let date = "4 November 2026"
#let body = read("body.txt")

// The text the seal fingerprints. A dictionary keeps the fields apart, so moving a word from
// the recipient into the date still changes the seal.
#let source = (sender: sender, recipient: recipient, date: date, body: body)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1in),
  // Page-anchored, bottom-right; the margin offsets keep it inside the text block's corner.
  ..seal-page(source, kind: "ring", alignment: bottom + right, dx: -0.8in, dy: -0.6in, size: 1in, caption: true),
)
#set text(size: 11pt)
#set par(justify: true, leading: 0.7em, spacing: 1.2em)

#align(right)[
  #sender \
  Department of Bioengineering \
  Los Angeles, California
]

#v(1.5em)
#date

#v(1em)
#recipient \
Symposium Organizing Committee

#v(1em)
Dear Dr. Smith,

// Paragraphs are the blocks of body.txt separated by blank lines.
#for paragraph in body.split(regex("\n\s*\n")) [
  #paragraph.trim()

]

Sincerely,

#v(2.5em)
#sender
