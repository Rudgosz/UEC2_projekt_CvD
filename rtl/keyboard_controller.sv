module keyboard_controller (
    input  logic       clk,
    input  logic       rst,
//    input  logic       ps2_clk,  
//    input  logic       ps2_data,
    input  logic [7:0] ps2_keycode,
    input  logic       ps2_key_valid,
    output logic       throw_trigger,
    output logic [7:0] throw_power
);

    localparam SPACE = 8'h29;
    localparam BREAK = 8'hF0;

    // PS2 Reciver signals
//    wire [15:0] keycode;
//    wire        key_event;

    reg [23:0] hold_counter = 0;
    reg        space_pressed = 0;
    reg [7:0]  power_reg = 0;
    reg        break_detected;

    always @(posedge clk) begin
        if(rst) begin
            space_pressed <= 0;
            hold_counter <= 0;
            power_reg    <= 0;
            break_detected  <= 0;
            throw_trigger <= 0;
        end else begin
            throw_trigger  <= 0;

            if (ps2_key_valid) begin
                if(ps2_keycode == BREAK) begin
                    break_detected <= 1;
                end
                else if (ps2_keycode == SPACE) begin
                    if(break_detected) begin
                        space_pressed <= 0;
                        throw_trigger <= 1;
                        power_reg <= (hold_counter > 255) ? 255 : hold_counter[7:0];
                    end else begin
                        space_pressed <= 1;
                        hold_counter <= 0;
                    end
                    break_detected <= 0;
                end else begin
                    break_detected <= 0;
                end
            end

            if(space_pressed) begin
                if(hold_counter < 24'hFFFFFF)
                    hold_counter <= hold_counter +1;
            end else begin
                hold_counter <= 0;
            end
        end
    end

    assign throw_power = power_reg;

endmodule