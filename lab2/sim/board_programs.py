"""Extract what the board runs from the template's Vitis archive.

    python3 board_programs.py <vitis_export_archive.ide.zip> <out_dir>
    python3 board_programs.py check <dump.mem> <out_dir>

img_blur/src/instruction.h holds the two RISC-V programs the ARM loads, and
data.h holds the input image (data[]) and the output the ARM checks against
(processed_data[]). This writes them as .mem files for tb.v, and `check`
compares a simulated output the same way img_blur.c does.
"""
import pathlib
import re
import sys
import zipfile

OUT_INDEX = 0x2000 // 4        # 0x4200_2000, blurred image
CYCLE_INDEX = 0x3500 // 4      # 0x4200_3500, cycle count the ARM reads


def array(text, name):
    body = re.search(name + r"\[\]\s*=\s*\{(.*?)\};", text, re.S).group(1)
    return [int(x, 0) for x in re.findall(r"0x[0-9a-fA-F]+|\d+", body)]


def write_mem(path, words):
    path.write_text("".join(f"{w:08x}\n" for w in words))


def extract(archive, out):
    out.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as z:
        ins = z.read("img_blur/src/instruction.h").decode().replace("\r", "")
        dat = z.read("img_blur/src/data.h").decode().replace("\r", "")
    write_mem(out / "board_baseline.mem", array(ins, "instructions"))
    write_mem(out / "board_modified.mem", array(ins, "instructions_modified"))
    write_mem(out / "board_data.mem", array(dat, "data"))
    (out / "board_expected.txt").write_text("\n".join(map(str, array(dat, "processed_data"))))


def check(dump, out):
    words = [int(l, 16) if "x" not in l.lower() else -1
             for l in open(dump) if l.strip() and not l.startswith("//")]
    expected = [int(x) for x in (out / "board_expected.txt").read_text().split()]
    got = words[OUT_INDEX:OUT_INDEX + len(expected)]
    wrong = sum(g != e for g, e in zip(got, expected))
    verdict = "blurred correctly" if wrong == 0 else "blurred INCORRECTLY"
    print(f"pixels differing from processed_data[]: {wrong} of {len(expected)} -> image {verdict}")
    print(f"cycle count the ARM reads: {words[CYCLE_INDEX]}")


if __name__ == "__main__":
    if sys.argv[1] == "check":
        check(sys.argv[2], pathlib.Path(sys.argv[3]))
    else:
        extract(sys.argv[1], pathlib.Path(sys.argv[2]))
