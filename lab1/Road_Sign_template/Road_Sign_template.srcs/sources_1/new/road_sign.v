`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TU Delft
// Engineer: Himanshu Savargaonkar
// Module Name: road_sign
// Part 3: road sign FSM -- point left, point right, warning, idle
//////////////////////////////////////////////////////////////////////////////////

module road_sign(
    input wire clk,      // Clock signal
    input wire reset,    // Reset signal to restart the FSM
    input wire [3:0] btn, // 4-bit input register
    output reg [3:0] led, // 4-bit output register
    output reg [2:0] rgb_led
    );

    // 125 MHz / 62_500_000 = one animation step every 500 ms.
    // Overridden to a small value in the testbench so simulation is quick.
    parameter DIV = 62_500_000;

    localparam IDLE  = 2'd0;
    localparam LEFT  = 2'd1;
    localparam RIGHT = 2'd2;
    localparam WARN  = 2'd3;

    reg [1:0]  mode;        // which sign mode we are in
    reg [25:0] divider;     // counts clock cycles between animation steps
    reg [2:0]  anim_step;   // position within the current animation
    reg [2:0]  anim_last;   // last step of the current animation

    // left and right run over 6 states, warning over 3, idle stays put
    always @(*) begin
        case (mode)
            LEFT, RIGHT: anim_last = 3'd5;
            WARN:        anim_last = 3'd2;
            default:     anim_last = 3'd0;
        endcase
    end

    // Mode changes are restricted: only Idle may enter an active mode, and an
    // active mode may only return to Idle. Any mode change restarts the animation.
    always @(posedge clk) begin
        if (reset) begin
            mode      <= IDLE;
            divider   <= 0;
            anim_step <= 0;
        end
        else if (mode == IDLE && btn[0]) begin
            mode <= LEFT;   divider <= 0;  anim_step <= 0;
        end
        else if (mode == IDLE && btn[1]) begin
            mode <= RIGHT;  divider <= 0;  anim_step <= 0;
        end
        else if (mode == IDLE && btn[2]) begin
            mode <= WARN;   divider <= 0;  anim_step <= 0;
        end
        else if (mode != IDLE && btn[3]) begin
            mode <= IDLE;   divider <= 0;  anim_step <= 0;
        end
        else if (divider == DIV - 1) begin
            divider <= 0;
            if (anim_step == anim_last)
                anim_step <= 0;         // circular: wrap to the first state
            else
                anim_step <= anim_step + 1'b1;
        end
        else begin
            divider <= divider + 1'b1;
        end
    end

    // LED patterns per mode, and one RGB colour per mode
    always @(*) begin
        led     = 4'b0000;
        rgb_led = 3'b000;

        case (mode)
            IDLE: begin
                rgb_led = 3'b001;               // blue
                led     = 4'b0000;
            end

            LEFT: begin
                rgb_led = 3'b010;               // green
                case (anim_step)
                    3'd0: led = 4'b0000;
                    3'd1: led = 4'b0001;
                    3'd2: led = 4'b0011;
                    3'd3: led = 4'b0110;
                    3'd4: led = 4'b1100;
                    3'd5: led = 4'b1000;
                    default: led = 4'b0000;
                endcase
            end

            RIGHT: begin
                rgb_led = 3'b100;               // red
                case (anim_step)
                    3'd0: led = 4'b0000;
                    3'd1: led = 4'b1000;
                    3'd2: led = 4'b1100;
                    3'd3: led = 4'b0110;
                    3'd4: led = 4'b0011;
                    3'd5: led = 4'b0001;
                    default: led = 4'b0000;
                endcase
            end

            WARN: begin
                rgb_led = 3'b110;               // yellow
                case (anim_step)
                    3'd0: led = 4'b0000;
                    3'd1: led = 4'b1100;
                    3'd2: led = 4'b0011;
                    default: led = 4'b0000;
                endcase
            end
        endcase
    end

endmodule
