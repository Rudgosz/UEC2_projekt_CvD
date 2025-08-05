module throw_ctl (
    input  logic clk,
    input  logic rst,
    input  logic enable,
    output logic [11:0] y_pos,
    output logic [11:0] x_pos    
);

    // Parameters
    localparam integer GRAVITY      = 10;
    localparam integer INIT_VEL_Y   = 100;
    localparam integer BASE_SPEED_X = 100;
    localparam integer WIND         = 100;
    localparam integer SLOWDOWN     = 16; // Universal slow-motion factor

    // Internal registers
    logic [11:0] y;
    logic [11:0] x;
    logic [15:0] vel_y;
    logic [7:0]  speed_x;
    logic        falling;
    logic [7:0]  tick_count;

    // FSM
    typedef enum logic [1:0] {IDLE, THROWING} state_t;
    state_t state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            y_pos      <= 0;
            x_pos      <= 0;
            y          <= 0;
            x          <= 0;
            vel_y      <= 0;
            speed_x    <= 0;
            falling    <= 0;
            tick_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    y_pos      <= 0;
                    x_pos      <= 0;
                    y          <= 0;
                    x          <= 0;
                    vel_y      <= INIT_VEL_Y;
                    falling    <= 0;
                    tick_count <= 0;

                    if (enable) begin
                        state <= THROWING;

                        // Compute wind-based x speed
                        if (WIND < 50)
                            speed_x <= BASE_SPEED_X - ((50 - WIND) / 25);
                        else if (WIND > 50)
                            speed_x <= BASE_SPEED_X + ((WIND - 50) / 25);
                        else
                            speed_x <= BASE_SPEED_X;
                    end
                end

                THROWING: begin
                    tick_count <= tick_count + 1;

                    if (tick_count >= SLOWDOWN) begin
                        tick_count <= 0;

                        // Vertical motion
                        if (!falling) begin
                            y <= y + vel_y;
                            if (vel_y > GRAVITY)
                                vel_y <= vel_y - GRAVITY;
                            else begin
                                vel_y <= 0;
                                falling <= 1;
                            end
                        end else begin
                            if (y > vel_y)
                                y <= y - vel_y;
                            else
                                y <= 0;

                            vel_y <= vel_y + GRAVITY;

                            if (y <= 1)
                                state <= IDLE;
                        end

                        // Horizontal motion
                        x <= x + speed_x;

                        // Outputs
                        y_pos <= y;
                        x_pos <= x;
                    end
                end
            endcase
        end
    end
endmodule
