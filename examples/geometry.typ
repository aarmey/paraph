// Visual check for src/geom.typ: arc-path over a reference circle(), wedges and quarters.
// Zoom to 400%: the red Bézier circle must hide the blue reference circle.
#import "../lib.typ": *
#set page(width: 9cm, height: 5cm, margin: 0.3cm)

#let canvas(body) = box(width: 4cm, height: 4cm, stroke: 0.2pt + luma(200), body)
#canvas[
  #place(top + left, dx: 0.4cm, dy: 0.4cm, circle(radius: 1.6cm, stroke: 0.6pt + blue))
  #place(top + left, arc-path(2cm, 2cm, 1.6cm, 0deg, 360deg, stroke: 0.2pt + red))
  #place(top + left, arc-path(2cm, 2cm, 1.2cm, 20deg, 250deg, stroke: 0.8pt + black))
  #place(top + left, wedge(2cm, 2cm, 0.4cm, 0.9cm, 100deg, 160deg, fill: orange.transparentize(30%)))
]
#h(0.3cm)
#canvas[
  // Truchet-style tile: arcs centred on opposite corners, pointing into the tile
  #place(top + left, rect(width: 3cm, height: 3cm, stroke: 0.3pt + luma(160)), dx: 0.5cm, dy: 0.5cm)
  #place(top + left, quarter(0.5cm, 0.5cm, 1.5cm, "br", stroke: 1.2pt + black))
  #place(top + left, quarter(3.5cm, 3.5cm, 1.5cm, "tl", stroke: 1.2pt + black))
  #place(top + left, quarter(3.5cm, 0.5cm, 1.5cm, "bl", stroke: 1.2pt + red))
  #place(top + left, quarter(0.5cm, 3.5cm, 1.5cm, "tr", stroke: 1.2pt + red))
]
