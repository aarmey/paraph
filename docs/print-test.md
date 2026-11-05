# Print test (issue #16)

Goal: choose the default `strength` (and revisit the per-mark opacities) so that on real paper the 0-bits stay distinguishable from blank paper while the seal stays subtle.

The opacities in the seal specs were tuned for a screen, so expect to adjust them after printing.

## Procedure

1. Compile `examples/print-test.typ`:
   ```bash
   typst compile --root . examples/print-test.typ out/print-test.pdf
   ```
2. Print `out/print-test.pdf` on the printer and paper you will actually use for letters. Print at **100% scale** (not "fit to page"). Check the 1-inch bar on each page with a ruler.
3. For each seal and strength (0.8, 1.0, 1.4) at both sizes (1.1 in and 0.6 in), judge by eye:
   - Are 0-bits (faint marks) distinguishable from blank paper?
   - Is the seal still subtle enough to sit on a letter?
   - Does it stay legible at 0.6 in?
4. Scan the sheet at 300 dpi and check that the marks are still resolvable in the scan.
5. Record the results below, set the default `strength` in `src/core.typ` (`defaults.strength`), and update the README note on opacities.
6. Attach photos or scans to issue #16.

## Results (fill in)

Printer / paper / toner or ink: _________________________

| Seal | Strength 0.8 | Strength 1.0 | Strength 1.4 | Legible at 0.6 in? | Scan at 300 dpi OK? |
|---|---|---|---|---|---|
| ring | | | | | |
| phyllotaxis | | | | | |
| truchet | | | | | |
| rule30 | | | | | |
| chord | | | | | |

Chosen default `strength`: ______

Per-mark opacities to change (seal, mark, old, new): ______
