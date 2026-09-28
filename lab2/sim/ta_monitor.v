`timescale 1ns / 1ps

// Runs alongside the template's testbench without changing it: writes a
// waveform with the registers the manual asks about, prints cycles per
// instruction for cpi.py, and stops once the program has reached its loop
// (the testbench itself would run for 2 ms).
module ta_monitor;
    wire [31:0] t0     = testbench.uut.cpuregs[5];
    wire [31:0] t1     = testbench.uut.cpuregs[6];
    wire [31:0] t2     = testbench.uut.cpuregs[7];
    wire [31:0] t3     = testbench.uut.cpuregs[28];
    wire [31:0] opcode = testbench.uut.dbg_insn_opcode;
    wire [63:0] instr  = testbench.uut.dbg_ascii_instr;

    reg [1023:0] vcd_file;
    initial
        if ($value$plusargs("vcd=%s", vcd_file)) begin
            $dumpfile(vcd_file);
            $dumpvars(1, ta_monitor);
            $dumpvars(1, testbench);
            $dumpvars(1, testbench.uut);
        end

    integer cycle = 0, last_start = -1;
    reg [31:0] last_addr;
    always @(posedge testbench.clk) begin
        cycle <= cycle + 1;
        if (testbench.resetn && testbench.uut.launch_next_insn) begin
            if (last_start >= 0)
                $display("CPI %08x %0d", last_addr, cycle - last_start);
            last_start <= cycle;
            last_addr  <= testbench.uut.next_pc & 32'h00FF_FFFF;
        end
        if (testbench.trap) begin
            $display("TRAP at cycle %0d", cycle);
            done;
        end
        if (cycle == 150) done;
    end

    task done;
        begin
            $display("REG t1 %0d", t1);
            $display("REG t2 %0d", t2);
            $display("REG t3 %0d", t3);
            $finish;
        end
    endtask
endmodule
