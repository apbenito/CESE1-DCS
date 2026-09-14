`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: async_en_decode
// Part 1 Step 1: Binary Display
//////////////////////////////////////////////////////////////////////////////////

module async_en_decode(
    input  wire       reset,
    input  wire       prog_select,
    input  wire [2:0] bin_rot,
    input  wire [3:0] gray_rot,
    output reg  [3:0] led
    );

    always @(*) begin
        led = 4'b0000;              // default: LEDs off (also avoids a latch)

        if (!reset) begin
            led[2:0] = ~bin_rot;    // switch has pull-ups, so invert
        end
    end

endmodule
