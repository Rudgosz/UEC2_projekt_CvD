`timescale 1 ns / 1 ps

module throw_tb;

    localparam CLK65_PERIOD = 15.385; // 65MHz period (15.385ns)

    logic clk, rst, enable;
    logic [11:0] y_pos, x_pos;

    throw_ctl dut (.*); // Auto-connect ports

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

        // Release reset and trigger throw
        rst = 0;
        #100;
        enable = 1;
        #(CLK65_PERIOD);
        enable = 0;

        // Observe full motion (1200 cycles)
        #(2400 * CLK65_PERIOD);

        // Print results
        $display("Final positions: x=%0d, y=%0d", x_pos, y_pos);
        $finish;
    end

    // Waveform dumping
    initial begin
        $dumpfile("throw_tb.vcd");
        $dumpvars(0, throw_tb);
    end

endmodule