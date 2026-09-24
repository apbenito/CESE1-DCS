# Baseline test program from the lab manual (Part 1, Running the Baseline)
_start:
    lui  t0, 0x40000     # upper 20 bits of the address
    addi t0, t0, 0x50    # t0 = 0x4000_0050
    lw   t1, 0(t0)       # t1 = mem[0x4000_0050]
    lw   t2, 4(t0)       # t2 = mem[0x4000_0054]
    add  t3, t1, t2
loop:
    nop
    j loop
