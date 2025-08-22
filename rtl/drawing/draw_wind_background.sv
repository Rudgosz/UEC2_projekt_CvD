/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

module draw_wind_background (
    input logic clk,
    input logic rst,
    vga_if.vga_in vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam BIG_RECT_WIDTH = 116;
    localparam BIG_RECT_HEIGHT = 16;
    localparam BIG_RECT_COLOR = 12'hEFF;
    
    localparam BIG_RECT_X = (HOR_PIXELS - BIG_RECT_WIDTH) / 2;
    localparam BIG_RECT_Y = 40;
    
    localparam BORDER_COLOR = 12'hBDF;
    localparam BORDER_WIDTH = 3;
    
    localparam BIG_RECT_X_MAX = BIG_RECT_X + BIG_RECT_WIDTH;
    localparam BIG_RECT_Y_MAX = BIG_RECT_Y + BIG_RECT_HEIGHT;
    localparam BORDER_X_MIN = BIG_RECT_X - BORDER_WIDTH;
    localparam BORDER_X_MAX = BIG_RECT_X_MAX + BORDER_WIDTH;
    localparam BORDER_Y_MIN = BIG_RECT_Y - BORDER_WIDTH;
    localparam BORDER_Y_MAX = BIG_RECT_Y_MAX + BORDER_WIDTH;
    
    logic [10:0] vga_x_ff, vga_y_ff;
    logic hblnk_ff, vblnk_ff;
    logic [11:0] rgb_in_ff;
    logic [11:0] rgb_nxt;
    
    always_ff @(posedge clk) begin
        vga_x_ff <= vga_in.hcount;
        vga_y_ff <= vga_in.vcount;
        hblnk_ff <= vga_in.hblnk;
        vblnk_ff <= vga_in.vblnk;
        rgb_in_ff <= vga_in.rgb;
    end
    
    logic in_display, in_border, in_big_rect;
    
    always_ff @(posedge clk) begin
        in_display <= !hblnk_ff && !vblnk_ff;
        
        in_border <= in_display &&
                    (vga_x_ff >= BORDER_X_MIN) && (vga_x_ff < BORDER_X_MAX) &&
                    (vga_y_ff >= BORDER_Y_MIN) && (vga_y_ff < BORDER_Y_MAX) &&
                    !((vga_x_ff >= BIG_RECT_X) && (vga_x_ff < BIG_RECT_X_MAX) &&
                      (vga_y_ff >= BIG_RECT_Y) && (vga_y_ff < BIG_RECT_Y_MAX));
        
        in_big_rect <= in_display &&
                      (vga_x_ff >= BIG_RECT_X) && (vga_x_ff < BIG_RECT_X_MAX) &&
                      (vga_y_ff >= BIG_RECT_Y) && (vga_y_ff < BIG_RECT_Y_MAX);
    end
    
    always_ff @(posedge clk) begin
        if (!in_display) begin
            rgb_nxt <= 12'h0;
        end else if (in_border) begin
            rgb_nxt <= BORDER_COLOR;
        end else if (in_big_rect) begin
            rgb_nxt <= BIG_RECT_COLOR;
        end else begin
            rgb_nxt <= rgb_in_ff;
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
            vga_out.hcount <= vga_x_ff;
            vga_out.vcount <= vga_y_ff;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.hblnk  <= hblnk_ff;
            vga_out.vblnk  <= vblnk_ff;
            vga_out.rgb    <= rgb_nxt;
        end
    end

endmodule