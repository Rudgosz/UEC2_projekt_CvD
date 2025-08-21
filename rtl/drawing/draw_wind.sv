/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */
 
module draw_wind (
    input logic clk,
    input logic rst,
    input logic [6:0] wind_force,
    vga_if.vga_in vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam RECT_SIZE = 16;
    localparam RECT_HALF = RECT_SIZE / 2;
    localparam RECT_COLOR = 12'h059;
    localparam SCREEN_CENTER_X = HOR_PIXELS / 2;
    localparam SCREEN_CENTER_Y = 48;
    localparam BASE_OFFSET = 50;

    logic [10:0] rect_center_x;
    logic [10:0] rect_left, rect_right, rect_top, rect_bottom;

    always_comb begin
        rect_center_x = SCREEN_CENTER_X - BASE_OFFSET + (100 - wind_force);
        rect_left = (rect_center_x > RECT_HALF) ? (rect_center_x - RECT_HALF) : 0;
        rect_right = rect_center_x + RECT_HALF;
        rect_top = (SCREEN_CENTER_Y > RECT_HALF) ? (SCREEN_CENTER_Y - RECT_HALF) : 0;
        rect_bottom = SCREEN_CENTER_Y + RECT_HALF;
    end

    logic in_rect;

    always_comb begin
        in_rect = (vga_in.hcount >= rect_left) && 
                  (vga_in.hcount <= rect_right) && 
                  (vga_in.vcount >= rect_top) && 
                  (vga_in.vcount <= rect_bottom);
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
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            
            if (vga_in.vblnk || vga_in.hblnk) begin            
                vga_out.rgb <= 12'h0_0_0;
            end else if (in_rect) begin
                vga_out.rgb <= RECT_COLOR;  // Tylko jedno przypisanie!
            end else begin
                vga_out.rgb <= vga_in.rgb;  // Domyślnie przekazuj wejściowy RGB
            end
        end
    end

endmodule