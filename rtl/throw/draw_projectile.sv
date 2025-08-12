module draw_projectile (
    input logic clk,
    input logic rst,
    input logic [11:0] x_pos,  // Absolute X from throw_ctl (0 = center)
    input logic [11:0] y_pos,  // Absolute Y from throw_ctl (0 = ground)
    vga_if.vga_in vga_in,
    vga_if.vga_out vga_out
);
    // Projectile parameters
    localparam PROJ_WIDTH = 30;    // Projectile width in pixels
    localparam PROJ_HEIGHT = 30;   // Projectile height in pixels
    localparam PROJ_COLOR = 12'hF00; // Red color
    
    // Screen parameters (must match your actual resolution)
    localparam SCREEN_WIDTH = 1024;
    localparam SCREEN_HEIGHT = 768;
    
    // Calculate projectile boundaries
    logic [11:0] proj_left, proj_right;
    logic [11:0] proj_top, proj_bottom;
    
    always_comb begin
        // Convert absolute coordinates to screen coordinates:
        // X: 0 = center, positive = right
        proj_left = (SCREEN_WIDTH/2) + x_pos - (PROJ_WIDTH/2);
        proj_right = (SCREEN_WIDTH/2) + x_pos + (PROJ_WIDTH/2);
        
        // Y: 0 = ground level, positive = up (screen Y increases downward)
        proj_top = (SCREEN_HEIGHT-1) - y_pos - (PROJ_HEIGHT/2);
        proj_bottom = (SCREEN_HEIGHT-1) - y_pos + (PROJ_HEIGHT/2);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            vga_out.rgb <= 0;
        end
        else begin
            // Pass through all VGA timing signals
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync <= vga_in.hsync;
            vga_out.hblnk <= vga_in.hblnk;
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync <= vga_in.vsync;
            vga_out.vblnk <= vga_in.vblnk;
            
            if(vga_in.vblnk || vga_in.hblnk) begin            
                vga_out.rgb <= 0; // Blanking period
            end
            else begin 
                // Check if current pixel is within projectile
                if((vga_in.hcount >= proj_left) && 
                   (vga_in.hcount <= proj_right) &&
                   (vga_in.vcount >= proj_top) && 
                   (vga_in.vcount <= proj_bottom)) begin
                    vga_out.rgb <= PROJ_COLOR;
                end
                else begin
                    vga_out.rgb <= vga_in.rgb; // Background
                end
            end
        end
    end
endmodule