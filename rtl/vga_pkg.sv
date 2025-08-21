/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

package vga_pkg;

    // Parameters for VGA Display 1024 x 768 @ 60fps using a 65 MHz clock;
    localparam HOR_PIXELS       = 1024;
    localparam VER_PIXELS       = 768;

    localparam TOTAL_HOR_PIXELS = 1344;
    localparam TOTAL_VER_PIXELS = 806;

    localparam HBLANK_START     = 1024;
    localparam HBLANK_END       = 1344;

    localparam HSYNC_START      = 1048;
    localparam HSYNC_END        = 1184;

    localparam VBLANK_START     = 768;
    localparam VBLANK_END       = 806;

    localparam VSYNC_START      = 771;
    localparam VSYNC_END        = 777;

endpackage
