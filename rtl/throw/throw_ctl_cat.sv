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
    output logic throw_done
);

    import vga_pkg::*;

    localparam int INITIAL_VELOCITY = 27;
    localparam int GRAVITY = 1;
    localparam int MOUSE_XPOS_CAT = 140;
    localparam int MOUSE_YPOS_CAT = 350;

    localparam int INIT_FORCE = 18;

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

    // Zoptymalizowane obliczenia efektu wiatru
    always_comb begin
        if (wind_force > 50) begin
            wind_effect = -5 - ((wind_force - 50) >> 3); // ~/8 zamiast /50 *5
        end else if (wind_force < 50) begin
            wind_effect = 5 + ((50 - wind_force) >> 3);  // ~/8 zamiast /50 *5
        end else begin
            wind_effect = 0;
        end
    end

    // Proste sprawdzenie zakresu psa
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

    // Zoptymalizowane obliczenia siły i czasu
    always_comb begin
        scaled_force_cat = (throw_force * INIT_FORCE) >> 6; // Przybliżenie /100 przez >>6 (64)
        elapsed_cat = ms_counter_cat - time_0_cat;
        elapsed_cat_fall = ms_counter_cat - time_0_fall_cat;
    end

    // Licznik czasu - zoptymalizowany (mniejsza stała)
    always_ff @(posedge clk) begin
        if (rst) begin
            counter_cat <= 0;
            ms_counter_cat <= 0;
        end else begin
            if (counter_cat == 1299980) begin // Zmniejszona stała dla szybszego symulowania
                ms_counter_cat <= ms_counter_cat + 1;
                counter_cat <= 0;
            end else begin
                counter_cat <= counter_cat + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            throw_done <= 0;
            state <= ST_IDLE;
            x_pos <= MOUSE_XPOS_CAT;
            y_pos <= MOUSE_YPOS_CAT;
            time_0_cat <= 0;
            time_0_fall_cat <= 0;
            v_0_cat <= 0;
            v_temp_cat <= 0;
            ypos_0 <= MOUSE_YPOS_CAT;
            xpos_0 <= MOUSE_XPOS_CAT;
            ypos_0_fall <= MOUSE_YPOS_CAT;
        end else begin
            case (state)
                ST_IDLE: begin
                    throw_done <= 0;
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
                    throw_done <= 0;
                    v_temp_cat <= v_0_cat - (GRAVITY * elapsed_cat);
                    // Uproszczone obliczenia pozycji - przesunięcie bitowe zamiast dzielenia
                    y_pos <= ypos_0 + (v_0_cat * elapsed_cat) - ((GRAVITY * elapsed_cat * elapsed_cat) >> 1);
                    x_pos <= xpos_0 + (scaled_force_cat + wind_effect) * elapsed_cat;
                    
                    if (v_temp_cat <= 0) begin
                        state <= ST_FALL;
                        time_0_fall_cat <= ms_counter_cat;
                        ypos_0_fall <= y_pos;
                        xpos_0 <= x_pos;
                    end
                end

                ST_FALL: begin
                    throw_done <= 0;
                    v_temp_cat <= -(GRAVITY * elapsed_cat_fall);
                    // Uproszczone obliczenia pozycji
                    y_pos <= ypos_0_fall - ((GRAVITY * elapsed_cat_fall * elapsed_cat_fall) >> 1);
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
                    throw_done <= 1;
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