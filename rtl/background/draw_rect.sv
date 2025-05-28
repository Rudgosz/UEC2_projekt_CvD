module draw_rect (
    input logic clk,
    input logic rst,

    vga_if.vga_in vga_in,
    vga_if.vga_out vga_out
    
);

    import vga_pkg::*;

    localparam RECT_CENTER_X = HOR_PIXELS / 2; //horizontal
    localparam RECT_CENTER_Y = VER_PIXELS / 2; //vertical
    localparam RECT_LENGTH = 350;   //horizontal
    localparam RECT_WIDTH = 200;    //vertical
    localparam RECT_COLOR = 12'hf_A_F;

    always_ff @(posedge clk) begin

        if (rst) begin

            vga_out.hcount <= 0;
            vga_out.hsync  <= 0;
            vga_out.hblnk  <= 0;
            vga_out.vcount <= 0;
            vga_out.vsync  <= 0;
            vga_out.vblnk  <= 0;
            vga_out.rgb    <= 0;

        end

        else begin
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            
            if(vga_in.vblnk || vga_in.hblnk) begin            
                vga_out.rgb <= 12'h0_0_0;                    
            end else begin 

                if( vga_in.hcount >= RECT_CENTER_X - (RECT_LENGTH / 2) && vga_in.hcount <= RECT_CENTER_X + (RECT_LENGTH / 2) &&
                vga_in.vcount >= RECT_CENTER_Y - (RECT_WIDTH / 2) && vga_in.vcount <= RECT_CENTER_Y + (RECT_WIDTH / 2)) begin

                    vga_out.rgb <= RECT_COLOR;
                end
                else begin
                    vga_out.rgb <= vga_in.rgb;
                end

            end
        end
    end

endmodule

