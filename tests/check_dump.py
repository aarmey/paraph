"""Cross-check the Typst bit dump against the independent Python implementation.

Runs `typst query` on tests/bits-dump.typ and compares every field with tests/reference.py.
Usage (from the repository root):  python3 tests/check_dump.py
Exits non-zero, naming the differing fields, if the two implementations disagree.
"""
import io, json, subprocess, sys, contextlib
from pathlib import Path

root = Path(__file__).resolve().parent.parent
# Importing reference.py prints its vectors; keep that out of the way.
sys.path.insert(0, str(root / "tests"))
with contextlib.redirect_stdout(io.StringIO()):
    import reference

proc = subprocess.run(
    ["typst", "query", "--root", str(root), str(root / "tests" / "bits-dump.typ"), "<bits-dump>", "--field", "value", "--one"],
    capture_output=True, text=True,
)
if proc.returncode != 0:
    sys.exit("typst query failed:\n" + proc.stderr)
got = json.loads(proc.stdout)
want = reference.dump(reference.SAMPLE)

bad = [k for k in sorted(set(got) | set(want)) if got.get(k) != want.get(k)]
if bad:
    for k in bad:
        print(f"MISMATCH {k}\n  typst : {str(got.get(k))[:120]}\n  python: {str(want.get(k))[:120]}")
    sys.exit(1)
print(f"bit dump matches the Python reference ({len(want)} fields, digest {want['digest'][:16]}...)")
