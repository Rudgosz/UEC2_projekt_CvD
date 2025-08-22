/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

module draw_player_cat (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] rgb_cat,
    input  logic hit_cat,

    output logic [13:0] cat_addr,

    vga_if.vga_in  vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam PLAYER_X      = 1;
    localparam PLAYER_Y      = 430;
    localparam PLAYER_WIDTH  = 157;
    localparam PLAYER_HEIGHT = 99;

    localparam int HALF_SECOND_TICKS = 32_500_000;

    logic [10:0] hcount_d, vcount_d;
    logic        hsync_d, vsync_d;
    logic        hblnk_d, vblnk_d;
    logic [11:0] rgb_in_d;

    logic [25:0] counter_cat;
    logic        flash_active;
    logic        hit_cat_reg;

    logic inside_cat;
    logic [13:0] rel_x;
    logic [13:0] rel_y;

    assign inside_cat = (hcount_d >= PLAYER_X) && (hcount_d < PLAYER_X + PLAYER_WIDTH) &&
                        (vcount_d >= PLAYER_Y) && (vcount_d < PLAYER_Y + PLAYER_HEIGHT) &&
                        !hblnk_d && !vblnk_d;

    assign rel_x = hcount_d - PLAYER_X;
    assign rel_y = vcount_d - PLAYER_Y;
    assign cat_addr = rel_y * PLAYER_WIDTH + rel_x;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            hit_cat_reg <= 0;
        end else begin
            if (hit_cat && !flash_active) 
                hit_cat_reg <= 1;
            else 
                hit_cat_reg <= 0;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_cat  <= 0;
            flash_active <= 0;
        end else begin
            if (hit_cat_reg) begin
                flash_active <= 1;
                counter_cat  <= 0;
            end else if (flash_active) begin
                if (counter_cat == HALF_SECOND_TICKS - 1) begin
                    flash_active <= 0;
                    counter_cat  <= 0;
                end else begin
                    counter_cat <= counter_cat + 1;
                end
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            hcount_d <= 0;
            vcount_d <= 0;
            hsync_d  <= 0;
            vsync_d  <= 0;
            hblnk_d  <= 0;
            vblnk_d  <= 0;
            rgb_in_d <= 0;

        end else begin
            hcount_d <= vga_in.hcount;
            vcount_d <= vga_in.vcount;
            hsync_d  <= vga_in.hsync;
            vsync_d  <= vga_in.vsync;
            hblnk_d  <= vga_in.hblnk;
            vblnk_d  <= vga_in.vblnk;
            rgb_in_d <= vga_in.rgb;
        end
    end

    logic [11:0] rgb_nxt;

    always_comb begin
        if (inside_cat) begin
            if (rgb_cat == 12'h0F0) begin
                rgb_nxt = rgb_in_d;
            end else if (flash_active) begin
                rgb_nxt = rgb_cat + 12'hA00;
            end else begin
                rgb_nxt = rgb_cat;
            end
        end else begin
            rgb_nxt = rgb_in_d;
        end
    end

    assign vga_out.hcount = hcount_d; 
    assign vga_out.vcount = vcount_d; 
    assign vga_out.hsync  = hsync_d; 
    assign vga_out.vsync  = vsync_d; 
    assign vga_out.hblnk  = hblnk_d; 
    assign vga_out.vblnk  = vblnk_d; 
    assign vga_out.rgb    = rgb_nxt; 

endmodule
