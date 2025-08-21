/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

interface vga_if;

    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;
    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [11:0] rgb;

    modport vga_in (input hcount, hsync, hblnk, vcount, vsync, vblnk, rgb);
    modport vga_out (output hcount, hsync, hblnk, vcount, vsync, vblnk, rgb);

endinterface : vga_if