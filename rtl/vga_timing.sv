/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

module vga_timing (
        input  logic clk,
        input  logic rst,
        output logic [10:0] vcount,
        output logic vsync,
        output logic vblnk,
        output logic [10:0] hcount,
        output logic hsync,
        output logic hblnk
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    // Add your signals and variables here.


    /**
     * Internal logic
     */

    // Add your code here.


     always_ff @(posedge clk) begin
        if(rst == 1'b1) begin
            hcount <= '0;
            hblnk <= '0;
            hsync <= '0;

            vcount <= '0;
            vblnk <= '0;
            vsync <= '0;
        end
        else begin

            if(hcount == TOTAL_HOR_PIXELS - 1) begin
                hcount <= '0;
            end 
            else begin
            hcount <= hcount+1;
            end

            if(hcount >= HBLANK_START - 1 && hcount < HBLANK_END - 1) begin
                hblnk <= 1'b1;
            end
            else begin
                hblnk <= 1'b0;
            end

            if(hcount >= HSYNC_START - 1 && hcount < HSYNC_END - 1) begin
                hsync <= 1'b1;
            end
            else begin
                hsync <= 1'b0;
            end

        end

        if(hcount == TOTAL_HOR_PIXELS-1)begin
            
            if(vcount == TOTAL_VER_PIXELS - 1) begin
                vcount <= '0;
            end 
            else begin
                vcount <= vcount+1;
            end

            if(vcount >= VBLANK_START - 1 && vcount < VBLANK_END - 1) begin
                vblnk <= 1'b1;
            end
            else begin
                vblnk <= 1'b0;
            end

            if(vcount >= VSYNC_START - 1 && vcount < VSYNC_END - 1) begin
                vsync <= 1'b1;
            end
            else begin
                vsync <= 1'b0;
            end
        end
    end
    

    
endmodule
