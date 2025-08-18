module draw_wind (
    input logic clk,
    input logic rst,
    input logic [6:0] wind_force,
    vga_if.vga_in vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam BIG_RECT_WIDTH = 143;
    localparam BIG_RECT_HEIGHT = 16;
    localparam BIG_RECT_COLOR = 12'hEFF;
    
    localparam SMALL_RECT_WIDTH = 16;
    localparam SMALL_RECT_HEIGHT = 16;
    localparam SMALL_RECT_COLOR = 12'h059;
    
    localparam BIG_RECT_X = (HOR_PIXELS - BIG_RECT_WIDTH) / 2;
    localparam BIG_RECT_Y = 40;
    
    localparam BORDER_COLOR = 12'hBDF;
    localparam BORDER_WIDTH = 3;
    
    logic [10:0] small_rect_x_center;
    logic [10:0] small_rect_x_left;
    
    always_comb begin
        small_rect_x_center = BIG_RECT_X + 8 + ((BIG_RECT_WIDTH - SMALL_RECT_WIDTH) * (127-wind_force) / 127);
        small_rect_x_left = small_rect_x_center - (SMALL_RECT_WIDTH / 2);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            vga_out.hcount <= 0;
            vga_out.hsync  <= 0;
            vga_out.hblnk  <= 0;
            vga_out.vcount <= 0;
            vga_out.vsync  <= 0;
            vga_out.vblnk  <= 0;
            vga_out.rgb    <= 0;
        end else begin
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            
            if(vga_in.vblnk || vga_in.hblnk) begin            
                vga_out.rgb <= 12'h0_0_0;
            end else begin 
                if((vga_in.hcount >= BIG_RECT_X - BORDER_WIDTH && vga_in.hcount < BIG_RECT_X + BIG_RECT_WIDTH + BORDER_WIDTH &&
                   vga_in.vcount >= BIG_RECT_Y - BORDER_WIDTH && vga_in.vcount < BIG_RECT_Y + BIG_RECT_HEIGHT + BORDER_WIDTH) &&
                   !(vga_in.hcount >= BIG_RECT_X && vga_in.hcount < BIG_RECT_X + BIG_RECT_WIDTH &&
                   vga_in.vcount >= BIG_RECT_Y && vga_in.vcount < BIG_RECT_Y + BIG_RECT_HEIGHT)) begin
                    vga_out.rgb <= BORDER_COLOR;
                end else if(vga_in.hcount >= BIG_RECT_X && vga_in.hcount < BIG_RECT_X + BIG_RECT_WIDTH &&
                   vga_in.vcount >= BIG_RECT_Y && vga_in.vcount < BIG_RECT_Y + BIG_RECT_HEIGHT) begin
                    if(vga_in.hcount >= small_rect_x_left && vga_in.hcount < small_rect_x_left + SMALL_RECT_WIDTH &&
                       vga_in.vcount >= BIG_RECT_Y && vga_in.vcount < BIG_RECT_Y + SMALL_RECT_HEIGHT) begin
                        vga_out.rgb <= SMALL_RECT_COLOR;
                    end else begin
                        vga_out.rgb <= BIG_RECT_COLOR;
                    end
                end else begin
                    vga_out.rgb <= vga_in.rgb;
                end
            end
        end
    end
endmodule