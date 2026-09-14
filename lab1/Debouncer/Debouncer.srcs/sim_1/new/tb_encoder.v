`timescale 1ns / 1ps

module tb_encoder;

    reg        clk;
    reg        reset;
    reg        A;
    reg        B;
    wire [3:0] EncOut;

    integer i;

    encoder uut (
        .reset(reset),
        .clk(clk),
        .A(A),
        .B(B),
        .EncOut(EncOut)
    );

    initial begin
        clk = 0;
        forever #4 clk = ~clk;      // 125 MHz -> 8 ns period
    end

    // hold the button for a few cycles, like a real press
    task press_A;
        begin
            A = 1;  #24;
            A = 0;  #24;
        end
    endtask

    task press_B;
        begin
            B = 1;  #24;
            B = 0;  #24;
        end
    endtask

    initial begin
        $dumpfile("encoder.vcd");
        $dumpvars(0, tb_encoder);

        A = 0;
        B = 0;
        reset = 1;  #40;
        reset = 0;  #16;

        $display("");
        $display(" count | gray");
        $display("-------+------");
        $display("   %2d  | %b", uut.count, EncOut);

        // walk the whole range so the gray sequence is visible
        for (i = 0; i < 15; i = i + 1) begin
            press_A;
            $display("   %2d  | %b", uut.count, EncOut);
        end

        // and back down a few
        $display("");
        press_B;
        $display("   %2d  | %b   (after one B press)", uut.count, EncOut);

        reset = 1;  #40;
        $display("   %2d  | %b   (after reset)", uut.count, EncOut);
        $display("");

        $finish;
    end

endmodule
