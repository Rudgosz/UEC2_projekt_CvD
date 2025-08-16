module draw_over (
    input  logic        clk,
    input  logic        rst,
    input  logic [2:0]  game_state,

    output logic [19:0] over_addr,
    input  logic [11:0] rgb_over,

    vga_if.vga_in  vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam IMG_WIDTH  = 403;
    localparam IMG_HEIGHT = 75;

    localparam X_OFFSET = (1024 - IMG_WIDTH) / 2;
    localparam Y_OFFSET = 300;

    logic [19:0] addr_reg;
    assign over_addr = addr_reg;

    logic [10:0] hcount_d, vcount_d;
    logic        hsync_d, vsync_d;
    logic        hblnk_d, vblnk_d;

    always_ff @(posedge clk) begin
        if (rst) begin
            addr_reg <= 0;
            hcount_d <= 0;
            vcount_d <= 0;
            hsync_d  <= 0;
            vsync_d  <= 0;
            hblnk_d  <= 0;
            vblnk_d  <= 0;
        end else begin
            hcount_d <= vga_in.hcount;
            vcount_d <= vga_in.vcount;
            hsync_d  <= vga_in.hsync;
            vsync_d  <= vga_in.vsync;
            hblnk_d  <= vga_in.hblnk;
            vblnk_d  <= vga_in.vblnk;

            if (vga_in.hcount >= X_OFFSET && vga_in.hcount < X_OFFSET + IMG_WIDTH &&
                vga_in.vcount >= Y_OFFSET && vga_in.vcount < Y_OFFSET + IMG_HEIGHT) begin
                addr_reg <= (vga_in.vcount - Y_OFFSET) * IMG_WIDTH +
                            (vga_in.hcount - X_OFFSET);
            end else begin
                addr_reg <= 0;
            end
        end
    end

    logic [11:0] rgb_nxt;

    always_comb begin
        if (!hblnk_d && !vblnk_d && game_state == 3'b100 &&
            hcount_d >= X_OFFSET && hcount_d < X_OFFSET + IMG_WIDTH &&
            vcount_d >= Y_OFFSET && vcount_d < Y_OFFSET + IMG_HEIGHT) begin

            if (rgb_over == 12'h0F0) begin
                rgb_nxt = vga_in.rgb;
            end else begin
                rgb_nxt = rgb_over;
            end

        end else begin
            rgb_nxt = vga_in.rgb;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            vga_out.vcount <= 0;
            vga_out.vsync  <= 0;
            vga_out.vblnk  <= 0;
            vga_out.hcount <= 0;
            vga_out.hsync  <= 0;
            vga_out.hblnk  <= 0;
            vga_out.rgb    <= 0;
        end else begin
            vga_out.vcount <= vcount_d;
            vga_out.vsync  <= vsync_d;
            vga_out.vblnk  <= vblnk_d;
            vga_out.hcount <= hcount_d;
            vga_out.hsync  <= hsync_d;
            vga_out.hblnk  <= hblnk_d;
            vga_out.rgb    <= rgb_nxt;
        end
    end

endmodule
