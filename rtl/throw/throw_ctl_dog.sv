/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

`timescale 1 ns / 1 ps

module throw_ctl_dog (
    input  logic clk,
    input  logic enable,
    input  logic rst,
    input  logic [9:0] throw_force,
    input  logic [6:0] wind_force,
    output logic signed [11:0] x_pos,
    output logic signed [11:0] y_pos,
    output logic hit_dog,
    output logic throw_done,
    output logic is_throwing
);

    import vga_pkg::*;

    localparam INITIAL_VELOCITY = 27;
    localparam GRAVITY = 1;
    localparam MOUSE_XPOS_DOG = 140;
    localparam MOUSE_YPOS_DOG = 350;

    localparam int INIT_FORCE = 18;

    localparam WALL_X_LEFT = 490;
    localparam WALL_X_RIGHT = 534;
    localparam WALL_TOP = 241;

    localparam CAT_X_LEFT = 0;
    localparam CAT_X_RIGHT = 157;
    localparam CAT_TOP = 427;
    localparam CAT_BOTTOM = 525;
    
    int counter;
    int ms_counter;

    logic signed [11:0] ypos_0, xpos_0, ypos_0_fall;
    int time_0;
    int time_0_fall;
    int signed v_0;
    int signed v_temp;
    int elapsed;

    int scaled_force;
    int wind_effect;
    int elapsed_fall;

    typedef enum logic [1:0] {ST_IDLE, ST_THROW, ST_FALL, ST_END} state_t;
    state_t state;

    logic hit_dog_reg;
    logic dog_in_range;
    logic dog_in_range_d;

    always_comb begin
        if (wind_force < 50) begin
            wind_effect = -5 - ((50 - wind_force) >> 3);
        end else if (wind_force > 50) begin
            wind_effect = 5 + ((wind_force - 50) >> 3);
        end else begin
            wind_effect = 0;
        end
    end

    always_comb begin
        dog_in_range = (VER_PIXELS - y_pos >= CAT_TOP && VER_PIXELS - y_pos <= CAT_BOTTOM &&
                        HOR_PIXELS - x_pos <= CAT_X_RIGHT && HOR_PIXELS - x_pos >= CAT_X_LEFT);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            dog_in_range_d <= 0;
            hit_dog_reg <= 0;
        end else begin
            dog_in_range_d <= dog_in_range;
            
            if (dog_in_range && !dog_in_range_d) begin
                hit_dog_reg <= 1;
            end else begin
                hit_dog_reg <= 0;
            end
        end
    end

    assign hit_dog = hit_dog_reg;

    always_comb begin
        scaled_force = (throw_force * INIT_FORCE) >> 6;
        elapsed = ms_counter - time_0;
        elapsed_fall = ms_counter - time_0_fall;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            ms_counter <= 0;
        end else begin
            if (counter == 1299980) begin
                ms_counter <= ms_counter + 1;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            is_throwing <= 0;
            throw_done <= 0;
            state <= ST_IDLE;
            x_pos <= MOUSE_XPOS_DOG;
            y_pos <= MOUSE_YPOS_DOG;
            time_0 <= 0;
            time_0_fall <= 0;
            v_0 <= 0;
            v_temp <= 0;
            ypos_0 <= MOUSE_YPOS_DOG;
            xpos_0 <= MOUSE_XPOS_DOG;
            ypos_0_fall <= MOUSE_YPOS_DOG;
        end else begin
            case (state)
                ST_IDLE: begin
                    is_throwing <= 0;
                    throw_done <= 0;
                    x_pos <= MOUSE_XPOS_DOG;
                    y_pos <= MOUSE_YPOS_DOG;
                    if (enable) begin
                        state <= ST_THROW;
                        is_throwing <= 1;
                        time_0 <= ms_counter;
                        ypos_0 <= MOUSE_YPOS_DOG;
                        xpos_0 <= MOUSE_XPOS_DOG;
                        v_0 <= INITIAL_VELOCITY;
                        v_temp <= INITIAL_VELOCITY;
                    end
                end

                ST_THROW: begin
                    throw_done <= 0;
                    is_throwing <= 1;
                    v_temp <= v_0 - GRAVITY * elapsed;
                    y_pos <= ypos_0 + v_0 * elapsed - (GRAVITY * elapsed * elapsed) / 2;
                    x_pos <= xpos_0 + (scaled_force + wind_effect) * elapsed;
                    
                    if (v_temp <= 0) begin
                        state <= ST_FALL;
                        time_0_fall <= ms_counter;
                        ypos_0_fall <= y_pos;
                        xpos_0 <= x_pos;
                    end
                end

                ST_FALL: begin
                    throw_done <= 0;
                    is_throwing <= 1;
                    v_temp <= -GRAVITY * elapsed_fall;
                    y_pos <= ypos_0_fall - (GRAVITY * elapsed_fall * elapsed_fall) / 2;
                    x_pos <= xpos_0 + (scaled_force + wind_effect) * elapsed_fall;
                    
                    if (y_pos <= 190) begin
                        y_pos <= MOUSE_YPOS_DOG;
                        state <= ST_END;
                    end

                    if (VER_PIXELS - y_pos > WALL_TOP && HOR_PIXELS - x_pos <= WALL_X_RIGHT + 15 && HOR_PIXELS - x_pos >= WALL_X_LEFT - 15) begin
                        x_pos <= x_pos;
                    end

                    if(VER_PIXELS - y_pos <= WALL_TOP && VER_PIXELS - y_pos >= WALL_TOP - 15 && 
                       HOR_PIXELS - x_pos <= WALL_X_RIGHT + 15 && HOR_PIXELS - x_pos >= WALL_X_LEFT - 15) begin
                        state <= ST_END;
                    end
                end

                ST_END: begin
                    throw_done <= 1;
                    is_throwing <= 0;
                    x_pos <= MOUSE_XPOS_DOG;
                    y_pos <= MOUSE_YPOS_DOG;

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