module wind_ctl (
    input  logic clk,
    input  logic rst,
    input  logic enter_start_remote,
    input  logic next_turn,
    output logic [6:0] wind
);
    // 7-bit LFSR (cycle length 127)
    localparam [6:0] LFSR_SEED = 7'b0011010;
    
    logic [6:0] lfsr;
    logic next_turn_prev;
    logic enter_flag_latched;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= LFSR_SEED;
            next_turn_prev <= 0;
            enter_flag_latched <= 0;
        end else begin
            next_turn_prev <= next_turn;
            
            if (next_turn && !next_turn_prev) begin
                lfsr <= {lfsr[5:0], lfsr[6] ^ lfsr[4]}; // x^7 + x^5 + 1
            end
            
            if (enter_start_remote) begin
                enter_flag_latched <= 1;
            end
        end
    end
    
    // Output the full 7-bit LFSR value (0-127)
    always_comb begin
        if (enter_flag_latched) begin
            wind = 127 - lfsr;  // Output full 7-bit value (0-127)
        end else begin
            wind = lfsr;  // Output full 7-bit value (0-127)
        end
    end
endmodule