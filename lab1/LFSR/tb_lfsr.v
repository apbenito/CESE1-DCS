`timescale 1ns / 1ps

module tb_lfsr;

    reg clk;
    reg reset;

    wire [5:0]  value_a, value_b, value_c;
    wire        rep_a,   rep_b,   rep_c;
    wire [31:0] dist_a,  dist_b,  dist_c;

    integer i;

    lfsr #(.SEED(6'b00_0000)) seed_a (
        .clk(clk), .reset(reset),
        .value(value_a), .repetition(rep_a), .distance(dist_a));

    lfsr #(.SEED(6'b01_1001)) seed_b (
        .clk(clk), .reset(reset),
        .value(value_b), .repetition(rep_b), .distance(dist_b));

    lfsr #(.SEED(6'b10_1001)) seed_c (
        .clk(clk), .reset(reset),
        .value(value_c), .repetition(rep_c), .distance(dist_c));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("lfsr.vcd");
        $dumpvars(0, tb_lfsr);

        reset = 1;  #20;
        reset = 0;

        // show the first part of each sequence
        $display("");
        $display("  step | 000000 | 011001 | 101001");
        $display("-------+--------+--------+-------");
        for (i = 0; i < 20; i = i + 1) begin
            $display("   %2d  | %b | %b | %b", i, value_a, value_b, value_c);
            #10;
        end

        // let them all run long enough to wrap
        #2000;

        $display("");
        $display("  seed   | repeated | repetition distance");
        $display("---------+----------+--------------------");
        $display("  000000 |    %b     | %0d", rep_a, dist_a);
        $display("  011001 |    %b     | %0d", rep_b, dist_b);
        $display("  101001 |    %b     | %0d", rep_c, dist_c);
        $display("");

        $finish;
    end

endmodule
