`timescale 1ns / 1ps

module tb_async_en_decode;

    reg        reset;
    reg        prog_select;
    reg  [2:0] bin_rot;
    reg  [3:0] gray_rot;
    wire [3:0] led;

    integer i;

    async_en_decode uut (
        .reset(reset),
        .prog_select(prog_select),
        .bin_rot(bin_rot),
        .gray_rot(gray_rot),
        .led(led)
    );

    initial begin
        $dumpfile("async.vcd");
        $dumpvars(0, tb_async_en_decode);

        prog_select = 1'b1;     // Step 1 mode (switch UP)
        gray_rot    = 4'b0000;  // unused for now

        // ---- reset asserted: LEDs must stay off regardless of input ----
        reset   = 1'b1;
        bin_rot = 3'b000;  #10;
        bin_rot = 3'b101;  #10;
        if (led !== 4'b0000) $display("FAIL: reset did not clear LEDs");

        // ---- reset released: sweep all 8 switch positions ----
        reset = 1'b0;
        $display("");
        $display(" position | bin_rot (raw) | led   | decoded");
        $display("----------+---------------+-------+--------");
        for (i = 0; i < 8; i = i + 1) begin
            bin_rot = ~i[2:0];          // emulate the pull-up wiring
            #10;
            $display("    %0d     |     %b       | %b  |   %0d %s",
                     i, bin_rot, led, led[2:0],
                     (led[2:0] === i[2:0]) ? "OK" : "<-- MISMATCH");
        end

        $display("");
        $finish;
    end

endmodule
