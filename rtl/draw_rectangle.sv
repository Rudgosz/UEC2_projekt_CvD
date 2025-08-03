module draw_rectangle (
    input  logic        clk,
    input  logic        rst,
    input  logic        space,
    output logic        rectangle_on,
    output logic [11:0] rgb_rectangle,
    vga_if.vga_out      vga_in,
    vga_if.vga_out      vga_out
);



    always_comb begin
        if (space && vga_in.hcount >= 1   && vga_in.hcount < 158 &&
            vga_in.vcount >= 400 && vga_in.vcount < 421) begin
            rectangle_on = 1;
            rgb_rectangle = 12'hF00;  // czerwony
        end else begin
            rectangle_on = 0;
            rgb_rectangle = vga_in.rgb;
        end
    end

    assign vga_out.hcount = vga_in.hcount;
    assign vga_out.vcount = vga_in.vcount;
    assign vga_out.hsync  = vga_in.hsync;
    assign vga_out.vsync  = vga_in.vsync;
    assign vga_out.hblnk  = vga_in.hblnk;
    assign vga_out.vblnk  = vga_in.vblnk;

    assign vga_out.rgb = rectangle_on ? rgb_rectangle : vga_in.rgb;

endmodule
