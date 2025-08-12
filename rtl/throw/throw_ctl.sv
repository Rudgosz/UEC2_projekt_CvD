`timescale 1 ns / 1 ps

module throw_ctl (
    input logic clk,
    input logic enable,
    input logic rst,
    output logic signed [11:0] x_pos,
    output logic signed [11:0] y_pos
);

    // Physics constants (adjust units as needed)
    localparam int INITIAL_VELOCITY = 20;    // initial velocity (units per ms tick)
    localparam int GRAVITY = 1;             // gravity acceleration (units per ms^2)
    localparam int MOUSE_XPOS = 400;
    localparam int MOUSE_YPOS = 101;
    localparam int IMAGE_Y_END = 700;

    int counter;
    int ms_counter;

    logic signed [11:0] ypos_0, xpos_0, ypos_0_fall;
    int time_0;
    int signed v_0;
    int signed v_temp;

    typedef enum logic [1:0] {ST_IDLE, ST_THROW, ST_FALL, ST_END} state_t;
    state_t state;

    // Clock divider to generate ms_counter (approx 1.3 ms increments)
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
                    int elapsed = ms_counter - time_0;
                    // Update velocity and position
                    v_temp <= v_0 - GRAVITY * elapsed;
                    y_pos <= ypos_0 + v_0 * elapsed - (GRAVITY * elapsed * elapsed) / 2;
                    x_pos <= xpos_0;

                    if (v_temp <= 0) begin
                        // Switch to falling phase
                        state <= ST_FALL;
                        time_0 <= ms_counter;
                        ypos_0_fall <= y_pos;
                    end
                end

                ST_FALL: begin
                    int elapsed = ms_counter - time_0;
                    // Falling velocity (downwards)
                    v_temp <= -GRAVITY * elapsed;
                    y_pos <= ypos_0_fall - (GRAVITY * elapsed * elapsed) / 2;
                    x_pos <= xpos_0;

                    // Stop falling once it reaches or passes initial y (ground)
                    if (y_pos <= MOUSE_YPOS) begin
                        y_pos <= MOUSE_YPOS;
                        state <= ST_END;
                    end
                end

                ST_END: begin
                    // Hold position at ground until reset or disable
                    x_pos <= xpos_0;
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
