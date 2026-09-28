`timescale 1ns / 1ps

module testbench;

    // Testbench signals
    reg clk;
    reg resetn;
    wire trap;

    // Signals for picorv32 to memory interface
    wire         mem_valid;
    wire         mem_instr;
    wire        mem_ready;
    wire [31:0]  mem_addr;
    wire [31:0]  mem_wdata;
    wire [ 3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    // Instantiate the picorv32 UUT
    picorv32 uut (
        .clk(clk),
        .resetn(resetn),
        .trap(trap),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    // Instantiate the memory module
    memory mem (
        .clk(clk),
        .reset(resetn), 
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns period (100 MHz)

    // Initial block for stimulus
    initial begin
        // Initialize signals
        clk = 0;
        resetn = 0;

        // Load memory data
        
        // Baseline ISA
        $readmemh("memory_data.mem", mem.memory_array);
        
        // Modified ISA
        //$readmemh("mod_memory.mem", mem.memory_array);
        
        mem.memory_array[20] = 20;
        mem.memory_array[21] = 24;
        
        #20;
        resetn = 1;
        #2000000;
        resetn = 0;
        #20;

        // Finish simulation after some time
        #1000;
        $finish;
    end

endmodule


module memory (
    input             clk,           // Clock signal
    input             reset,         // Reset signal

    // Interface with the core
    input             mem_valid,     // Indicates memory access is valid
    input             mem_instr,     // Instruction fetch (1) or data access (0)
    output reg        mem_ready,     // Memory is ready

    input [31:0]      mem_addr,      // Memory address
    input [31:0]      mem_wdata,     // Data to be written to memory
    input [ 3:0]      mem_wstrb,     // Write strobe (which bytes are valid for a write)
    output reg [31:0] mem_rdata      // Data read from memory
);

    // Define the base address offset
    localparam BASE_ADDR = 32'h4000_0000;

    // Define memory array (for simplicity, using a small size)
    reg [31:0] memory_array [0:255];  // 256 x 32-bit memory array

    // Internal signals to manage memory transactions
    reg [31:0] read_data;
    reg [31:0] shifted_mem_addr;
    
    reg [2:0] delay_counter;

    always @(posedge clk or posedge reset) begin
        if (!reset) begin
            // Reset the memory state
            mem_ready <= 1'b0;
            mem_rdata <= 32'b0;
            delay_counter <= 0;
        end else begin
            if (mem_valid) begin
                mem_ready <= 1'b0; // Indicate memory is ready for this transaction
                shifted_mem_addr = mem_addr - BASE_ADDR;
                
                if (mem_wstrb != 4'b0000) begin
                    // Write operation
                    if (mem_wstrb[0]) memory_array[shifted_mem_addr[31:2]][ 7: 0] <= mem_wdata[ 7: 0];
                    if (mem_wstrb[1]) memory_array[shifted_mem_addr[31:2]][15: 8] <= mem_wdata[15: 8];
                    if (mem_wstrb[2]) memory_array[shifted_mem_addr[31:2]][23:16] <= mem_wdata[23:16];
                    if (mem_wstrb[3]) memory_array[shifted_mem_addr[31:2]][31:24] <= mem_wdata[31:24];
                    mem_ready <= 1'b1;
                end else begin
                    // Read operation
                    read_data <= memory_array[shifted_mem_addr[31:2]];
                end
            end 
            else begin
                mem_ready <= 1'b0; // Memory is not ready if not valid
            end
        end
    end

    // Handle data output (for read operations)
    always @(posedge clk) begin
        if (mem_valid && mem_wstrb == 4'b0000) begin
            delay_counter <= delay_counter+1;
            if(delay_counter == 3) begin
                mem_rdata <= read_data;
                delay_counter <= 0;
                mem_ready <= 1'b1;
            end
        end
    end

endmodule
