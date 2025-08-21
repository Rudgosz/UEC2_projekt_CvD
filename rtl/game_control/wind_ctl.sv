/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

module wind_ctl (
    input  logic clk,
    input  logic rst,
    input  logic enter_start_remote,
    input  logic next_turn,
    output logic [6:0] wind
);

    (* rom_style = "block" *) logic [6:0] random_values [0:127];
    
    initial begin
        $readmemh("../../rtl/data/wind/wind.dat", random_values);
    end

    logic [6:0] read_index;
    logic next_turn_prev;
    logic enter_flag_latched;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            read_index <= 7'h0;
            next_turn_prev <= 0;
            enter_flag_latched <= 0;
            wind <= 0;
        end else begin
            next_turn_prev <= next_turn;
            
            if (enter_start_remote) begin
                enter_flag_latched <= 1;
            end
            
            if (next_turn && !next_turn_prev) begin
                read_index <= read_index + 1;
            end
            
            wind <= enter_flag_latched ? (100 - random_values[read_index]) : random_values[read_index];
        end
    end

endmodule