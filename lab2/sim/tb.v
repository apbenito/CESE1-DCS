`timescale 1ns / 1ps

// Standalone testbench for the template's PicoRV32, with the board's memory map:
//   0x4000_0000  instruction memory (the core starts here)
//   0x4200_0000  data memory
//
//   +code=<file>      program, loaded at 0x4000_0000
//   +idata=<file>     extra words for instruction memory (use @addr lines),
//                     e.g. the test values the manual's small programs read
//   +data=<file>      data memory image, loaded at 0x4200_0000
//   +maxcycles=<n>    stop after this many cycles
//   +stoppc=<hex>     stop once execution reaches this offset
//   +dump=<file>      write data memory to a file when finished
//   +vcd=<file>       write a waveform (only for short programs)
//
// Memory timing, chosen at compile time:
//   (default)     same as the template's testbench.v: a read answers once a
//                 delay counter reaches 3, a write answers on the next edge
//   -DFAST_MEM    zero wait states
//   -DSINGLE_PORT build the core with a single-port register file
//
// Every time an instruction starts, prints the offset and the number of cycles
// the previous instruction took ("CPI ...") for cpi.py to summarise.

module tb;

    reg clk = 0;
    reg resetn = 0;
    always #5 clk = ~clk;

    wire        mem_valid;
    wire        mem_instr;
    reg         mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [ 3:0] mem_wstrb;
    reg  [31:0] mem_rdata;
    wire        trap;

    // same configuration as the block design's picorv32 instance
    picorv32 #(
`ifdef SINGLE_PORT
        .ENABLE_REGS_DUALPORT(0),
`endif
        .ENABLE_MUL(1),
        .ENABLE_DIV(1)
    ) uut (
        .clk       (clk),
        .resetn    (resetn),
        .trap      (trap),
        .mem_valid (mem_valid),
        .mem_instr (mem_instr),
        .mem_ready (mem_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata)
    );

    reg [31:0] imem [0:16383];     // 0x4000_0000
    reg [31:0] dmem [0:16383];     // 0x4200_0000

    wire        in_dmem = mem_addr[25];
    wire [13:0] index   = mem_addr[15:2];
    wire [31:0] word    = in_dmem ? dmem[index] : imem[index];

    task write_word;
        begin
            if (in_dmem) begin
                if (mem_wstrb[0]) dmem[index][ 7: 0] <= mem_wdata[ 7: 0];
                if (mem_wstrb[1]) dmem[index][15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) dmem[index][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) dmem[index][31:24] <= mem_wdata[31:24];
            end else begin
                if (mem_wstrb[0]) imem[index][ 7: 0] <= mem_wdata[ 7: 0];
                if (mem_wstrb[1]) imem[index][15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) imem[index][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) imem[index][31:24] <= mem_wdata[31:24];
            end
        end
    endtask

`ifdef FAST_MEM
    // zero wait states: memory answers in the same cycle it is asked
    always @* begin
        mem_ready = mem_valid;
        mem_rdata = word;
    end
    always @(posedge clk)
        if (mem_valid && mem_wstrb) write_word;
`else
    // Same timing as the template's memory module. The template drives
    // mem_ready from two always blocks on the same edge; here they are one
    // block in the same order, so the later assignment reliably wins -- the
    // behaviour Vivado's simulator gives the original.
    reg [2:0]  delay_counter = 0;
    reg [31:0] read_data;
    always @(posedge clk) begin
        if (mem_valid) begin
            mem_ready <= 1'b0;
            if (mem_wstrb != 4'b0000) begin
                write_word;
                mem_ready <= 1'b1;
            end else
                read_data <= word;
        end else
            mem_ready <= 1'b0;

        if (mem_valid && mem_wstrb == 4'b0000) begin
            delay_counter <= delay_counter + 1;
            if (delay_counter == 3) begin
                mem_rdata <= read_data;
                delay_counter <= 0;
                mem_ready <= 1'b1;
            end
        end
    end
`endif

    // ---- waveform ----------------------------------------------------------
    // Registers live in an array, which Icarus doesn't dump, so the ones the
    // manual asks about get their own names. opcode and instr show which
    // instruction is executing, like the OPCODE signal in Vivado.
    wire [31:0] t0     = uut.cpuregs[5];
    wire [31:0] t1     = uut.cpuregs[6];
    wire [31:0] t2     = uut.cpuregs[7];
    wire [31:0] t3     = uut.cpuregs[28];
    wire [31:0] opcode = uut.dbg_insn_opcode;
    wire [63:0] instr  = uut.dbg_ascii_instr;

    reg [1023:0] vcd_file;
    initial
        if ($value$plusargs("vcd=%s", vcd_file)) begin
            $dumpfile(vcd_file);
            $dumpvars(1, tb);                 // this module's signals only
            $dumpvars(1, uut);                // plus the core's top level
        end

    // ---- cycles per instruction ------------------------------------------
    integer cycle = 0;
    integer last_start = -1;
    reg [31:0] last_addr;
    wire [31:0] pc_offset = uut.next_pc & 32'h00FF_FFFF;

    always @(posedge clk) begin
        cycle <= cycle + 1;
        if (resetn && uut.launch_next_insn) begin
            if (last_start >= 0)
                $display("CPI %08x %0d", last_addr, cycle - last_start);
            last_start <= cycle;
            last_addr  <= pc_offset;
        end
    end

    // ---- run control -----------------------------------------------------
    reg [1023:0] code_file, idata_file, data_file, dump_file;
    integer max_cycles;
    reg [31:0] stop_pc;
    reg has_stop_pc;

    initial begin
        if (!$value$plusargs("code=%s", code_file)) $fatal(1, "missing +code=<file>");
        if (!$value$plusargs("maxcycles=%d", max_cycles)) max_cycles = 200;
        has_stop_pc = $value$plusargs("stoppc=%h", stop_pc);

        $readmemh(code_file, imem);
        if ($value$plusargs("idata=%s", idata_file)) $readmemh(idata_file, imem);
        if ($value$plusargs("data=%s", data_file))   $readmemh(data_file, dmem);

        repeat (5) @(posedge clk);
        resetn <= 1;

        repeat (max_cycles) @(posedge clk);
        $display("STOP max cycles reached");
        finish;
    end

    always @(posedge clk) begin
        if (trap) begin
            $display("TRAP at cycle %0d", cycle);
            finish;
        end
        if (has_stop_pc && resetn && uut.launch_next_insn && pc_offset == stop_pc) begin
            repeat (2) @(posedge clk);
            finish;
        end
    end

    task finish;
        begin
            if ($value$plusargs("dump=%s", dump_file))
                $writememh(dump_file, dmem);
            $display("REG t1 %0d", uut.cpuregs[6]);
            $display("REG t2 %0d", uut.cpuregs[7]);
            $display("REG t3 %0d", uut.cpuregs[28]);
            $display("CYCLES %0d", cycle);
            $finish;
        end
    endtask

endmodule
