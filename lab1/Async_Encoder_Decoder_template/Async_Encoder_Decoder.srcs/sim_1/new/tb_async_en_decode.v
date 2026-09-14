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

        // reset on: LEDs off whatever the switches say
        reset       = 1'b1;
        prog_select = 1'b1;
        bin_rot     = 3'b111;
        gray_rot    = 4'b0001;
        #10;

        // ---- Step 1: binary display (prog_select = 1) ----
        reset       = 1'b0;
        prog_select = 1'b1;
        bin_rot = 3'b111;  #10;   // position 0
        bin_rot = 3'b110;  #10;   // position 1
        bin_rot = 3'b101;  #10;   // position 2
        bin_rot = 3'b100;  #10;   // position 3
        bin_rot = 3'b011;  #10;   // position 4
        bin_rot = 3'b010;  #10;   // position 5
        bin_rot = 3'b001;  #10;   // position 6
        bin_rot = 3'b000;  #10;   // position 7

        // ---- Step 2: cardinal decoder (prog_select = 0) ----
        prog_select = 1'b0;
        gray_rot = 4'b0001;  #10;   // N
        gray_rot = 4'b0011;  #10;   // NE
        gray_rot = 4'b0111;  #10;   // E
        gray_rot = 4'b1111;  #10;   // SE
        gray_rot = 4'b1110;  #10;   // S
        gray_rot = 4'b1100;  #10;   // SW
        gray_rot = 4'b1000;  #10;   // W
        gray_rot = 4'b0000;  #10;   // NW

        // reset should override the decoder too
        reset = 1'b1;  #10;

        $finish;
    end

    initial
        $monitor("t=%3d  reset=%b  sel=%b  bin=%b  gray=%b  led=%b",
                 $time, reset, prog_select, bin_rot, gray_rot, led);

endmodule
