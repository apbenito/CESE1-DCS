`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TU Delft
// Engineer: Himanshu Savargaonkar
// Module Name: road_sign
// Part 3 Step 1: 6-state circular FSM, arrow pointing left
//////////////////////////////////////////////////////////////////////////////////

module road_sign(
    input wire clk,      // Clock signal
    input wire reset,    // Reset signal to restart the FSM
    input wire [3:0] btn, // 4-bit input register
    output reg [3:0] led, // 4-bit output register
    output reg [2:0] rgb_led
    );

    // 125 MHz / 62_500_000 = one state change every 500 ms.
    // Overridden to a small value in the testbench so simulation is quick.
    parameter DIV = 62_500_000;

    reg [25:0] divider;     // counts clock cycles between state changes
    reg [2:0]  state;       // 0..5

    always @(posedge clk) begin
        if (reset) begin
            divider <= 0;
            state   <= 0;
        end
        else if (divider == DIV - 1) begin
            divider <= 0;
            if (state == 5)
                state <= 0;         // circular: wrap back to the first state
            else
                state <= state + 1'b1;
        end
        else begin
            divider <= divider + 1'b1;
        end
    end

    // LED pattern for each state: a two-wide band moving left
    always @(*) begin
        rgb_led = 3'b000;

        case (state)
            3'd0: led = 4'b0000;
            3'd1: led = 4'b0001;
            3'd2: led = 4'b0011;
            3'd3: led = 4'b0110;
            3'd4: led = 4'b1100;
            3'd5: led = 4'b1000;
            default: led = 4'b0000;
        endcase
    end

endmodule
