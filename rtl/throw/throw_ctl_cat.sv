`timescale 1 ns / 1 ps

module throw_ctl_cat (
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
    localparam int MOUSE_XPOS_CAT = 140;
    localparam int MOUSE_YPOS_CAT = 350;
    localparam int IMAGE_Y_END = 700;

    localparam int INIT_FORCE = 18;
    localparam int WIND = 50;


    localparam WALL_X_LEFT = 490;
    localparam WALL_X_RIGHT = 534;
    localparam WALL_TOP = 241;
    localparam WALL_BOTTOM = 768;

    localparam DOG_X_LEFT = 867;
    localparam DOG_X_RIGHT = 1024;
    localparam DOG_TOP = 427;
    localparam DOG_BOTTOM = 525;
    
    

    int counter_cat;
    int ms_counter_cat;

    logic signed [11:0] ypos_0, xpos_0, ypos_0_fall;
    int time_0_cat;
    int signed v_0_cat;
    int signed v_temp_cat;
    int elapsed_cat;

    int scaled_force_cat;
    int wind_offset_cat;
    int elapsed_cat_fall;

    typedef enum logic [1:0] {ST_IDLE, ST_THROW, ST_FALL, ST_END} state_t;
    state_t state;

    logic hit_cat_reg;
    logic cat_in_range;
    logic cat_in_range_d;

    always_comb begin
        cat_in_range = (VER_PIXELS - y_pos >= DOG_TOP && VER_PIXELS - y_pos <= DOG_BOTTOM &&
                        x_pos <= DOG_X_RIGHT && x_pos >= DOG_X_LEFT);
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
        scaled_force_cat = (throw_force * INIT_FORCE) / 100;
        if (WIND < 50)
            wind_offset_cat = -((50 - WIND) * throw_force) / 50;
        else if (WIND > 50)
            wind_offset_cat = ((WIND - 50) * throw_force) / 50;
        else
            wind_offset_cat = 0;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            counter_cat <= 0;
            ms_counter_cat <= 0;
        end else begin
            if (counter_cat == 64999 * 20) begin
                ms_counter_cat <= ms_counter_cat + 1;
                counter_cat <= 0;
            end else begin
                counter_cat <= counter_cat + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= ST_IDLE;
            x_pos <= MOUSE_XPOS_CAT;
            y_pos <= MOUSE_YPOS_CAT;
            time_0_cat <= 0;
            v_0_cat <= 0;
            v_temp_cat <= 0;
            ypos_0 <= MOUSE_YPOS_CAT;
            xpos_0 <= MOUSE_XPOS_CAT;
            ypos_0_fall <= MOUSE_YPOS_CAT;
        end else begin
            case (state)
                ST_IDLE: begin
                    x_pos <= MOUSE_XPOS_CAT;
                    y_pos <= MOUSE_YPOS_CAT;
                    if (enable) begin
                        state <= ST_THROW;
                        time_0_cat <= ms_counter_cat;
                        ypos_0 <= MOUSE_YPOS_CAT;
                        xpos_0 <= MOUSE_XPOS_CAT;
                        v_0_cat <= INITIAL_VELOCITY;
                        v_temp_cat <= INITIAL_VELOCITY;
                    end
                end

                ST_THROW: begin
                    elapsed_cat = ms_counter_cat - time_0_cat;
                    v_temp_cat <= v_0_cat - GRAVITY * elapsed_cat;
                    y_pos <= ypos_0 + v_0_cat * elapsed_cat - (GRAVITY * elapsed_cat * elapsed_cat) / 2;
                    x_pos <= xpos_0 + (scaled_force_cat + wind_offset_cat) * elapsed_cat;
                    
                    if (v_temp_cat <= 0) begin
                        state <= ST_FALL;
                        time_0_cat <= ms_counter_cat;
                        ypos_0_fall <= y_pos;
                        xpos_0 <= x_pos;
                    end
                end

                ST_FALL: begin
                    elapsed_cat_fall = ms_counter_cat - time_0_cat;
                    v_temp_cat <= -GRAVITY * elapsed_cat_fall;
                    y_pos <= ypos_0_fall - (GRAVITY * elapsed_cat_fall * elapsed_cat_fall) / 2;
                    

                    if (y_pos <= VER_PIXELS - 525) begin
                        y_pos <= MOUSE_YPOS_CAT;
                        state <= ST_END;
                    end

                    if (VER_PIXELS - y_pos > WALL_TOP && x_pos <= WALL_X_RIGHT + 15 && x_pos >= WALL_X_LEFT - 15) begin
                        x_pos <= x_pos;
                    end else begin
                        x_pos <= xpos_0 + (scaled_force_cat + wind_offset_cat) * elapsed_cat_fall;
                    end

                    if(VER_PIXELS - y_pos <= WALL_TOP && VER_PIXELS - y_pos >= WALL_TOP - 15 && x_pos <= WALL_X_RIGHT + 15 && x_pos >= WALL_X_LEFT - 15) begin
                        state <= ST_END;
                    end

                                        

                end

                ST_END: begin
                    x_pos <= MOUSE_XPOS_CAT;
                    y_pos <= MOUSE_YPOS_CAT;

                    if (!enable) begin
                        state <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end


endmodule
