`timescale 1ns / 1ps

// Standalone testbench for the modified PicoRV32.
//
//   +code=<file>      instruction memory image, loaded at 0x0000_0000
//   +data=<file>      data memory image, loaded at 0x4xxx_xxxx
//   +maxcycles=<n>    stop after this many cycles
//   +stopaddr=<hex>   stop once the program writes to this address
//   +stoppc=<hex>     stop once execution reaches this address
//
// Build options: -DFAST_MEM for zero-wait memory (default is one cycle late),
// -DSINGLE_PORT for a single-port register file.
//
// Every time an instruction starts, prints the address and the number of
// cycles the previous instruction took ("CPI ...") for cpi.py to summarise.

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

    // two separate arrays: code at 0x0000_0000, data at 0x4xxx_xxxx
    reg [31:0] code [0:16383];
    reg [31:0] data [0:16383];

    wire        is_data = mem_addr[30];
    wire [13:0] index   = mem_addr[15:2];

`ifdef FAST_MEM
    // zero wait states: memory answers in the same cycle it is asked
    always @* begin
        mem_ready = mem_valid;
        mem_rdata = is_data ? data[index] : code[index];
    end
    always @(posedge clk) begin
        if (mem_valid && is_data) begin
            if (mem_wstrb[0]) data[index][ 7: 0] <= mem_wdata[ 7: 0];
            if (mem_wstrb[1]) data[index][15: 8] <= mem_wdata[15: 8];
            if (mem_wstrb[2]) data[index][23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3]) data[index][31:24] <= mem_wdata[31:24];
        end
    end
`else
    // one cycle latency, same as the reference testbench_ez.v upstream
    always @(posedge clk) begin
        mem_ready <= 0;
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1;
            mem_rdata <= is_data ? data[index] : code[index];
            if (is_data) begin
                if (mem_wstrb[0]) data[index][ 7: 0] <= mem_wdata[ 7: 0];
                if (mem_wstrb[1]) data[index][15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) data[index][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) data[index][31:24] <= mem_wdata[31:24];
            end
        end
    end
`endif

    // ---- cycles per instruction ------------------------------------------
    integer cycle = 0;
    integer last_start = -1;
    reg [31:0] last_addr;

    always @(posedge clk) begin
        cycle <= cycle + 1;
        if (resetn && uut.launch_next_insn) begin
            if (last_start >= 0)
                $display("CPI %08x %0d", last_addr, cycle - last_start);
            last_start <= cycle;
            last_addr  <= uut.next_pc;
        end
    end

    // ---- run control -----------------------------------------------------
    reg [1023:0] code_file, data_file;
    integer max_cycles;
    reg [31:0] stop_addr, stop_pc;
    reg has_stop, has_stop_pc;

    initial begin
        if (!$value$plusargs("code=%s", code_file)) $fatal(1, "missing +code=<file>");
        if (!$value$plusargs("data=%s", data_file)) $fatal(1, "missing +data=<file>");
        if (!$value$plusargs("maxcycles=%d", max_cycles)) max_cycles = 200;
        has_stop    = $value$plusargs("stopaddr=%h", stop_addr);
        has_stop_pc = $value$plusargs("stoppc=%h", stop_pc);

        $readmemh(code_file, code);
        $readmemh(data_file, data);

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
        if (has_stop_pc && resetn && uut.launch_next_insn && uut.next_pc == stop_pc) begin
            repeat (2) @(posedge clk);
            finish;
        end
        if (has_stop && mem_valid && mem_ready && |mem_wstrb && mem_addr == stop_addr) begin
            repeat (2) @(posedge clk);
            finish;
        end
    end

    reg [1023:0] dump_file;

    task finish;
        begin
            if ($value$plusargs("dump=%s", dump_file))
                $writememh(dump_file, data);
            $display("REG t1 %0d", uut.cpuregs[6]);
            $display("REG t2 %0d", uut.cpuregs[7]);
            $display("REG t3 %0d", uut.cpuregs[28]);
            $display("CYCLES %0d", cycle);
            $finish;
        end
    endtask

endmodule
