.global __start
.text
__start:
bootloader:
    lui t0, 0x42000
    lw s2, (t0)         # Load the image width
    lw s3, 4(t0)        # Load the image height
    lw s4, 8(t0)        # Pixel start address & loop counter
    li t2, 4
    addi s5, s2, 2      # Add padding on both sides
    mul s5, s5, t2      # Convert bytes to word
    neg s6, s5          # -img_width
    addi s7, s6, 4      # -img_width + 1
    addi s8, s6, -4     # -img_width - 1
    addi s9, s5, 4      # img_width + 1
    addi s10, s5, -4    # img_width - 1
    li s11, 9           # Number of pixels for blurring
    addi s0, s2, 0      # Set the row check
    addi s1, s3, 0      # Set the column check
    li a0, 0x42002000   # Store address for the blur image
blur:
    lw t0, (s4)         # Load pixel value (i)
    lw t1, 4(s4)        # Load pixel value (Right)
    add t0, t0, t1
    lw t1, -4(s4)       # Load pixel value (Left)
    add t0, t0, t1
    lwi t1, s6(s4)      # Load pixel value (Up)
    add t0, t0, t1
    lwi t1, s7(s4)      # Load pixel value (Up-Right)
    add t0, t0, t1
    lwi t1, s8(s4)      # Load pixel value (Up-Left)
    add t0, t0, t1
    lwi t1, s5(s4)      # Load pixel value (Down)
    add t0, t0, t1
    lwi t1, s9(s4)      # Load pixel value (Down-Right)
    add t0, t0, t1
    lwi t1, s10(s4)     # Load pixel value (Down-Left)
    add t0, t0, t1
    div t0, t0, s11     # Average the output (Divided by 9)
    sw t0, (a0)
    addi a0, a0, 4
    addi s4, s4, 4
    addi s0, s0, -1
    bnez s0, blur
    addi s4, s4, 8
    addi s0, s2, 0
    addi s1, s1, -1
    bnez s1, blur
    rdcycle t5
    rdcycleh t6
    lui t3, 0x42003
    addi t3, t3, 0x500
    sw t5, 0(t3)
    addi t3, t3, 4
    sw t6, 0(t3)
nop_loop:
    nop
    j nop_loop
