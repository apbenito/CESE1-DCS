`timescale 1ns / 1ps

module tb_road_sign;

    reg        clk;
    reg        reset;
    reg  [3:0] btn;
    wire [3:0] led;
    wire [2:0] rgb_led;

    integer i;

    // small divider so the FSM steps quickly in simulation
    road_sign #(.DIV(10)) uut (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .led(led),
        .rgb_led(rgb_led)
    );

    initial begin
        clk = 0;
        forever #4 clk = ~clk;      // 125 MHz -> 8 ns period
    end

    initial begin
        $dumpfile("road_sign.vcd");
        $dumpvars(0, tb_road_sign);

        btn   = 4'b0000;
        reset = 1;  #40;
        reset = 0;

        $display("");
        $display(" state | led");
        $display("-------+------");

        // two full laps, so the wrap from state 5 back to 0 is visible
        for (i = 0; i < 13; i = i + 1) begin
            $display("   %0d   | %b", uut.state, led);
            #80;                     // DIV=10 -> 10 clocks -> 80 ns per state
        end

        $display("");
        $finish;
    end

endmodule
