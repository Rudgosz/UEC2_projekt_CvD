/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background scaled from 256x192 to 1024x768.
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
    input  logic [11:0] rgb_background, // from ROM
    output logic [19:0] bg_addr,        // address to ROM

    vga_if.vga_out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    // Scaled coordinates (divide by 4)
    logic [9:0] scaled_x;
    logic [8:0] scaled_y;

    assign scaled_x = hcount_in >> 2; // 1024 / 4 = 256
    assign scaled_y = vcount_in >> 2; // 768 / 4 = 192

    // Address to ROM (row-major order: y * 256 + x)
    logic [19:0] bg_addr_reg;
    assign bg_addr = bg_addr_reg;

    always_ff @(posedge clk) begin
        if (rst)
            bg_addr_reg <= 0;
        else
            bg_addr_reg <= scaled_y * 256 + scaled_x;
    end

    // Delay signals to align with ROM read
    logic [10:0] hcount_d, vcount_d;
    logic        hsync_d, vsync_d;
    logic        hblnk_d, vblnk_d;

    always_ff @(posedge clk) begin
        if (rst) begin
            hcount_d <= 0;
            vcount_d <= 0;
            hsync_d  <= 0;
            vsync_d  <= 0;
            hblnk_d  <= 0;
            vblnk_d  <= 0;
        end else begin
            hcount_d <= hcount_in;
            vcount_d <= vcount_in;
            hsync_d  <= hsync_in;
            vsync_d  <= vsync_in;
            hblnk_d  <= hblnk_in;
            vblnk_d  <= vblnk_in;
        end
    end

    // VGA output assignment
    logic [11:0] rgb_nxt;

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

    // RGB selection logic
    always_comb begin
        if (!hblnk_d && !vblnk_d) begin
            rgb_nxt = rgb_background;
        end else begin
            rgb_nxt = 12'h888; // grey background
        end
    end

endmodule
