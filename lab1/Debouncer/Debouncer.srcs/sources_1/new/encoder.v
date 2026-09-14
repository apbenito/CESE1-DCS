`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TU Delft
// Module Name: encoder
// Target Devices: PYNQ Z1
// Part 2: 4-bit up/down counter (A up, B down), output gray encoded
//////////////////////////////////////////////////////////////////////////////////

module encoder (
    input wire reset, // Reset pin
    input wire clk,   // Clock signal
    input wire A,     // Button A input
    input wire B,     // Button B input
    output reg [3:0] EncOut  // 4-bit Gray code output
    );

    reg [3:0] count;        // internal binary value

    // previous button states, used to count once per press instead of
    // once per clock cycle while the button is held
    reg A_prev;
    reg B_prev;

    always @(posedge clk) begin
        if (reset) begin
            count  <= 4'b0000;
            A_prev <= 1'b0;
            B_prev <= 1'b0;
        end
        else begin
            A_prev <= A;
            B_prev <= B;

            if (A && !A_prev)
                count <= count + 1'b1;
            else if (B && !B_prev)
                count <= count - 1'b1;
        end
    end

    // binary to gray: each bit is the XOR of the binary bit above it
    always @(*) begin
        EncOut[3] = count[3];
        EncOut[2] = count[3] ^ count[2];
        EncOut[1] = count[2] ^ count[1];
        EncOut[0] = count[1] ^ count[0];
    end

endmodule
