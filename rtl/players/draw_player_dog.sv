module draw_player_dog (
    input  logic clk,
    input  logic rst,

    input  logic turn_active,
    input  logic throw_command,
    input  logic [7:0] throw_power,

    input  logic [11:0] rgb_dog,
    input  logic hit_dog,

    output logic [14:0] dog_addr,
    output logic [1:0]  dog_state,
    output logic        throw_complete,

    vga_if.vga_in  vga_in,
    vga_if.vga_out vga_out
);

    import vga_pkg::*;

    localparam PLAYER_X = 880;
    localparam PLAYER_Y = 430;
    localparam PLAYER_WIDTH  = 140;
    localparam PLAYER_HEIGHT = 151;
    localparam IDLE = 2'b00;
    localparam THROW1 = 2'b01;
    localparam THROW2 = 2'b10;

    localparam int HALF_SECOND_TICKS = 32_500_000;

    logic [10:0] hcount_d, vcount_d;
    logic        hsync_d, vsync_d;
    logic        hblnk_d, vblnk_d;
    logic [11:0] rgb_in_d;

    logic [25:0] counter_dog;
    logic        flash_active;
    logic        hit_dog_reg;

    logic [1:0]  state;
    logic [23:0] throw_timer;
    logic        throw_command_prev;

    logic inside_dog;
    logic [7:0] rel_x;
    logic [7:0] rel_y;

    assign inside_dog = (hcount_d >= PLAYER_X) && (hcount_d < PLAYER_X + PLAYER_WIDTH) &&
                        (vcount_d >= PLAYER_Y) && (vcount_d < PLAYER_Y + PLAYER_HEIGHT) &&
                        !hblnk_d && !vblnk_d;

    assign rel_x = hcount_d - PLAYER_X;
    assign rel_y = vcount_d - PLAYER_Y;
    assign dog_addr = rel_y * PLAYER_WIDTH + rel_x;

    assign throw_complete = (state == THROW2) && 
                            (throw_timer > (1000000 + throw_power * 10000));

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            hit_dog_reg <= 0;
        end else begin
            if (hit_dog && !flash_active) 
                hit_dog_reg <= 1;
            else 
                hit_dog_reg <= 0;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_dog  <= 0;
            flash_active <= 0;
        end else begin
            if (hit_dog_reg) begin
                flash_active <= 1;
                counter_dog  <= 0;
            end else if (flash_active) begin
                if (counter_dog == HALF_SECOND_TICKS - 1) begin
                    flash_active <= 0;
                    counter_dog  <= 0;
                end else begin
                    counter_dog <= counter_dog + 1;
                end
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            throw_command_prev <= 0;
            throw_timer <= 0;

            hcount_d <= 0;
            vcount_d <= 0;
            hsync_d  <= 0;
            vsync_d  <= 0;
            hblnk_d  <= 0;
            vblnk_d  <= 0;
            rgb_in_d <= 0;

        end else begin
            throw_command_prev <= throw_command;
            case (state)
                IDLE: 
                    if (turn_active && throw_command && !throw_command_prev)
                        state <= THROW1;

                THROW1: 
                    if (!throw_command) begin
                        state <= THROW2;
                        throw_timer <= 0;
                    end

                THROW2: 
                    if (throw_complete) 
                        state <= IDLE;
                    else 
                        throw_timer <= throw_timer + 1;
            endcase

            hcount_d <= vga_in.hcount;
            vcount_d <= vga_in.vcount;
            hsync_d  <= vga_in.hsync;
            vsync_d  <= vga_in.vsync;
            hblnk_d  <= vga_in.hblnk;
            vblnk_d  <= vga_in.vblnk;
            rgb_in_d <= vga_in.rgb;
        end
    end

    assign dog_state = state;

    logic [11:0] rgb_nxt;

    always_comb begin
        if (inside_dog) begin
            if (rgb_dog == 12'h0F0) begin
                rgb_nxt = rgb_in_d;
            end else if (flash_active) begin
                rgb_nxt = rgb_dog + 12'hA00;
            end else begin
                rgb_nxt = rgb_dog;
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
