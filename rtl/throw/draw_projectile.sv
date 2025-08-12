module draw_projectile (
    input logic clk,
    input logic rst,
    input logic [11:0] x_pos,
    input logic [11:0] y_pos,
    vga_if.vga_in vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam RECT_SIZE = 30;

    logic [11:0] rgb_delay;
    logic [10:0] vcount_delay;
    logic vsync_delay;
    logic vblnk_delay;
    logic [10:0] hcount_delay;
    logic hsync_delay;
    logic hblnk_delay;

    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_delay <= '0;
            vsync_delay  <= '0;
            vblnk_delay  <= '0;
            hcount_delay <= '0;
            hsync_delay  <= '0;
            hblnk_delay  <= '0;
            rgb_delay    <= '0;
        end else begin
            vcount_delay <= vga_in.vcount;
            vsync_delay  <= vga_in.vsync;
            vblnk_delay  <= vga_in.vblnk;
            hcount_delay <= vga_in.hcount;
            hsync_delay  <= vga_in.hsync;
            hblnk_delay  <= vga_in.hblnk;
            rgb_delay    <= vga_in.rgb;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            vga_out.hcount <= 0;
            vga_out.hsync  <= 0;
            vga_out.hblnk  <= 0;
            vga_out.vcount <= 0;
            vga_out.vsync  <= 0;
            vga_out.vblnk  <= 0;
            vga_out.rgb    <= 0;
        end else begin
            vga_out.hcount <= hcount_delay;
            vga_out.hsync  <= hsync_delay;
            vga_out.hblnk  <= hblnk_delay;
            vga_out.vcount <= vcount_delay;
            vga_out.vsync  <= vsync_delay;
            vga_out.vblnk  <= vblnk_delay;

            if (hcount_delay >= HOR_PIXELS - x_pos && hcount_delay < HOR_PIXELS - x_pos + RECT_SIZE &&
                vcount_delay >= VER_PIXELS - y_pos && vcount_delay < VER_PIXELS - y_pos + RECT_SIZE)
                vga_out.rgb <= 12'hF00;
            else
                vga_out.rgb <= rgb_delay;
        end
    end

endmodule
