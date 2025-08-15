module draw_over (
    input  logic        clk,
    input  logic        rst,
    input  logic [2:0]  game_state,
    output logic        over_on,
    output logic [11:0] rgb_over,
    vga_if.vga_in      vga_in,
    vga_if.vga_out      vga_out
);

    localparam integer X_START = 400;
    localparam integer X_END   = 600;
    localparam integer Y_START = 200;
    localparam integer Y_END   = 300;

    always_comb begin
        over_on  = 0;
        rgb_over = vga_in.rgb;

        if (game_state == 3'b100 &&
            vga_in.hcount >= X_START && vga_in.hcount < X_END &&
            vga_in.vcount >= Y_START && vga_in.vcount < Y_END) begin
            over_on  = 1;
            rgb_over = 12'hFF0;
        end
    end

    assign vga_out.hcount = vga_in.hcount;
    assign vga_out.vcount = vga_in.vcount;
    assign vga_out.hsync  = vga_in.hsync;
    assign vga_out.vsync  = vga_in.vsync;
    assign vga_out.hblnk  = vga_in.hblnk;
    assign vga_out.vblnk  = vga_in.vblnk;
    assign vga_out.rgb    = over_on ? rgb_over : vga_in.rgb;

endmodule
