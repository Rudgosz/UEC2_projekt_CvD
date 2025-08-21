/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

module draw_projectile_dog (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] x_pos,
    input  logic [11:0] y_pos,
    vga_if.vga_in  vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam int CIRCLE_DIAMETER = 30;
    localparam int RADIUS = CIRCLE_DIAMETER / 2;

    logic [11:0] rgb_delay;
    logic [10:0] vcount_delay, hcount_delay;
    logic        vsync_delay,  vblnk_delay;
    logic        hsync_delay,  hblnk_delay;

    int center_x;
    int center_y;
    int dx;
    int dy;

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

            center_x <= HOR_PIXELS - x_pos + RADIUS;
            center_y <= VER_PIXELS - y_pos + RADIUS;

            dx <= hcount_delay - center_x;
            dy <= vcount_delay - center_y;

            if (dx*dx + dy*dy <= RADIUS*RADIUS)
                vga_out.rgb <= 12'hAAA;
            else
                vga_out.rgb <= rgb_delay;
        end
    end

endmodule
