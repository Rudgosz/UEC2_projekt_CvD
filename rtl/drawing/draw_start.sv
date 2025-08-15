module draw_start (
    input  logic        clk,
    input  logic        rst,
    input  logic        enter,
    input  logic        game_state,
    output logic        start_on,
    output logic [11:0] rgb_start,
    vga_if.vga_in      vga_in,
    vga_if.vga_out      vga_out
);

    localparam integer X_START = 200;
    localparam integer X_END   = 400;
    localparam integer Y_START = 200;
    localparam integer Y_END   = 300;

    logic start_enable;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            start_enable <= 1;
        end else if (enter) begin
            start_enable <= 0;
        end
    end

    always_comb begin
        start_on  = 0;
        rgb_start = vga_in.rgb;

        if (game_state == 3'b000 &&
            start_enable &&
            vga_in.hcount >= X_START && vga_in.hcount < X_END &&
            vga_in.vcount >= Y_START && vga_in.vcount < Y_END) begin
            start_on  = 1;
            rgb_start = 12'hFF0;
        end
    end

    assign vga_out.hcount = vga_in.hcount;
    assign vga_out.vcount = vga_in.vcount;
    assign vga_out.hsync  = vga_in.hsync;
    assign vga_out.vsync  = vga_in.vsync;
    assign vga_out.hblnk  = vga_in.hblnk;
    assign vga_out.vblnk  = vga_in.vblnk;
    assign vga_out.rgb    = start_on ? rgb_start : vga_in.rgb;

endmodule
