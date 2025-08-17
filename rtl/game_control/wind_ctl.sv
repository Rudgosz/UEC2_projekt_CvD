module wind_ctl (
    input  logic clk,
    input  logic rst,
    input  logic next_turn,
    output logic [6:0] wind
);

    localparam logic [15:0] SEED = 16'hBEEF;

    logic [15:0] state;
    logic feedback;
    logic next_turn_prev;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= SEED;
            feedback <= 0;
            next_turn_prev <= 0;
        end else begin
            next_turn_prev <= next_turn;
            if (next_turn && !next_turn_prev) begin
                feedback <= state[15] ^ state[13] ^ state[12] ^ state[10];
                state <= {state[14:0], feedback};
            end
        end
    end

    assign wind = state % 101;

endmodule