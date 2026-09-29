# CESE1-DCS

Digital Computing Systems (CESE4130) — TU Delft, EEMCS/QCE, 2026/27.

## Layout

    lab1/
      Async_Encoder_Decoder_template/   Part 1 — async encoder/decoder
      Debouncer/                        Part 2 — debouncing + counters
      Road_Sign_template/               Part 3 — FSM road sign
      LFSR/                             Bonus — 6-bit LFSR (no Vivado project yet)
      PYNQ-Z1_Constraints.xdc           blank board constraints (for the bonus)
      Makefile                          iverilog simulation targets

Each Vivado project keeps its sources where Vivado expects them:

    <Project>.srcs/sources_1/new/   design (.v) + that project's PYNQ-Z1_C.xdc
    <Project>.srcs/sim_1/new/       testbenches

Only sources and block diagrams (`.bd`) are tracked. Everything Vivado
generates (`.runs`, `.cache`, `.gen`, `.sim`, `.xpr`) is gitignored.

## Simulating locally

Behavioural simulation runs natively on macOS with Icarus Verilog — no Vivado,
no VM. From `lab1/`:

    make p1          # Part 1 — async encoder / cardinal decoder
    make p2          # Part 2 — debounced up/down counter, gray encoded
    make p3          # Part 3 — road sign FSM
    make bonus       # Bonus — 6-bit LFSR, all three seeds
    make p3 WAVE=1   # ...and open the waveform in gtkwave
    make clean

Requires `brew install icarus-verilog gtkwave`.

## Vivado

Synthesis, implementation, bitstream generation, block-diagram editing and
programming the board all need Vivado 2023.2 on x86 — the Windows machine.
Board: PYNQ-Z1 (Zynq XC7Z020).

Note: `.xpr` is not tracked. On a fresh machine (e.g. a lab PC), download the
template projects and drop the tracked sources in, rather than expecting a
project file to travel.

## Lab 2

    lab2/
      solution/                        the Vivado project with lwi added
        pico32.srcs/sources_1/bd/picorv32.v   the core
        pico32.srcs/sim_1/new/testbench.v     the template's testbench (loads mod_memory.mem)
      template/                        the template exactly as downloaded, as a clean base
      sim/                             Icarus Verilog verification of lwi
      Makefile

`solution/` and `template/` are complete projects, stored byte for byte, so
`git diff --no-index lab2/template lab2/solution` shows exactly what changed.

From `lab2/`: `make test`, `make blur`, `make board` and `make scaling` check the
core in `solution/`. `make board` runs the exact programs and image from the
Vitis archive and checks the output the same way the ARM does. `make ta` runs
the testbench.v under Icarus and writes a waveform (`P=modified` for the lwi
program); `make wave` does the same with the standalone testbench. Open the
.vcd with the Surfer extension in VS Code.
