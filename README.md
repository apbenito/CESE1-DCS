# CESE1-DCS

Digital Computing Systems (CESE4130) — TU Delft, EEMCS/QCE, 2026/27.

## Layout

    lab1/
      Async_Encoder_Decoder_template/   Part 1 — async encoder/decoder
      Debouncer/                        Part 2 — debouncing + counters
      Road_Sign_template/               Part 3 — FSM road sign
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

    make p1        # compile + run Part 1 testbench
    make p1 WAVE=1 # ...and open the waveform in gtkwave
    make clean

Requires `brew install icarus-verilog gtkwave`.

## Vivado

Synthesis, implementation, bitstream generation, block-diagram editing and
programming the board all need Vivado 2023.2 on x86 — the Windows machine.
Board: PYNQ-Z1 (Zynq XC7Z020).

Note: `.xpr` is not tracked. On a fresh machine (e.g. a lab PC), download the
template projects and drop the tracked sources in, rather than expecting a
project file to travel.
