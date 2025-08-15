module draw_rectangle (
    input  logic        clk,
    input  logic        rst,
    input  logic        space,
    output logic        rectangle_on,
    output logic [11:0] rgb_rectangle,
    output logic [9:0]  throw_force,
    vga_if.vga_out      vga_in,
    vga_if.vga_out      vga_out
);

    localparam X_START     = 876;
    localparam Y_START     = 400;
    localparam Y_END       = 421; 
    localparam MAX_WIDTH   = 128;

    localparam integer STEP_INTERVAL = 1_234_177;

    localparam BORDER_THICKNESS = 3;

    logic [9:0]  rect_width;
    logic [31:0] step_counter;
    logic        space_prev;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rect_width   <= 0;
            step_counter <= 0;
            throw_force  <= 0;
            space_prev   <= 0;
        end else begin
            space_prev <= space;

            if (space) begin
                if (rect_width < MAX_WIDTH) begin
                    if (step_counter >= STEP_INTERVAL) begin
                        rect_width   <= rect_width + 1;
                        step_counter <= 0;
                    end else begin
                        step_counter <= step_counter + 1;
                    end
                end
            end else begin
                rect_width   <= 0;
                step_counter <= 0;
            end

            if (space_prev && !space) begin
                throw_force <= rect_width;
            end
        end
    end

    always_comb begin
        if (space &&
            vga_in.hcount >= X_START && vga_in.hcount < (X_START + rect_width) &&
            vga_in.vcount >= Y_START && vga_in.vcount < Y_END) begin
            rectangle_on  = 1;
            rgb_rectangle = 12'hF00;

        end else if (space && (
                (vga_in.hcount >= (X_START - BORDER_THICKNESS) &&
                vga_in.hcount <  (X_START + MAX_WIDTH + BORDER_THICKNESS) &&
                vga_in.vcount >= (Y_START - BORDER_THICKNESS) &&
                vga_in.vcount <  Y_START) ||

                (vga_in.hcount >= (X_START - BORDER_THICKNESS) &&
                vga_in.hcount <  (X_START + MAX_WIDTH + BORDER_THICKNESS) &&
                vga_in.vcount >= Y_END &&
                vga_in.vcount <  (Y_END + BORDER_THICKNESS)) ||

                (vga_in.vcount >= (Y_START - BORDER_THICKNESS) &&
                vga_in.vcount <  (Y_END + BORDER_THICKNESS) &&
                vga_in.hcount >= (X_START - BORDER_THICKNESS) &&
                vga_in.hcount <  X_START) ||

                (vga_in.vcount >= (Y_START - BORDER_THICKNESS) &&
                vga_in.vcount <  (Y_END + BORDER_THICKNESS) &&
                vga_in.hcount >= (X_START + MAX_WIDTH) &&
                vga_in.hcount <  (X_START + MAX_WIDTH + BORDER_THICKNESS))
        )) begin
            rectangle_on  = 1;
            rgb_rectangle = 12'h000;

        end else begin
            rectangle_on  = 0;
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
