# Modified test program from the lab manual (Part 1, Running the Modified Code)
_start:
    lui  t0, 0x40000     # t0 = 0x4000_0000 (base)
    addi t1, x0, 0x50    # t1 = 0x50 (index)
    lwi  t2, t1(t0)      # t2 = mem[t0 + t1] = mem[0x4000_0050]
    addi t1, t1, 4
    lwi  t3, t1(t0)      # t3 = mem[0x4000_0054]
    add  t3, t3, t2
loop:
    nop
    j loop
