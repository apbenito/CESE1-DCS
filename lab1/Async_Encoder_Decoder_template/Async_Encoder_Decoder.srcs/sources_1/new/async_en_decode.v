`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: async_en_decode
// Part 1: binary display (SW0 up) / cardinal decoder (SW0 down)
//////////////////////////////////////////////////////////////////////////////////

module async_en_decode(
    input  wire       reset,
    input  wire       prog_select,
    input  wire [2:0] bin_rot,
    input  wire [3:0] gray_rot,
    output reg  [3:0] led
    );

    always @(*) begin
        led = 4'b0000;                  // default: off, and prevents a latch

        if (!reset) begin
            if (prog_select) begin
                led[2:0] = ~bin_rot;    // pull-ups: a closed contact reads 0
            end
            else begin
                // gray codes from the datasheet, inverted for the pull-ups
                case (gray_rot)
                    4'b0001: led = 4'b0001;  // N
                    4'b0011: led = 4'b0011;  // NE
                    4'b0111: led = 4'b0010;  // E
                    4'b1111: led = 4'b0110;  // SE
                    4'b1110: led = 4'b0100;  // S
                    4'b1100: led = 4'b1100;  // SW
                    4'b1000: led = 4'b1000;  // W
                    4'b0000: led = 4'b1001;  // NW
                    default: led = 4'b0000;
                endcase
            end
        end
    end

endmodule
