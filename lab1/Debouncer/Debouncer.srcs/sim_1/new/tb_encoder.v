`timescale 1ns / 1ps

module tb_encoder;

    reg        clk;
    reg        reset;
    reg        A;
    reg        B;
    wire [3:0] EncOut;

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

        press_A;  press_A;  press_A;   // count up to 3
        press_B;                       // back down to 2
        press_B;  press_B;             // down to 0
        press_B;                       // underflow to 15
        press_A;                       // overflow back to 0

        reset = 1;  #40;               // reset clears the count

        $finish;
    end

    initial
        $monitor("t=%4d  reset=%b  A=%b  B=%b  EncOut=%b (%2d)",
                 $time, reset, A, B, EncOut, EncOut);

endmodule
