`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: async_en_decode
// Part 1 Step 1: Binary Display     (prog_select = 1, SW0 up)
// Part 1 Step 2: Cardinal Decoder   (prog_select = 0, SW0 down)
//////////////////////////////////////////////////////////////////////////////////

module async_en_decode(
    input  wire       reset,
    input  wire       prog_select,
    input  wire [2:0] bin_rot,
    input  wire [3:0] gray_rot,
    output reg  [3:0] led
    );

    always @(*) begin
        led = 4'b0000;                      // default: off, and no latch

        if (!reset) begin

            if (prog_select) begin
                // ---- Step 1: binary rotary switch -> LEDs ----
                // pull-ups mean a closed contact reads 0, so invert
                led[2:0] = ~bin_rot;
            end

            else begin
                // ---- Step 2: gray rotary switch -> cardinal direction ----
                // Codes come straight from the switch datasheet (MCSRM-8R8G,
                // "Changeover Angle" table), with pull-ups inverting them.
                // Cardinals light one LED, intercardinals light the two either side.
                case (gray_rot)
                    4'b0001: led = 4'b0001;  // MODE1  N    LD0
                    4'b0011: led = 4'b0011;  // MODE2  NE   LD0 + LD1
                    4'b0111: led = 4'b0010;  // MODE3  E    LD1
                    4'b1111: led = 4'b0110;  // MODE4  SE   LD1 + LD2
                    4'b1110: led = 4'b0100;  // MODE5  S    LD2
                    4'b1100: led = 4'b1100;  // MODE6  SW   LD2 + LD3
                    4'b1000: led = 4'b1000;  // MODE7  W    LD3
                    4'b0000: led = 4'b1001;  // MODE8  NW   LD3 + LD0
                    default: led = 4'b0000;  // between detents
                endcase
            end

        end
    end

endmodule
