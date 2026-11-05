def h32(data, run, salt):
    h = 2166136261
    for b in (f"{run}|{salt}|".encode() + data):
        h = ((h ^ b) * 16777619) & 0xFFFFFFFF
    for _ in range(2):
        h ^= h >> 16
        h = (h * 73244475) & 0xFFFFFFFF
    return h ^ (h >> 16)
def digest(data, salt=""):
    out = bytearray()
    for r in range(8):
        out += h32(data, r, salt).to_bytes(4, "big")
    return bytes(out)
import sys
import random
for s, salt in [("",""),("abc",""),("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",""),("Grüße → ü",""),("abc","x")]:
    print(repr(s), repr(salt), digest(s.encode(), salt).hex())
# avalanche
import random
tot=0;n=0
random.seed(1)
for _ in range(500):
    m = bytes(random.randrange(32,127) for _ in range(random.randrange(1,200)))
    i = random.randrange(len(m)); m2 = bytearray(m); m2[i] ^= 1<<random.randrange(5)
    a,b = digest(m), digest(bytes(m2))
    tot += sum(bin(x^y).count("1") for x,y in zip(a,b)); n+=1
print("mean flipped bits", tot/n, "of 256")

# ---- Rule 30 rosette reference (issue #9) -------------------------------------------
def rule30_rows(seed_bits, rings=22):
    W = len(seed_bits)
    rows = [list(seed_bits)]
    for _ in range(rings - 1):
        p = rows[-1]
        rows.append([(30 >> (4 * p[(i - 1) % W] + 2 * p[i] + p[(i + 1) % W])) & 1 for i in range(W)])
    return rows

def bits_of(d, n):
    return [(d[i // 8] >> (7 - i % 8)) & 1 for i in range(n)]

if __name__ == "__main__":
    d = digest(b"paraph-v1\nabc")
    rows = rule30_rows(bits_of(d, 64))
    print("rule30 seed  ", "".join(map(str, rows[0])))
    print("rule30 ring 5", "".join(map(str, rows[5])))
    print("rule30 ring21", "".join(map(str, rows[21])))
    print("rule30 live cells", sum(map(sum, rows)))

# ---- Chord wheel reference (issue #11) -----------------------------------------------
def chords(d):
    out = []
    for k in range(24):
        a = d[k] % 60
        b = (a + 3 + d[k + 8] % 54) % 60
        out.append((a, b))
    return out

if __name__ == "__main__":
    d = digest(b"paraph-v1\nabc")
    print("chords", chords(d))
    print("rim bits 1..59", "".join(str(b) for b in bits_of(d, 60)[1:]))
