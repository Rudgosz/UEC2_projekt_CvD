`timescale 1 ns / 1 ps

module throw_ctl_dog (
    input  logic clk,
    input  logic enable,
    input  logic rst,
    input  logic [9:0] throw_force,
    output logic signed [11:0] x_pos,
    output logic signed [11:0] y_pos,
    output logic hit_cat
);

    import vga_pkg::*;

    localparam int INITIAL_VELOCITY = 27;
    localparam int GRAVITY = 1;
    localparam int MOUSE_XPOS = 140;
    localparam int MOUSE_YPOS = 350;
    localparam int IMAGE_Y_END = 700;

    localparam int INIT_FORCE = 18;
    localparam int WIND = 50;


    localparam WALL_X_LEFT = 490;
    localparam WALL_X_RIGHT = 534;
    localparam WALL_TOP = 241;
    localparam WALL_BOTTOM = 768;

    localparam CAT_X_LEFT = 0;
    localparam CAT_X_RIGHT = 157;
    localparam CAT_TOP = 427;
    localparam CAT_BOTTOM = 525;
    
    

    int counter;
    int ms_counter;

    logic signed [11:0] ypos_0, xpos_0, ypos_0_fall;
    int time_0;
    int signed v_0;
    int signed v_temp;
    int elapsed;

    int scaled_force;
    int wind_offset;
    int elapsed_fall;

    typedef enum logic [1:0] {ST_IDLE, ST_THROW, ST_FALL, ST_END} state_t;
    state_t state;

    logic hit_cat_reg;
    logic cat_in_range;
    logic cat_in_range_d;

    always_comb begin
        cat_in_range = (VER_PIXELS - y_pos >= CAT_TOP && VER_PIXELS - y_pos <= CAT_BOTTOM &&
                        HOR_PIXELS - x_pos <= CAT_X_RIGHT && HOR_PIXELS - x_pos >= CAT_X_LEFT);
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cat_in_range_d <= 0;
            hit_cat_reg <= 0;
        end else begin
            cat_in_range_d <= cat_in_range;
            
            if (cat_in_range && !cat_in_range_d) begin
                hit_cat_reg <= 1;
            end else begin
                hit_cat_reg <= 0;
            end
        end
    end

    assign hit_cat = hit_cat_reg;


    always_comb begin
        scaled_force = (throw_force * INIT_FORCE) / 100;
        if (WIND < 50)
            wind_offset = -((50 - WIND) * throw_force) / 50;
        else if (WIND > 50)
            wind_offset = ((WIND - 50) * throw_force) / 50;
        else
            wind_offset = 0;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            ms_counter <= 0;
        end else begin
            if (counter == 64999 * 20) begin
                ms_counter <= ms_counter + 1;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= ST_IDLE;
            x_pos <= MOUSE_XPOS;
            y_pos <= MOUSE_YPOS;
            time_0 <= 0;
            v_0 <= 0;
            v_temp <= 0;
            ypos_0 <= MOUSE_YPOS;
            xpos_0 <= MOUSE_XPOS;
            ypos_0_fall <= MOUSE_YPOS;
        end else begin
            case (state)
                ST_IDLE: begin
                    x_pos <= MOUSE_XPOS;
                    y_pos <= MOUSE_YPOS;
                    if (enable) begin
                        state <= ST_THROW;
                        time_0 <= ms_counter;
                        ypos_0 <= MOUSE_YPOS;
                        xpos_0 <= MOUSE_XPOS;
                        v_0 <= INITIAL_VELOCITY;
                        v_temp <= INITIAL_VELOCITY;
                    end
                end

                ST_THROW: begin
                    elapsed = ms_counter - time_0;
                    v_temp <= v_0 - GRAVITY * elapsed;
                    y_pos <= ypos_0 + v_0 * elapsed - (GRAVITY * elapsed * elapsed) / 2;
                    x_pos <= xpos_0 + (scaled_force + wind_offset) * elapsed;
                    
                    if (v_temp <= 0) begin
                        state <= ST_FALL;
                        time_0 <= ms_counter;
                        ypos_0_fall <= y_pos;
                        xpos_0 <= x_pos;
                    end
                end

                ST_FALL: begin
                    elapsed_fall = ms_counter - time_0;
                    v_temp <= -GRAVITY * elapsed_fall;
                    y_pos <= ypos_0_fall - (GRAVITY * elapsed_fall * elapsed_fall) / 2;
                    

                    if (y_pos <= VER_PIXELS - 525) begin
                        y_pos <= MOUSE_YPOS;
                        state <= ST_END;
                    end

                    if (VER_PIXELS - y_pos > WALL_TOP && HOR_PIXELS - x_pos <= WALL_X_RIGHT + 15 && HOR_PIXELS - x_pos >= WALL_X_LEFT - 15) begin
                        x_pos <= x_pos;
                    end else begin
                        x_pos <= xpos_0 + (scaled_force + wind_offset) * elapsed_fall;
                    end

                    if(VER_PIXELS - y_pos <= WALL_TOP && VER_PIXELS - y_pos >= WALL_TOP - 15 && HOR_PIXELS - x_pos <= WALL_X_RIGHT + 15 && HOR_PIXELS - x_pos >= WALL_X_LEFT - 15) begin
                        state <= ST_END;
                    end

                                        

                end

                ST_END: begin
                    x_pos <= MOUSE_XPOS;
                    y_pos <= MOUSE_YPOS;

                    if (!enable) begin
                        state <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
