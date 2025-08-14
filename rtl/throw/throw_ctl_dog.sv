`timescale 1 ns / 1 ps

module throw_ctl_dog (
    input  logic clk,
    input  logic enable,
    input  logic rst,
    input  logic [9:0] throw_force,
    output logic signed [11:0] x_pos,
    output logic signed [11:0] y_pos,
    output logic hit_dog
);

    import vga_pkg::*;

    localparam int INITIAL_VELOCITY = 27;
    localparam int GRAVITY = 1;
    localparam int MOUSE_XPOS_DOG = 140;
    localparam int MOUSE_YPOS_DOG = 350;
    localparam int IMAGE_Y_END = 700;

    localparam int INIT_FORCE = 18;
    localparam int WIND = 50;


    localparam WALL_X_LEFT = 490;
    localparam WALL_X_RIGHT = 534;
    localparam WALL_TOP = 241;
    localparam WALL_BOTTOM = 768;

    localparam DOG_X_LEFT = 800;
    localparam DOG_X_RIGHT = 850;
    localparam DOG_TOP = 427;
    localparam DOG_BOTTOM = 525;
    
    

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

    logic hit_dog_reg;
    logic dog_in_range;
    logic dog_in_range_d;

    always_comb begin
        dog_in_range = (VER_PIXELS - y_pos >= DOG_TOP && VER_PIXELS - y_pos <= DOG_BOTTOM &&
                        HOR_PIXELS - x_pos <= DOG_X_RIGHT && HOR_PIXELS - x_pos >= DOG_X_LEFT);
    end

    always_ff @(posedge clk or posedge rst) begin
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
            x_pos <= MOUSE_XPOS_DOG;
            y_pos <= MOUSE_YPOS_DOG;
            time_0 <= 0;
            v_0 <= 0;
            v_temp <= 0;
            ypos_0 <= MOUSE_YPOS_DOG;
            xpos_0 <= MOUSE_XPOS_DOG;
            ypos_0_fall <= MOUSE_YPOS_DOG;
        end else begin
            case (state)
                ST_IDLE: begin
                    x_pos <= MOUSE_XPOS_DOG;
                    y_pos <= MOUSE_YPOS_DOG;
                    if (enable) begin
                        state <= ST_THROW;
                        time_0 <= ms_counter;
                        ypos_0 <= MOUSE_YPOS_DOG;
                        xpos_0 <= MOUSE_XPOS_DOG;
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
                        y_pos <= MOUSE_YPOS_DOG;
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
                    x_pos <= MOUSE_XPOS_DOG;
                    y_pos <= MOUSE_YPOS_DOG;

                    if (!enable) begin
                        state <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
