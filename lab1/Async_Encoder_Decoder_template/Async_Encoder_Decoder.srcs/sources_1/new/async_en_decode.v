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
        // Default assignment. Two jobs at once:
        //   1. implements "reset on -> all LEDs off"
        //   2. guarantees led is driven on every path, so no latch is inferred
        led = 4'b0000;

        if (!reset) begin
            // Rotary switch is wired with pull-ups: an open contact reads 1,
            // a closed contact is pulled to GND and reads 0. The switch shorts
            // the bits of the selected position to common, so the raw input is
            // the bitwise complement of the position number.
            led[2:0] = ~bin_rot;
        end
    end

endmodule
