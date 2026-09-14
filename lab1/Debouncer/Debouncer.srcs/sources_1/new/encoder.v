`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TU Delft
// Module Name: encoder
// Target Devices: PYNQ Z1
// Part 2 Step 1: 4-bit up/down counter, A counts up and B counts down
//////////////////////////////////////////////////////////////////////////////////

module encoder (
    input wire reset, // Reset pin
    input wire clk,   // Clock signal
    input wire A,     // Button A input
    input wire B,     // Button B input
    output reg [3:0] EncOut  // 4-bit Gray code output
    );

    // previous button states, used to count once per press instead of
    // once per clock cycle while the button is held
    reg A_prev = 0;
    reg B_prev = 0;

    always @(posedge clk) begin
        if (reset) begin
            EncOut <= 4'b0000;
            A_prev <= 1'b0;
            B_prev <= 1'b0;
        end
        else begin
            A_prev <= A;
            B_prev <= B;

            if (A && !A_prev)
                EncOut <= EncOut + 1'b1;
            else if (B && !B_prev)
                EncOut <= EncOut - 1'b1;
        end
    end

endmodule
