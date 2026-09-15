`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: lfsr
// Bonus: 6-bit linear feedback shift register, P(x) = x^6 + x^5 + x^3 + 1
//////////////////////////////////////////////////////////////////////////////////

module lfsr(
    input  wire        clk,
    input  wire        reset,
    output reg  [5:0]  value,        // current pseudo-random value
    output reg         repetition,   // high once the sequence returns to the seed
    output reg  [6:0]  distance      // number of shifts taken to get back
    );

    parameter SEED1 = 6'b000000;
    parameter SEED2 = 6'b011001;
    parameter SEED3 = 6'b101001;
    parameter SEED = SEED1;

    // the polynomial taps bits 6, 5 and 3, so the bit shifted in is their XOR
    wire       feedback = value[5] ^ value[4] ^ value[2];
    wire [5:0] next     = {value[4:0], feedback};

    always @(posedge clk) begin
        if (reset) begin
            value      <= SEED;
            distance   <= 0;
            repetition <= 0;
        end
        else if (!repetition) begin
            value    <= next;
            distance <= distance + 1'b1;
            if (next == SEED)
                repetition <= 1'b1;     // back at the seed: one full cycle done
        end
    end

endmodule
