module keyboard_controller (
    input  logic        clk,
    input  logic [15:0] keycode,
    output logic        space
);

    timeunit 1ns;
    timeprecision 1ps;

    localparam SPACE = 8'h29;
    localparam BREAK = 8'hF0;

    always_ff @(posedge clk) begin
        if (keycode[15:8] == BREAK && keycode[7:0] == SPACE) begin
            space <= 0;
        end else if (keycode[7:0] == SPACE) begin
            space <= 1;
        end
    end
    
endmodule