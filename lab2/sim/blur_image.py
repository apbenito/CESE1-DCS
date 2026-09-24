"""Test image for the blur programs, plus a reference to check the output.

    python3 blur_image.py make  blur_data.mem [size]   # write the input data memory
    python3 blur_image.py check dump.mem [size]        # compare the simulated output

Data memory layout (word index = (address & 0xFFFF) / 4):
    0x4200_0000  image width, height, address of the first real pixel
    0x4200_2000  blurred output, written by the program
    0x4200_3500  64-bit cycle count, written by the program
    0x4200_8000  zero-padded input image (clear of the output for any size used)

For 64x64 the output runs past 0x4200_3500, so the cycle count overwrites two
output pixels at the end; those two are skipped when checking.
"""
import sys

W = H = int(sys.argv[3]) if len(sys.argv) > 3 else 32
PAD_W = W + 2
IMAGE_BASE = 0x42008000
OUT_BASE = 0x42002000
CYCLE_ADDR = 0x42003500


def idx(addr):
    return (addr & 0xFFFF) // 4


def test_image():
    """A filled circle and a square, black & white like the lab's image."""
    k = W / 32                                     # scale the shapes with the image
    img = [[0] * W for _ in range(H)]
    for r in range(H):
        for c in range(W):
            if (r - 12 * k) ** 2 + (c - 11 * k) ** 2 <= (7 * k) ** 2:
                img[r][c] = 255
            if 19 * k <= r <= 27 * k and 18 * k <= c <= 28 * k:
                img[r][c] = 255
    return img


def padded(img):
    return [[0] * PAD_W] + [[0] + row + [0] for row in img] + [[0] * PAD_W]


def reference_blur(img):
    p = padded(img)
    return [[sum(p[r + dr][c + dc] for dr in (-1, 0, 1) for dc in (-1, 0, 1)) // 9
             for c in range(1, W + 1)] for r in range(1, H + 1)]


def make(path):
    mem = [0] * (idx(IMAGE_BASE) + PAD_W * PAD_W)
    mem[0], mem[1] = W, H
    mem[2] = IMAGE_BASE + (PAD_W + 1) * 4          # first real pixel, row 1 col 1
    for r, row in enumerate(padded(test_image())):
        for c, v in enumerate(row):
            mem[idx(IMAGE_BASE) + r * PAD_W + c] = v
    with open(path, "w") as f:
        f.write("".join(f"{w:08x}\n" for w in mem))


def check(path):
    words = []
    for line in open(path):
        line = line.strip()
        if line and not line.startswith("//"):
            words.append(int(line, 16) if "x" not in line.lower() else 0)
    got = [[words[idx(OUT_BASE) + r * W + c] for c in range(W)] for r in range(H)]
    want = reference_blur(test_image())
    skip = {idx(CYCLE_ADDR), idx(CYCLE_ADDR) + 1}
    bad = sum(got[r][c] != want[r][c] for r in range(H) for c in range(W)
              if idx(OUT_BASE) + r * W + c not in skip)
    cycles = words[idx(CYCLE_ADDR)] | (words[idx(CYCLE_ADDR) + 1] << 32)
    print(f"output pixels wrong: {bad} of {W * H}")
    print(f"program cycle count (rdcycle): {cycles}")


if __name__ == "__main__":
    {"make": make, "check": check}[sys.argv[1]](sys.argv[2])
