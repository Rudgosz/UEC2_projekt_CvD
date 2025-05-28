/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input  logic clk,
        input  logic rst,

        input  logic [10:0] vcount_in,
        input  logic        vsync_in,
        input  logic        vblnk_in,
        input  logic [10:0] hcount_in,
        input  logic        hsync_in,
        input  logic        hblnk_in,
        input  logic [11:0] rgb_background,
        output logic [11:0] bg_addr,


        vga_if.vga_out vga_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic bg_pixel;

    assign bg_pixel = ((hcount_in >= 0) && (hcount_in <= HOR_PIXELS) && 
                      (vcount_in >= 0) && (vcount_in <= VER_PIXELS) &&
                      !hblnk_in && !vblnk_in);
                      

    assign bg_addr = {11'(vcount_in), 11'(hcount_in)};

    logic [11:0] rgb_nxt;
    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.vcount <= vcount_in;
            vga_out.vsync  <= vsync_in;
            vga_out.vblnk  <= vblnk_in;
            vga_out.hcount <= hcount_in;
            vga_out.hsync  <= hsync_in;
            vga_out.hblnk  <= hblnk_in;
            vga_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin
        if(bg_pixel) begin
            rgb_nxt = rgb_background;
        end else begin
            rgb_nxt = 12'h8_8_8;
        end
    end

    
endmodule
