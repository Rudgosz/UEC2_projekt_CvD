module throw_ctl (
    input  logic clk,          // 65 MHz clock
    input  logic rst,          // Active-high reset
    input  logic enable,       // Starts the throwing motion
    output logic [11:0] y_pos  // Y position (parabolic: 0 → 100 → 0)
);

// Fixed-point parameters (Q16.16 format)
localparam integer SCALE        = 16;           // Fractional bits
localparam integer GRAVITY      = 64;           // Gravity (0.0005 * 2^16)
localparam integer INIT_VEL     = 65536;        // Initial velocity (1.0 * 2^16)

// Internal signals (fixed-point)
logic signed [31:0] y_fixed;    // 16.16 format
logic signed [31:0] velocity;   // 16.16 format

// FSM states
typedef enum {IDLE, THROWING} state_t;
state_t state;

// Motion calculation (quadratic: y = v0*t - 0.5*g*t^2)
always_ff @(posedge clk) begin
    if (rst) begin
        state     <= IDLE;
        y_fixed   <= 0;
        velocity  <= 0;
        y_pos     <= 0;
    end else begin
        case (state)
            IDLE: begin
                y_pos <= 0;
                if (enable) begin
                    state    <= THROWING;
                    y_fixed  <= 0;
                    velocity <= INIT_VEL; // Initial upward velocity
                end
            end

            THROWING: begin
                // Update position: y += velocity
                y_fixed <= y_fixed + velocity;

                // Update velocity: v -= gravity
                velocity <= velocity - GRAVITY;

                // Extract integer position (clamp to 0 if negative)
                if ($signed(y_fixed) < 0) begin
                    y_pos <= 0;
                    state <= IDLE;
                end else begin
                    y_pos <= y_fixed >>> SCALE; // Convert to integer
                end
            end
        endcase
    end
end

endmodule