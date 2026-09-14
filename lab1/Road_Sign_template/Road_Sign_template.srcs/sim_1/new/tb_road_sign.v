`timescale 1ns / 1ps

module tb_road_sign;

    reg        clk;
    reg        reset;
    reg  [3:0] btn;
    wire [3:0] led;
    wire [2:0] rgb_led;

    integer i;

    // small divider so the animation steps quickly in simulation
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

    task press;
        input [3:0] which;
        begin
            btn = which;  #24;
            btn = 4'b0000;  #24;
        end
    endtask

    // print one full animation cycle for whatever mode we are in
    task show_animation;
        input integer steps;
        begin
            for (i = 0; i < steps; i = i + 1) begin
                $display("      step %0d  led=%b  rgb=%b", uut.anim_step, led, rgb_led);
                #80;                 // DIV=10 -> 10 clocks -> 80 ns per step
            end
        end
    endtask

    initial begin
        $dumpfile("road_sign.vcd");
        $dumpvars(0, tb_road_sign);

        btn   = 4'b0000;
        reset = 1;  #40;
        reset = 0;  #40;

        $display("");
        $display("IDLE after reset:  led=%b  rgb=%b (blue)", led, rgb_led);

        $display("");
        $display("BTN0 -> POINT LEFT");
        press(4'b0001);
        show_animation(7);

        // Step 3 safety: an active mode must NOT jump straight to another
        $display("");
        $display("BTN1 while in LEFT (should be ignored):");
        press(4'b0010);
        $display("      mode=%0d  (1 = still LEFT)", uut.mode);
        press(4'b0100);
        $display("      mode=%0d after BTN2 (1 = still LEFT)", uut.mode);

        $display("");
        $display("BTN3 -> IDLE");
        press(4'b1000);
        $display("      mode=%0d  led=%b  rgb=%b", uut.mode, led, rgb_led);

        $display("");
        $display("BTN1 -> POINT RIGHT");
        press(4'b0010);
        show_animation(7);

        $display("");
        $display("BTN3 -> IDLE, then BTN2 -> WARNING");
        press(4'b1000);
        press(4'b0100);
        show_animation(4);

        $display("");
        $display("reset from WARNING:");
        reset = 1;  #40;
        $display("      mode=%0d  led=%b  rgb=%b", uut.mode, led, rgb_led);
        $display("");

        $finish;
    end

endmodule
