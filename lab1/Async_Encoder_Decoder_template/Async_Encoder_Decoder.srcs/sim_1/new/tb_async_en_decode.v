`timescale 1ns / 1ps

module tb_async_en_decode;

    reg        reset;
    reg        prog_select;
    reg  [2:0] bin_rot;
    reg  [3:0] gray_rot;
    wire [3:0] led;

    async_en_decode uut (
        .reset(reset),
        .prog_select(prog_select),
        .bin_rot(bin_rot),
        .gray_rot(gray_rot),
        .led(led)
    );

    initial begin
        $dumpfile("async.vcd");
        $dumpvars(0, tb_async_en_decode);

        prog_select = 1'b1;
        gray_rot    = 4'b0000;

        // reset on: LEDs should stay off whatever the switch says
        reset   = 1'b1;
        bin_rot = 3'b111;  #10;
        bin_rot = 3'b010;  #10;

        // reset off: step through all 8 switch positions
        // (switch has pull-ups, so the input is the inverted position)
        reset = 1'b0;
        bin_rot = 3'b111;  #10;   // position 0
        bin_rot = 3'b110;  #10;   // position 1
        bin_rot = 3'b101;  #10;   // position 2
        bin_rot = 3'b100;  #10;   // position 3
        bin_rot = 3'b011;  #10;   // position 4
        bin_rot = 3'b010;  #10;   // position 5
        bin_rot = 3'b001;  #10;   // position 6
        bin_rot = 3'b000;  #10;   // position 7

        $finish;
    end

    initial
        $monitor("t=%3d  reset=%b  bin_rot=%b  led=%b",
                 $time, reset, bin_rot, led);

endmodule
