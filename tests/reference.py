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
