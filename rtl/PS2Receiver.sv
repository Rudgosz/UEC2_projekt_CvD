module ps2_receiver(
    input wire clk,
    input wire ps2_clk,
    input wire ps2_data,
    output reg [7:0] keycode,
    output reg key_valid
);

localparam DEBOUNCE_TIME = 650;

reg [9:0] debounce_count = 0;
reg ps2_clk_clean = 1;
reg ps2_clk_prev =1;
reg [3:0] bit_count = 0;
reg [10:0] shift_reg = 0;

always @(posedge clk) begin
    if (ps2_clk != ps2_clk_clean) begin
        debounce_count <= debounce_count + 1;
        if(debounce_count == DEBOUNCE_TIME) begin
            ps2_clk_clean <= ps2_clk;
            debounce_count <= 0;
        end
    end else begin
        debounce_count <= 0;
    end 
    ps2_clk_prev <= ps2_clk_clean;
end

wire falling_edge = (ps2_clk_prev == 1 && ps2_clk_clean == 0);

always @(posedge clk) begin
    key_valid <= 0;

    if(falling_edge) begin
        shift_reg <= {ps2_data, shift_reg[10:1]};
        bit_count <= bit_count +1;

        if (bit_count == 10) begin
            if (shift_reg[0] == 0 && shift_reg[10] == 1 && ^shift_reg[9:1] == shift_reg[9]) begin
                keycode <= shift_reg[8:1];
                key_valid <= 1;
            end
            bit_count <= 0;
        end
    end

    if(ps2_clk_clean && ps2_data && bit_count != 0)
        bit_count <= 0;
end
endmodule