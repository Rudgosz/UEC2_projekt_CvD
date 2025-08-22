/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

`timescale 1 ns / 1 ps

module throw_ctl_cat (
    input  logic clk,
    input  logic enable,
    input  logic rst,
    input  logic [9:0] throw_force,
    input  logic [6:0] wind_force,
    output logic signed [11:0] x_pos,
    output logic signed [11:0] y_pos,
    output logic hit_cat,
    output logic throw_done,
    output logic is_throwing
);

    import vga_pkg::*;

    localparam INITIAL_VELOCITY = 27;
    localparam GRAVITY = 1;
    localparam MOUSE_XPOS_CAT = 140;
    localparam MOUSE_YPOS_CAT = 350;

    localparam INIT_FORCE = 18;

    localparam WALL_X_LEFT = 490;
    localparam WALL_X_RIGHT = 534;
    localparam WALL_TOP = 241;

    localparam DOG_X_LEFT = 867;
    localparam DOG_X_RIGHT = 1024;
    localparam DOG_TOP = 427;
    localparam DOG_BOTTOM = 525;
    
    int counter_cat;
    int ms_counter_cat;

    logic signed [11:0] ypos_0, xpos_0, ypos_0_fall;
    int time_0_cat;
     int time_0_fall_cat;
    int signed v_0_cat;
    int signed v_temp_cat;
    int elapsed_cat;

    int scaled_force_cat;
    int wind_effect;
    int elapsed_cat_fall;

    typedef enum logic [1:0] {ST_IDLE, ST_THROW, ST_FALL, ST_END} state_t;
    state_t state;

    logic hit_cat_reg;
    logic cat_in_range;
    logic cat_in_range_d;

    always_comb begin
        if (wind_force > 50) begin
            wind_effect = -5 - ((wind_force - 50) >> 3);
        end else if (wind_force < 50) begin
            wind_effect = 5 + ((50 - wind_force) >> 3);
        end else begin
            wind_effect = 0;
        end
    end

    always_comb begin
        cat_in_range = (VER_PIXELS - y_pos >= DOG_TOP && VER_PIXELS - y_pos <= DOG_BOTTOM &&
                        x_pos <= DOG_X_RIGHT && x_pos >= DOG_X_LEFT);
    end

    always_ff @(posedge clk) begin
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
        scaled_force_cat = (throw_force * INIT_FORCE) >> 6;
        elapsed_cat = ms_counter_cat - time_0_cat;
        elapsed_cat_fall = ms_counter_cat - time_0_fall_cat;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            counter_cat <= 0;
            ms_counter_cat <= 0;
        end else begin
            if (counter_cat == 1299980) begin
                ms_counter_cat <= ms_counter_cat + 1;
                counter_cat <= 0;
            end else begin
                counter_cat <= counter_cat + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            is_throwing <= 0;
            throw_done <= 0;
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
                    is_throwing <= 0;
                    throw_done <= 0;
                    x_pos <= MOUSE_XPOS_CAT;
                    y_pos <= MOUSE_YPOS_CAT;
                    if (enable) begin
                        is_throwing <= 1;
                        state <= ST_THROW;
                        time_0_cat <= ms_counter_cat;
                        ypos_0 <= MOUSE_YPOS_CAT;
                        xpos_0 <= MOUSE_XPOS_CAT;
                        v_0_cat <= INITIAL_VELOCITY;
                        v_temp_cat <= INITIAL_VELOCITY;
                    end
                end

                ST_THROW: begin
                    is_throwing <= 1;
                    throw_done <= 0;
                    v_temp_cat <= v_0_cat - GRAVITY * elapsed_cat;
                    y_pos <= ypos_0 + v_0_cat * elapsed_cat - (GRAVITY * elapsed_cat * elapsed_cat) / 2;
                    x_pos <= xpos_0 + (scaled_force_cat + wind_effect) * elapsed_cat;
                    
                    if (v_temp_cat <= 0) begin
                        state <= ST_FALL;
                        time_0_fall_cat <= ms_counter_cat;
                        ypos_0_fall <= y_pos;
                        xpos_0 <= x_pos;
                    end
                end

                ST_FALL: begin
                    is_throwing <= 1;
                    throw_done <= 0;
                    v_temp_cat <= -GRAVITY * elapsed_cat_fall;
                    y_pos <= ypos_0_fall - (GRAVITY * elapsed_cat_fall * elapsed_cat_fall) / 2;
                    x_pos <= xpos_0 + (scaled_force_cat + wind_effect) * elapsed_cat_fall;
                    
                    if (y_pos <= 190) begin
                        y_pos <= MOUSE_YPOS_CAT;
                        state <= ST_END;
                    end

                    if (VER_PIXELS - y_pos > WALL_TOP && x_pos <= WALL_X_RIGHT + 15 && x_pos >= WALL_X_LEFT - 15) begin
                        x_pos <= x_pos;
                    end

                    if(VER_PIXELS - y_pos <= WALL_TOP && VER_PIXELS - y_pos >= WALL_TOP - 15 && 
                       x_pos <= WALL_X_RIGHT + 15 && x_pos >= WALL_X_LEFT - 15) begin
                        state <= ST_END;
                    end
                end

                ST_END: begin
                    is_throwing <= 0;
                    throw_done <= 1;
                    x_pos <= MOUSE_XPOS_CAT;
                    y_pos <= MOUSE_YPOS_CAT;

                    if (!enable) begin
                        state <= ST_IDLE;
                    end
                end

                default: begin
                    state <= ST_IDLE;
                    is_throwing <= 0;
                end
            endcase
        end
    end

endmodule