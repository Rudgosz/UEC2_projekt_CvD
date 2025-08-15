module keyboard_controller (
    input  logic        clk,
    input  logic [15:0] keycode,
    output logic        space,
    output logic        enter
);

    timeunit 1ns;
    timeprecision 1ps;

    localparam SPACE = 8'h29;
    localparam ENTER = 8'h5A;
    localparam BREAK = 8'hF0;

    always_ff @(posedge clk) begin
        if (keycode[15:8] == BREAK && keycode[7:0] == SPACE) begin
            space <= 0;
        end else if (keycode[7:0] == SPACE) begin
            space <= 1;
        end
    end

        if (keycode[15:8] == BREAK && keycode[7:0] == ENTER) begin
            enter <= 0;
        end else if (keycode[7:0] == ENTER) begin
            enter <= 1;
        end
    end
    
endmodule