/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

module top_vga (
        input  logic clk,
        input  logic rst,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    // VGA signals from timing
    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    // VGA signals from background
    vga_if vga_bg_if();

    // VGA signals from draw_player_dog
    vga_if vga_dog_if();

    //signals for draw_player_dog and dog_rom
    logic [14:0] dog_addr;
    logic [11:0] rgb_dog;


    /**
     * Signals assignments
     */

    assign vs = vga_dog_if.vsync;
    assign hs = vga_dog_if.hsync;
    assign {r,g,b} = vga_dog_if.rgb[11:0];

    wire [11:0] rgb_background;
    wire [19:0] bg_addr;

    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk,
        .rst,
        .vcount (vcount_tim),
        .vsync  (vsync_tim),
        .vblnk  (vblnk_tim),
        .hcount (hcount_tim),
        .hsync  (hsync_tim),
        .hblnk  (hblnk_tim)
    );

    draw_bg u_draw_bg (
        .clk,
        .rst,

        .vcount_in  (vcount_tim),
        .vsync_in   (vsync_tim),
        .vblnk_in   (vblnk_tim),
        .hcount_in  (hcount_tim),
        .hsync_in   (hsync_tim),
        .hblnk_in   (hblnk_tim),
        .rgb_background (rgb_background),
        .bg_addr (bg_addr),

        .vga_out    (vga_bg_if.vga_out)

    );

    image_rom u_image_rom_background (
        .clk,
        .address(bg_addr),
        .rgb(rgb_background)
    );

    draw_player_dog u_draw_player_dog (
        .clk,
        .rst,
        .rgb_dog(rgb_dog),
        .dog_addr(dog_addr),
        .vga_in     (vga_bg_if.vga_in),
        .vga_out    (vga_dog_if.vga_out)
    );

    image_rom_dog u_image_rom_dog (
        .clk,
        .address(dog_addr),
        .rgb(rgb_dog)
    );
    

endmodule