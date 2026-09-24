"""Label the simulator's CPI trace with source lines.

    python3 cpi.py program.lst sim_output.txt [--summary]

Default prints every instruction in execution order. --summary groups by
address instead (count and cycles per instruction), for looping programs.
"""
import sys
from collections import defaultdict

listing = {}
for line in open(sys.argv[1]):
    addr, _, text = line.rstrip("\n").split(" ", 2)
    listing[int(addr, 16)] = text

trace, regs, total = [], {}, None
for line in open(sys.argv[2]):
    parts = line.split()
    if not parts:
        continue
    if parts[0] == "CPI":
        trace.append((int(parts[1], 16), int(parts[2])))
    elif parts[0] == "REG":
        regs[parts[1]] = int(parts[2])
    elif parts[0] == "CYCLES":
        total = int(parts[1])
    elif parts[0] in ("TRAP", "STOP"):
        print(line.strip())

if "--summary" in sys.argv:
    stats = defaultdict(list)
    for addr, cycles in trace:
        stats[addr].append(cycles)
    print(f"{'addr':>8}  {'count':>6}  {'cycles':>9}  source")
    for addr in sorted(stats):
        c = stats[addr]
        cyc = f"{min(c)}" if min(c) == max(c) else f"{min(c)}-{max(c)}"
        print(f"{addr:08x}  {len(c):>6}  {cyc:>9}  {listing.get(addr, '?')}")
else:
    print(f"{'addr':>8}  {'cycles':>6}  source")
    for addr, cycles in trace:
        print(f"{addr:08x}  {cycles:>6}  {listing.get(addr, '?')}")

for name in ("t1", "t2", "t3"):
    if name in regs:
        print(f"{name} = {regs[name]}")
if total is not None:
    print(f"total cycles = {total}")
