`timescale 1 ns / 1 ps

module throw_tb;

localparam CLK100_PERIOD = 15; // 40MHz clock (25ns period)     

logic clk, rst;
logic enable;
logic [11:0] x_pos, y_pos;

// Clock generation
initial begin
    clk = 1'b0;
    forever #(CLK100_PERIOD/2) clk = ~clk;
end

// Instantiate the unit under test
throw_ctl u_throw_ctl(
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .y_pos(y_pos),
    .x_pos(x_pos)
);

// Test sequence
initial begin
    // Initialize inputs
    rst = 1'b1;
    enable = 1'b0;
    
    // Reset the system
    #100;
    rst = 1'b0;
    
    // Wait a bit
    #1000;
    
    // Start the throw
    enable = 1'b1;
    #50;
    enable = 1'b0; // Only need a pulse to start
    
    // Let it run for 200ms (enough to reach bottom)
    #1000000000; // 200ms at 1ns timescale 500000000
    
    // End simulation
    $display("Simulation finished");
    $finish;
end

// Monitor the results
initial begin
    $timeformat(-9, 0, " ns", 10);
    $monitor("At time %t: enable = %b, y_pos = %0d, x_pos = %0d", 
             $time, enable, y_pos, x_pos);
end

endmodule