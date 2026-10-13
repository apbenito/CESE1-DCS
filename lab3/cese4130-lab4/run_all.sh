#!/bin/bash
# Runs every measurement of lab 3 in order and collects the results in
# results/: logs, cycle counts and the plots as PNGs.
#   bash run_all.sh
# Takes a while under emulation; each step's log is written as it runs.
set -u
export PATH=/opt/riscv/bin:$PATH
LAB=$(cd "$(dirname "$0")" && pwd)
OUT=$LAB/results
mkdir -p "$OUT"

# The plot scripts end with plt.show(), which needs a display. Run them with a
# non-interactive backend and save the figure instead.
plot() { # plot <script> <png>
    python3 -c "
import sys, runpy, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
plt.show = lambda *a, **k: plt.savefig('$2', dpi=120)
sys.argv = ['$1']
runpy.run_path('$1', run_name='__main__')
"
}

# Selects the test array that main.c is compiled with by default
set_array() { sed -i "s/^    #define ARRAY [0-9]*/    #define ARRAY $1/" "$LAB/Part2/main.c"; }

step() { echo; echo "===== $* ($(date +%T))"; }

step "Part 1: baseline image blur"
(cd "$LAB/img-blur-baseline" && make gvsoc all count-cycles) > "$OUT/p1_baseline.log" 2>&1
tail -n 1 "$OUT/p1_baseline.log"

step "Part 1: check lwi on the image"
(cd "$LAB/check-image-blur-modified" && make gvsoc all run image) > "$OUT/p1_check.log" 2>&1
tail -n 3 "$LAB/check-image-blur-modified/data.txt"
cp "$LAB/check-image-blur-modified/data.txt" "$OUT/p1_check_data.txt"
cp "$LAB/check-image-blur-modified/"*.png "$OUT/" 2>/dev/null

step "Part 1: modified image blur"
(cd "$LAB/img-blur-modified" && make gvsoc all count-cycles) > "$OUT/p1_modified.log" 2>&1
tail -n 1 "$OUT/p1_modified.log"

step "Part 2: build the 16-core SoC and run the program on 1 core (the baseline)"
cd "$LAB/Part2"
set_array 1
(make gvsoc all run) > "$OUT/p2_run.log" 2>&1
grep "total 3s" "$OUT/p2_run.log"

step "Part 2: verify"
(make verify) > "$OUT/p2_verify.log" 2>&1
tail -n 3 "$OUT/p2_verify.log"

step "Part 2: plot, array 1"
set_array 1
plot test/process.py "$OUT/p2_plot_array1.png" > "$OUT/p2_plot_array1.log" 2>&1
grep "^\[" "$OUT/p2_plot_array1.log"

step "Part 2: diff, array 1 vs array 2"
plot test/diff_array.py "$OUT/p2_diff.png" > "$OUT/p2_diff.log" 2>&1
grep -A 1 "Cycle Count Array" "$OUT/p2_diff.log"

step "Part 2: plot, array 3"
set_array 3
plot test/process.py "$OUT/p2_plot_array3.png" > "$OUT/p2_plot_array3.log" 2>&1
grep "^\[" "$OUT/p2_plot_array3.log"
set_array 1

step "Bonus: build and run with 16 cores"
cd "$LAB/bonus"
(make gvsoc && make all compile_args="-DNUM_CORES=16" && make run) > "$OUT/bonus_run.log" 2>&1
grep -A 7 "Output Data" "$OUT/bonus_run.log"

step "Bonus: plot"
plot process.py "$OUT/bonus_plot.png" > "$OUT/bonus_plot.log" 2>&1
grep "^\[" "$OUT/bonus_plot.log"

step "done"
