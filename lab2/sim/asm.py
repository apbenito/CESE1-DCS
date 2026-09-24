"""Tiny RV32IM assembler for the Lab 2 test programs, with the custom lwi.

Only covers the instructions these programs use. Writes one 32-bit hex word
per line, the format $readmemh expects.

    python3 asm.py program.s out.mem
"""
import re
import sys

REGS = {f"x{i}": i for i in range(32)}
REGS.update({
    "zero": 0, "ra": 1, "sp": 2, "gp": 3, "tp": 4,
    "t0": 5, "t1": 6, "t2": 7, "s0": 8, "fp": 8, "s1": 9,
    "a0": 10, "a1": 11, "a2": 12, "a3": 13, "a4": 14, "a5": 15, "a6": 16, "a7": 17,
    "s2": 18, "s3": 19, "s4": 20, "s5": 21, "s6": 22, "s7": 23, "s8": 24, "s9": 25,
    "s10": 26, "s11": 27, "t3": 28, "t4": 29, "t5": 30, "t6": 31,
})


def reg(name):
    return REGS[name.strip()]


def num(text):
    return int(text.strip(), 0)


# ---- instruction formats -------------------------------------------------

def r_type(funct7, rs2, rs1, funct3, rd, opcode):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def i_type(imm, rs1, funct3, rd, opcode):
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def s_type(imm, rs2, rs1, funct3, opcode):
    imm &= 0xFFF
    return ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | ((imm & 0x1F) << 7) | opcode


def b_type(imm, rs2, rs1, funct3, opcode):
    imm &= 0x1FFF
    return (((imm >> 12) & 1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) \
        | (funct3 << 12) | (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 1) << 7) | opcode


def u_type(imm20, rd, opcode):
    return ((imm20 & 0xFFFFF) << 12) | (rd << 7) | opcode


def j_type(imm, rd, opcode):
    imm &= 0x1FFFFF
    return (((imm >> 20) & 1) << 31) | (((imm >> 1) & 0x3FF) << 21) | (((imm >> 11) & 1) << 20) \
        | (((imm >> 12) & 0xFF) << 12) | (rd << 7) | opcode


def mem_operand(text):
    """'-4(s4)' -> (-4, 20),  '(s4)' -> (0, 20),  's6(s4)' -> ('s6', 20)"""
    m = re.fullmatch(r"\s*(.*?)\s*\(\s*(\w+)\s*\)\s*", text)
    off, base = m.group(1), reg(m.group(2))
    if off in REGS:
        return off, base
    return (num(off) if off else 0), base


# ---- pseudo-instruction expansion -----------------------------------------

def expand(op, args):
    """Turn pseudo-instructions into real ones. Returns a list of (op, args)."""
    if op == "nop":
        return [("addi", ["x0", "x0", "0"])]
    if op == "neg":
        return [("sub", [args[0], "x0", args[1]])]
    if op == "bnez":
        return [("bne", [args[0], "x0", args[1]])]
    if op == "j":
        return [("jal", ["x0", args[0]])]
    if op == "rdcycle":
        return [("csrrs", [args[0], "0xC00", "x0"])]
    if op == "rdcycleh":
        return [("csrrs", [args[0], "0xC80", "x0"])]
    if op == "li":
        value = num(args[1]) & 0xFFFFFFFF
        if value >= 0x80000000:
            value -= 1 << 32
        if -2048 <= value < 2048:
            return [("addi", [args[0], "x0", str(value)])]
        hi = ((value + 0x800) >> 12) & 0xFFFFF
        lo = value - (((value + 0x800) >> 12) << 12)
        out = [("lui", [args[0], str(hi)])]
        if lo:
            out.append(("addi", [args[0], args[0], str(lo)]))
        return out
    return [(op, args)]


def encode(op, args, pc, labels):
    if op == "add":  return r_type(0b0000000, reg(args[2]), reg(args[1]), 0b000, reg(args[0]), 0b0110011)
    if op == "sub":  return r_type(0b0100000, reg(args[2]), reg(args[1]), 0b000, reg(args[0]), 0b0110011)
    if op == "mul":  return r_type(0b0000001, reg(args[2]), reg(args[1]), 0b000, reg(args[0]), 0b0110011)
    if op == "div":  return r_type(0b0000001, reg(args[2]), reg(args[1]), 0b100, reg(args[0]), 0b0110011)
    if op == "addi": return i_type(num(args[2]), reg(args[1]), 0b000, reg(args[0]), 0b0010011)
    if op == "lui":  return u_type(num(args[1]), reg(args[0]), 0b0110111)
    if op == "csrrs": return i_type(num(args[1]), reg(args[2]), 0b010, reg(args[0]), 0b1110011)
    if op == "lw":
        off, base = mem_operand(args[1])
        return i_type(off, base, 0b010, reg(args[0]), 0b0000011)
    if op == "sw":
        off, base = mem_operand(args[1])
        return s_type(off, reg(args[0]), base, 0b010, 0b0100011)
    if op == "lwi":
        # lwi rd, rs2(rs1): funct7=0000000, funct3=010, opcode=0101011
        index, base = mem_operand(args[1])
        return r_type(0b0000000, reg(index), base, 0b010, reg(args[0]), 0b0101011)
    if op == "bne":
        return b_type(labels[args[2]] - pc, reg(args[1]), reg(args[0]), 0b001, 0b1100011)
    if op == "jal":
        return j_type(labels[args[1]] - pc, reg(args[0]), 0b1101111)
    raise ValueError(f"unsupported instruction: {op}")


def parse(source):
    """Split into (label list, op, args) lines, dropping comments/directives."""
    lines = []
    for raw in source.splitlines():
        line = raw.split("#")[0].strip()
        if not line or line.startswith("."):
            continue
        labels = []
        while ":" in line:
            label, line = line.split(":", 1)
            labels.append(label.strip())
            line = line.strip()
        if not line:
            lines.append((labels, None, [], ""))
            continue
        op, _, rest = line.partition(" ")
        args = [a.strip() for a in rest.split(",")] if rest.strip() else []
        lines.append((labels, op.strip(), args, line))
    return lines


def assemble(source):
    lines = parse(source)

    # pass 1: expand pseudo-ops and record label addresses
    labels, program, pc = {}, [], 0
    for line_labels, op, args, text in lines:
        for label in line_labels:
            labels[label] = pc
        if op is None:
            continue
        for real in expand(op, args):
            program.append((pc, *real, text))
            pc += 4

    # pass 2: encode
    return [(pc, encode(op, args, pc, labels), text) for pc, op, args, text in program]


if __name__ == "__main__":
    # self-check against the example in the lab manual
    assert assemble("lwi t1, s6(s4)")[0][1] == 0x016A232B, "lwi encoding does not match the manual"

    program = assemble(open(sys.argv[1]).read())
    with open(sys.argv[2], "w") as out:
        for _, word, _ in program:
            out.write(f"{word:08x}\n")
    # listing (address, word, source) so the cycle trace can be labelled
    with open(sys.argv[2].rsplit(".", 1)[0] + ".lst", "w") as out:
        for pc, word, text in program:
            out.write(f"{pc:08x} {word:08x} {text}\n")
    print(f"{sys.argv[1]}: {len(program)} instructions -> {sys.argv[2]}")
