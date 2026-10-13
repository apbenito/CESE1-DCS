"""Builds Lab3_Report.pdf from the measurements in ../results and the code in
../cese4130-lab4 and ../gvsoc/modified.

    python3 make_report.py

Needs PyMuPDF and matplotlib (only for its bundled DejaVu fonts).
"""
import html
import os
import re

import matplotlib
import numpy as np
import pymupdf

HERE = os.path.dirname(os.path.abspath(__file__))
LAB = os.path.dirname(HERE)
RES = os.path.join(LAB, 'results')
SRC = os.path.join(LAB, 'cese4130-lab4')
OUT = os.path.join(LAB, 'Lab3_Report.pdf')
FONTS = os.path.join(os.path.dirname(matplotlib.__file__), 'mpl-data', 'fonts', 'ttf')

FOOTER = 'CESE4130 Lab 3 – GVSoC: LWI instruction & multi-core processing'
PAGE = pymupdf.paper_rect('a4')
BODY = PAGE + (56, 56, -56, -64)

# ---------------------------------------------------------------- measurements

def read(name):
    with open(os.path.join(RES, name)) as f:
        return f.read()

def cycles(log):
    return int(float(re.search(r"occurrences: ([\d.]+)", read(log)).group(1)))

def lists(log):
    return [[int(float(x)) for x in m.split(',')]
            for m in re.findall(r'^\[([\d., ]+)\]$', read(log), re.M)]

base, modified = cycles('p1_baseline.log'), cycles('p1_modified.log')
arr1, arr2 = lists('p2_diff.log')
arr3 = lists('p2_plot_array3.log')[0]
bonus = lists('bonus_plot.log')[0]
assert lists('p2_plot_array1.log')[0] == arr1
assert 'LWI implemented correctly' in read('p1_check_data.txt')
assert 'All tests were passed!!' in read('p2_verify.log')
bins = [int(b) for b in re.findall(r'Bin\[\d\]: (\d+)', read('bonus_run.log'))]

cores = list(range(1, 17))
speedup = [arr1[0] / t for t in arr1]
diff = [a - b for a, b in zip(arr1, arr2)]
best3 = cores[arr3.index(min(arr3))]

def amdahl_p(n):
    s = arr1[0] / arr1[n - 1]
    return (1 - 1 / s) / (1 - 1 / n)

# Least-squares fit of T(N) = T_serial + T_parallel / N over all 16 points
(t_ser, t_par), *_ = np.linalg.lstsq(np.vstack([np.ones(16), 1 / np.array(cores)]).T,
                                     np.array(arr1, float), rcond=None)
p_fit = t_par / (t_ser + t_par)
p16 = amdahl_p(16)

# Core 0 time split, measured from the host/insn trace (see README):
# counting phase, sync wait and printf for 1 and 16 cores
TRACE = {1: (32188, 91, 2885), 16: (2105, 800, 2885)}
PRINTF_DIFF = 2885 - 2680

# ---------------------------------------------------------------- code excerpts

def excerpt(path, start, end, dedent=0):
    lines = open(path).read().splitlines()
    i = next(k for k, l in enumerate(lines) if start in l)
    j = next(k for k in range(i, len(lines)) if end in lines[k])
    return '\n'.join(l[dedent:] for l in lines[i:j + 1])

gen_line = excerpt(os.path.join(LAB, 'gvsoc/modified/isa_riscv_gen.py'),
                   "Instr('lwi'", "Instr('lwi'", 12)
lwi_exec = excerpt(os.path.join(LAB, 'gvsoc/modified/rv32i.hpp'),
                   '// Load Word Indexed', 'return iss_insn_next')
lwi_exec += '\n}'
system = excerpt(os.path.join(SRC, 'Part2/my_system.py'),
                 '# Global memory shared', 'loader.o_ENTRY', 8)
main_p2 = excerpt(os.path.join(SRC, 'Part2/main.c'),
                  'if (core_id >= NUM_CORES)', '*sync = 0;', 4)
main_bonus = excerpt(os.path.join(SRC, 'bonus/main.c'),
                     'int arr_size_per_core', 'printf("Output Data', 4)

# ---------------------------------------------------------------- HTML helpers

def n(x):
    return f'{x:,}'

def code(s):
    return f'<pre>{html.escape(s)}</pre>'

def table(head, rows, highlight=(), widths=None):
    out = ['<table>']
    widths = widths or [None] * len(head)
    out.append('<tr>' + ''.join(f'<th style="width: {w}%">{h}</th>' if w else f'<th>{h}</th>'
                                for h, w in zip(head, widths)) + '</tr>')
    for k, r in enumerate(rows):
        cls = 'hl' if k in highlight else ('alt' if k % 2 else '')
        out.append(f'<tr class="{cls}">' + ''.join(f'<td>{c}</td>' for c in r) + '</tr>')
    out.append('</table>')
    return ''.join(out)

def callout(s):
    return f'<table class="callout"><tr><td class="bar"></td><td class="msg">{s}</td></tr></table>'

def figure(img, caption, width=300):
    return (f'<p class="fig"><img src="{img}" width="{width}"/></p>'
            f'<p class="caption">{caption}</p>')

CSS = """
@font-face { font-family: sans; src: url(DejaVuSans.ttf); }
@font-face { font-family: sans; src: url(DejaVuSans-Bold.ttf); font-weight: bold; }
@font-face { font-family: mono; src: url(DejaVuSansMono.ttf); }
* { font-family: sans; color: #1f2937; line-height: 1.45; }
body, p, li { font-size: 9.6px; }
h1 { font-size: 15px; color: #2f5d8a; font-weight: bold; margin: 0 0 8px 0; }
h2 { font-size: 11.5px; font-weight: bold; margin: 10px 0 4px 0; }
h3 { font-size: 9.6px; font-weight: bold; margin: 8px 0 3px 0; }
p { margin: 0 0 6px 0; }
code { font-family: mono; font-size: 8.2px; }
pre { font-family: mono; font-size: 7.6px; }
td code { font-size: 8px; }
pre { background-color: #f3f4f6; border: 0.5px solid #e5e7eb; padding: 5px 6px; margin: 2px 0 6px 0; line-height: 1.3; }
table { border-collapse: collapse; width: 100%; margin: 2px 0 6px 0; }
th { background-color: #2f5d89; color: #ffffff; font-weight: bold; font-size: 8.8px; text-align: left; padding: 3px 6px; border: 0.5px solid #2f5d89; }
td { font-size: 8.8px; padding: 3px 6px; border: 0.5px solid #e5e7eb; }
tr.alt td { background-color: #f8f9fb; }
tr.hl td { background-color: #e6f4e9; }
table.callout td { border: none; padding: 5px 7px; }
td.bar { background-color: #2f5d8a; width: 3px; padding: 0; }
td.msg { background-color: #eaf0f8; }
p.fig { text-align: center; margin: 6px 0 2px 0; }
p.caption { text-align: center; font-size: 8.4px; color: #4b5563; margin: 0 0 8px 0; }
p.note { font-size: 8.4px; color: #4b5563; }
p.title { text-align: center; font-size: 24px; font-weight: bold; color: #2f5d8a; margin: 150px 0 14px 0; }
p.sub { text-align: center; font-size: 11px; color: #4b5563; margin: 0 0 4px 0; }
"""

# ---------------------------------------------------------------- sections

cover = f"""
<p class="title">Lab 3 Report</p>
<p class="sub">Simulation of a RISC-V based SoC using GVSoC</p>
<p class="sub">Digital Computing Systems (CESE4130) · 2026/27</p>
<p style="margin-top: 40px"></p>
""" + table(['Part', 'Result'], [
    ['1 – LWI instruction', f'Implemented; check prints “LWI implemented correctly”. '
     f'{n(base)} → {n(modified)} cycles (−{n(base - modified)}).'],
    ['2 – 16-core SoC', '16 cores + global memory; parallel count of 3s. '
     '<b>make verify: all 48 tests passed.</b>'],
    ['Profiling', f'Array-1: {n(arr1[0])} → {n(arr1[-1])} cycles ({speedup[-1]:.2f}× on 16 cores); '
     f'≈ {p_fit * 100:.0f}% parallelizable. Array-3: best on {best3} cores.'],
    ['Bonus – histogram', f'Correct on 1–16 cores ({"/".join(map(str, bins))}); '
     f'{n(bonus[0])} → {n(bonus[-1])} cycles.'],
], widths=[25, 75])

part1 = f"""
<h1>Part 1 – Load Word Indexed (LWI)</h1>
<h2>1a. Baseline</h2>
<p>In <code>img-blur-baseline</code>, <code>make gvsoc all count-cycles</code> gives
<b>{n(base)} cycles</b> for the image-blur kernel with the original ISA.</p>

<h2>1b. Adding the instruction</h2>
<p><b>Encoding</b> (R-type): funct7 = <code>0000000</code>, funct3 = <code>010</code>,
opcode = <code>0101011</code> (custom-1). Semantics: <b>rd = mem[rs1 + rs2]</b>
(rs1 = base, rs2 = index).</p>
<p><b>Decoder</b> – <code>core/models/cpu/iss/isa_gen/isa_riscv_gen.py</code>, class
<code>Rv32i</code>, next to <code>lw</code>, without a fast handler:</p>
{code(gen_line)}
<p>It has two source registers like <code>add</code>, so it uses <code>Format_R</code>
(rd = output 0, rs1 = input 0, rs2 = input 1), not the L format whose second operand is an
immediate. The <code>load</code> tag gives it the timing of a load. Opcode 0101011 is only used
by the CORE-V / PULP extensions, which an <code>rv64imafdc</code> core does not include.</p>
<p><b>Execution</b> – <code>core/models/cpu/iss/include/isa/rv32i.hpp</code>, after
<code>lw_exec</code>: the <code>lw</code> load path, with the address computed as
<code>add</code> would:</p>
{code(lwi_exec)}
<p><b>Assembly:</b> the provided <code>.s</code> files already contain the instruction as
<code>.word 0x00F727AB</code> = rd a5, rs1 a4 (base), rs2 a5 (index), 9 times per output
pixel. It replaces <code>add a5,a4,a5</code> + <code>lw a5,0(a5)</code>; the index was
already scaled by 4 by the preceding <code>slli</code>.</p>

<!--PAGE-->
<h2>1c. Verification and modified-ISA run</h2>
<p><code>check-image-blur-modified</code>: <code>make gvsoc all run image</code> prints
<b>“LWI implemented correctly”</b> and produces the blurred image below.
<code>img-blur-modified</code>: <code>make gvsoc all count-cycles</code> gives
<b>{n(modified)} cycles</b>.</p>
<table><tr>
<td style="border: none; text-align: center"><img src="original.png" width="120"/></td>
<td style="border: none; text-align: center"><img src="output_image.png" width="120"/></td>
</tr><tr>
<td style="border: none; text-align: center"><span class="caption">Input image</span></td>
<td style="border: none; text-align: center"><span class="caption">Output of the LWI check program (blurred)</span></td>
</tr></table>
""" + table(['Version', 'Cycles', 'Δ vs baseline'], [
    ['Original ISA (baseline)', n(base), '–'],
    ['Modified ISA (lwi)', n(modified),
     f'−{n(base - modified)} ({(modified - base) / base * 100:.1f}%)'],
], widths=[50, 25, 25]) + f"""
<h3>Question – difference in cycles?</h3>
<p>{n(base)} − {n(modified)} = <b>{n(base - modified)} cycles</b>
(≈{(base - modified) / base * 100:.1f}% fewer). The image has 32 × 32 = 1,024 output pixels
and the 3×3 blur does 9 loads per pixel: 1,024 × 9 = 9,216. Each <code>lwi</code> replaces
an <code>add</code> + <code>lw</code> pair, so every load saves exactly one instruction, one
cycle. The memory access itself is unchanged, and most of the loop is still index
arithmetic, so the overall gain is modest.</p>
"""

part2 = f"""
<h1>Part 2 – Multi-core RISC-V SoC</h1>
<h2>2a. Baseline</h2>
<p>With the template (1 core, Array-1), <code>make gvsoc all run</code> prints
<code>The total 3s are:56</code>.</p>

<h2>2b/2c. Adding 16 cores and the global memory – my_system.py</h2>
{code(system)}
<p>Core 0 keeps the name <code>host</code> because the profiling scripts trace
<code>host/insn</code>. Every core gets a distinct <code>core_id</code> (its
<code>mhartid</code>), its fetch/data/debug ports on the interconnect, and is started by the
same loader. <code>Global_Mem</code> is mapped at <b>0x20000000</b>, size <b>0x1000</b>;
<code>rm_base</code> makes the component see offsets: 0x0 = <code>sync_reg</code>,
0x4 + 4·i = <code>count[i]</code>, all initialised to −1. <code>crt0.S</code> already gives
each hart its own stack.</p>

<h2>2d. Parallelizing main.c</h2>
<ul>
<li>Unused cores (core_id ≥ NUM_CORES) write 0 to their counter and pause.</li>
<li>Each core counts a contiguous slice of ceil(arr_size / NUM_CORES) elements; the last
slices may be shorter or empty, and the index check stops at the end of the array.</li>
<li>The template read <code>arr[start_index + i]</code> although <code>i</code> already starts
at <code>start_index</code>; it now reads <code>arr[i]</code>. Its “protection”
<code>if (arr[i] &gt; arr_size)</code> compared an element <i>value</i> with the size; it is
replaced by a real bound on the index.</li>
<li>Each core stores its count; cores 1–15 pause; core 0 waits in
<code>sync_cores()</code> until no counter is −1, sums, prints and writes
<code>sync = 0</code> to release the others.</li>
</ul>
<!--PAGE-->
{code(main_p2)}
<p><b>Verification:</b> <code>make gvsoc verify</code> → <b>“All tests were passed!!”</b>
(3 arrays × 1–16 cores = 48 configurations).</p>
"""

rows = []
for k, c in enumerate(cores):
    rows.append([str(c), n(arr1[k]), f'{speedup[k]:.2f}×', n(arr2[k]), str(diff[k]), n(arr3[k])])

profiling = f"""
<h1>Verification &amp; Profiling</h1>
<p>Measured cycles (core 0, first to last instruction in main):</p>
""" + table(['Cores', 'Array-1', 'Speedup', 'Array-2', 'Δ (1−2)', 'Array-3'], rows,
            highlight=[best3 - 1], widths=[12, 18, 16, 18, 16, 20]) + f"""
<p class="note">Highlighted row: {best3} cores = minimum for Array-3.</p>
<h2>Array-1 (make plot)</h2>
{figure('p2_plot_array1.png', 'Execution cycles vs number of cores – Array-1', 280)}
<!--PAGE-->
<h3>Q1. Why is the graph non-linear?</h3>
<p>Only the counting loop is divided between the cores, so only that part shrinks as 1/N.
The rest is serial on core 0: start-up, the final sum and above all the <code>printf</code>,
which alone takes {n(TRACE[1][2])} cycles (measured in the trace). That is 8% of the 1-core
time but half of the 16-core time. Some overhead even grows with N: <code>sync_cores()</code>
and the final sum loop over NUM_CORES (core 0 spends {TRACE[1][1]} cycles in sync on 1 core,
{TRACE[16][1]} on 16), and core 0 has to wait for the slowest slice. So
T(N) ≈ T<sub>serial</sub> + T<sub>parallel</sub>/N + c·N: a hyperbola that flattens out
instead of a straight line.</p>
<h3>Q2. Amdahl's law – parallel fraction p</h3>
<p>Speedup at 16 cores S = {n(arr1[0])} / {n(arr1[-1])} = {speedup[-1]:.2f}.
Solving 1/S = (1 − p) + p/16:</p>
{code(f'p = (1 − 1/S) / (1 − 1/16) = (1 − {1 / speedup[-1]:.3f}) / 0.9375 ≈ {p16:.3f}')}
""" + table(['Cores used', 'Speedup S', 'p'], [
    [str(c), f'{speedup[c - 1]:.2f}', f'{amdahl_p(c):.3f}'] for c in (2, 4, 8, 16)
] + [['Fit over all 16 points', '–', f'{p_fit:.3f}']], highlight=[3], widths=[40, 30, 30]) + callout(
    f'<b>≈ {p_fit * 100:.0f}% of the program is parallelizable</b> (0.89–0.91 depending on the '
    f'points used). The trace agrees: on 1 core the counting phase is {n(TRACE[1][0])} of '
    f'{n(arr1[0])} cycles (≈{TRACE[1][0] / arr1[0] * 100:.0f}%). The estimate falls slightly with N '
    f'because the synchronisation overhead grows with N, which Amdahl\'s law does not model.') + f"""
<h3>Q3. Trend beyond 16 cores?</h3>
<p>The curve keeps flattening towards the serial floor (≈ {n(int(round(t_ser, -2)))} cycles from the
fit); the speedup is capped at 1/(1 − p) ≈ {1 / (1 - p_fit):.1f}×. Before reaching it, each core
gets almost no work (1000/N elements) while the sync and sum loops keep growing with N, so the
curve reaches a minimum and rises again, as Array-3 already does. The hardware would also need
more than the 16 counters in the global memory.</p>
"""

diff_arr3 = f"""
<h1>Array-1 vs Array-2 (make diff)</h1>
{figure('p2_diff.png', 'Cycle difference Array-1 − Array-2 vs number of cores')}
<h3>Q1. Difference in execution between Array-1 and Array-2?</h3>
<p>Same size, same loop. For every element equal to 3, Array-1 executes the extra
<code>local_counter++</code> (lw / addiw / sw) instead of branching past it; Array-2 has no 3s.
The final <code>printf</code> also prints “56” instead of “0”, one more digit to convert.
Splitting core 0's trace shows both parts:</p>
""" + table(['', 'Counting phase', 'printf → end', 'Total Δ'], [
    ['1 core', f'+{diff[0] - PRINTF_DIFF} (56 threes × 2 cycles)', f'+{PRINTF_DIFF}', str(diff[0])],
    ['16 cores', '+6 (core 0: 3 threes; busiest slice: 7)', f'+{PRINTF_DIFF}', str(diff[-1])],
], widths=[16, 44, 20, 20]) + f"""
<h3>Q2. Why is the difference decreasing? Will it reach zero?</h3>
<p>The 3s are spread over the cores, which count in parallel, and core 0 only waits for the
slowest one. So only the 3s in the busiest slice are on the critical path: 56 on 1 core, 34 on
2, 19 on 4, 11 on 8, 7 on 16. <b>It will not reach zero</b>: it levels off at about
{diff[-1]} cycles from 12 cores onward. {PRINTF_DIFF} of those come from the <code>printf</code>,
which does not depend on the core count, and a slice that still contains 3s keeps the rest
above zero.</p>
<h3>Q3. What if Array-1 had more 3s?</h3>
<p>Each extra 3 in the busiest slice costs about 2 cycles. On 1 core the difference grows
linearly with the number of 3s; with N cores each extra 3 adds only ≈1/N of that, so the curve
starts higher but still falls towards the <code>printf</code> floor. A count with one more digit
(≥ 100) raises that floor by roughly another 200 cycles, and clustered 3s (load imbalance) make
the difference shrink more slowly than evenly spread ones.</p>

<!--PAGE-->
<h1>Array-3 (make plot)</h1>
{figure('p2_plot_array3.png', 'Execution cycles vs number of cores – Array-3 (36 elements)')}
<h3>Q1. Why is the trend different?</h3>
<p>With only 36 elements the divisible work is about 1,100 cycles, small next to the fixed
serial part and the ≈40 cycles of sync and summing added per extra core. Up to 4 cores the
counting shrinks faster than the overhead grows; after that each added core saves 2–3 elements
but still costs its sync and sum, so the curve rises roughly linearly. The zigzag comes from 36
not dividing evenly by N.</p>
<h3>Q2. Ideal number of cores for Array-3: {best3}</h3>
<p>Minimum of {n(min(arr3))} cycles (9 elements per core), a speedup of only
{arr3[0] / min(arr3):.2f}×; 5–6 cores are within about 1%. With T(N) ≈ T<sub>s</sub> + W/N + c·N,
W ≈ 1,100 and c ≈ 40, the optimum N = √(W/c) ≈ 5 agrees.</p>
"""

bonus_sec = f"""
<h1>Bonus – Character histogram</h1>
<ul>
<li>Copied <code>Part2/my_system.py</code> to <code>bonus/my_system.py</code> (the bonus global
memory holds 16 × 7 = 112 counters).</li>
<li>Each core takes ceil(arr_size / NUM_CORES) characters (CUDA-grid style); the index check
handles the shorter last slice.</li>
<li>Each core writes its 7 bins to <code>global_mem[core_id*NUM_BINS + bin]</code>; unused cores
clear only their own 7 words (<code>global_mem[core_id]</code> would land in a used core's
bins) and pause.</li>
<li>Core 0 synchronises over NUM_CORES·NUM_BINS words, sums every bin over the used cores and
prints the histogram. The big test array is active, as required for sign-off.</li>
</ul>
{code(main_bonus)}
""" + table(['Bin'] + [str(k) for k in range(7)],
            [['Output (1–16 cores)'] + [str(b) for b in bins]], widths=[30] + [10] * 7) + f"""
<p>Checked for every core count from 1 to 16; all match the expected output.</p>
<!--PAGE-->
{figure('bonus_plot.png', f'Bonus – execution cycles vs number of cores ({n(bonus[0])} → {n(bonus[-1])}, {bonus[0] / bonus[-1]:.1f}× on 16 cores)', 260)}
<h2>Files changed</h2>
""" + table(['File', 'Change'], [
    ['core/models/cpu/iss/isa_gen/isa_riscv_gen.py', 'lwi decoder entry in Rv32i'],
    ['core/models/cpu/iss/include/isa/rv32i.hpp', 'lwi_exec'],
    ['cese4130-lab4/Part2/my_system.py', '16 cores + global memory'],
    ['cese4130-lab4/Part2/main.c', 'Parallel count of 3s'],
    ['cese4130-lab4/bonus/my_system.py', 'Copy of Part2 system'],
    ['cese4130-lab4/bonus/main.c', 'Parallel histogram, big array active'],
], widths=[58, 42])

# ---------------------------------------------------------------- layout

def build():
    archive = pymupdf.Archive()
    archive.add(pymupdf.Archive(FONTS))
    archive.add(pymupdf.Archive(RES))
    writer = pymupdf.DocumentWriter(OUT)
    # One Story per page: a Story that spans pages redraws table and <pre>
    # backgrounds on the next page, so pages are split by hand at <!--PAGE-->.
    sections = (cover, part1, part2, profiling, diff_arr3, bonus_sec)
    pages = [pg for sec in sections for pg in sec.split('<!--PAGE-->')]
    for k, pg in enumerate(pages):
        story = pymupdf.Story(html=pg, user_css=CSS, archive=archive)
        dev = writer.begin_page(PAGE)
        more, _ = story.place(BODY)
        story.draw(dev)
        writer.end_page()
        if more:
            raise SystemExit(f'page {k + 1} overflows: {pg.strip()[:60]!r}')
    writer.close()

    # Running footer, as in the reference layout
    doc = pymupdf.open(OUT)
    font = pymupdf.Font(fontfile=os.path.join(FONTS, 'DejaVuSans.ttf'))
    for i, page in enumerate(doc):
        y = PAGE.height - 40
        page.draw_line((56, y - 9), (PAGE.width - 56, y - 9), color=(0.75, 0.82, 0.9), width=0.6)
        tw = pymupdf.TextWriter(page.rect, color=(0x6b / 255, 0x72 / 255, 0x80 / 255))
        tw.append((56, y), FOOTER, font=font, fontsize=7.5)
        label = f'Page {i + 1}'
        tw.append((PAGE.width - 56 - font.text_length(label, 7.5), y), label, font=font, fontsize=7.5)
        tw.write_text(page)
    doc.set_metadata({'title': 'CESE4130 Lab 3 Report', 'author': 'Lab 3'})
    # Each page's Story embeds the full fonts again; subsetting and garbage
    # collection merge them, taking the file from ~12 MB to a few hundred KB.
    doc.subset_fonts()
    data = doc.tobytes(garbage=4, deflate=True)
    pages = len(doc)
    doc.close()
    with open(OUT, 'wb') as f:
        f.write(data)
    print(OUT, pages, 'pages')


if __name__ == '__main__':
    build()
