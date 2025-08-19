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
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_vga_basys3 (
        input  wire clk,
        input  wire btnC,
        input  wire btnU,
        input  wire btnD,
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        inout  wire PS2Clk,
        inout  wire PS2Data,
        input wire SPACE_RX,
        input wire ENTER_RX,
        output wire SPACE_TX,
        output wire ENTER_TX
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    wire clk_in, clk_fb, clk_ss, clk_out;
    wire pclk;
    wire pclk_mirror;
    wire clk65MHz;

    (* KEEP = "TRUE" *)
    (* ASYNC_REG = "TRUE" *)
    logic [7:0] safe_start = 0;
    // For details on synthesis attributes used above, see AMD Xilinx UG 901:
    // https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


    /**
     * Signals assignments
     */

    assign JA1 = pclk_mirror;
    assign pclk = clk65MHz;


    /**
     * FPGA submodules placement
     */

     clk_wiz_0_clk_wiz inst
     (
     // Clock out ports  
     .clk100MHz(clk100MHz),
     .clk65MHz(clk65MHz),
     // Status and control signals               
     .locked(),
    // Clock in ports
     .clk(clk)
     );

    // Mirror pclk on a pin for use by the testbench;
    // not functionally required for this design to work.

    ODDR pclk_oddr (
        .Q(pclk_mirror),
        .C(pclk),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );


    /**
     *  Project functional top module
     */

    top_vga u_top_vga (
        .clk65MHz(clk65MHz),
        .rst(btnC),
        .btn_space_remote(btnU),
        .btn_enter_remote(btnD),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
        .PS2Clk(PS2Clk),
        .PS2Data(PS2Data),
        .SPACE_RX(SPACE_RX),
        .SPACE_TX(SPACE_TX),
        .ENTER_RX(ENTER_RX),
        .ENTER_TX(ENTER_TX)
    );

endmodule
