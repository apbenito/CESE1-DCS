"""Make the template's testbench.v runnable under Icarus Verilog.

    python3 ta_testbench.py <testbench.v> <out.v> [baseline|modified]

The template's memory module drives mem_ready from two always blocks on the
same clock edge. Vivado's simulator lets the second one win; Icarus doesn't,
and the core then waits for its first instruction forever. This writes a copy
with the two blocks merged in source order, so the second assignment always
wins, and selects the program the same way the manual does (only the chosen
$readmemh line is left active). The original file is left untouched.
"""
import re
import sys

src = open(sys.argv[1]).read().replace("\r", "")
program = sys.argv[3] if len(sys.argv) > 3 else "baseline"

race = ("    end\n\n    // Handle data output (for read operations)\n"
        "    always @(posedge clk) begin\n")
assert src.count(race) == 1, "memory module not in the expected shape"
src = src.replace(race, "        // (second always block merged here, in source order)\n")

# comment both $readmemh lines out, then turn the chosen one back on, so this
# works whichever program the testbench currently loads
src = re.sub(r'^(\s*)(?://\s*)?\$readmemh\("(memory_data|mod_memory)\.mem"', r'\1// $readmemh("\2.mem"', src, flags=re.M)
wanted = "mod_memory" if program == "modified" else "memory_data"
src = re.sub(r'^(\s*)//\s*\$readmemh\("' + wanted + r'\.mem"', r'\1$readmemh("' + wanted + '.mem"', src, flags=re.M)

open(sys.argv[2], "w").write(src)
