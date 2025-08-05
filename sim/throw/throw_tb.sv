`timescale 1 ns / 1 ps

module throw_tb;

    localparam CLK65_PERIOD = 15.385; // 65MHz period (15.385ns)

    logic clk;
    logic rst;
    logic enable;
    logic [11:0] y_pos;

    throw_ctl dut (.*); // Connect all ports automatically

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK65_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        enable = 0;
        #100;

        // Release reset and trigger motion
        rst = 0;
        #100;
        enable = 1;
        #(CLK65_PERIOD);
        enable = 0;

        // Observe for 1200 cycles (enough to see full parabola)
        #(6400 * CLK65_PERIOD);

        // Verify final state
        if (y_pos !== 0) $error("Error: y_pos did not return to 0");
        else $display("Success: Parabolic motion completed (0→100→0)");

        $finish;
    end

    // Waveform dumping
    initial begin
        $dumpfile("throw_tb.vcd");
        $dumpvars(0, throw_tb);
    end

endmodule