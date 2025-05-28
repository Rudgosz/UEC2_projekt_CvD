/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 25;     // 40 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    wire [10:0] vcount, hcount;
    wire        vsync,  hsync;
    wire        vblnk,  hblnk;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut(
        .clk,
        .rst,
        .vcount,
        .vsync,
        .vblnk,
        .hcount,
        .hsync,
        .hblnk
    );

    /**
     * Tasks and functions
     */

    // Here you can declare tasks with immediate assertions (assert).


    /**
     * Assertions
     */

    property hcount_rst_property;
        @(posedge clk) (hcount == TOTAL_HOR_PIXELS - 1) |=> (hcount == 0);
    endproperty
    
    property vcount_rst_property;
        @(posedge clk) (vcount == TOTAL_VER_PIXELS) |=> (vcount == 0);
    endproperty

    property hblnk_property;
        @(posedge clk) (hcount >= HBLANK_START - 1) && (hcount < HBLANK_END - 1) |=> (hblnk == 1);
    endproperty

    property vblnk_property;
        @(posedge clk) (vcount >= (VBLANK_START)) && (vcount < (VBLANK_END - 1)) |=> (vblnk == 1);
    endproperty

    property hsync_property;
        @(posedge clk) (hcount >= HSYNC_START - 1) && (hcount < HSYNC_END - 1) |=> (hsync == 1);
    endproperty

    property vsync_property;
        @(posedge clk) (vcount >= VSYNC_START - 1) && (vcount < VSYNC_END - 1) |=> (vsync == 1);
    endproperty
    


    // Here you can declare concurrent assertions (assert property).
    assert property (hcount_rst_property) else $error("HCOUNT RESERT FAIL");
    assert property (vcount_rst_property) else $error("VCOUNT RESERT FAIL");
    assert property (hblnk_property) else $error("HBLANK FAIL, hcount (%d) not in range (%d - %d)", hcount, HBLANK_START-1, HBLANK_END-1);
    assert property (vblnk_property) else $error("VBLANK FAIL, vcount (%d) not in range (%d - %d)", vcount, VBLANK_START-1, VBLANK_END-1);
    assert property (hsync_property) else $error("HSYNC FAIL, hcount (%d )not in range (%d - %d)", hcount, HSYNC_START-1, HSYNC_END-1);
    assert property (hsync_property) else $error("VSYNC FAIL, vcount (%d )not in range (%d - %d)", vcount, VSYNC_START-1, VSYNC_END-1);

    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

    
endmodule
