    module game_controller (

        input  logic clk,
        input  logic rst,
    //    input  logic throw_button, // przycisk do rzucania
        input  logic throw_trigger,
        input  logic [7:0] throw_power,
        input  logic cat_throw_complete,
        input  logic dog_throw_complete,
        output logic cat_turn,
        output logic dog_turn,
        output logic throw_command, // komenda rzutu dla tego co ma ture
        output logic [7:0] power_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    typedef enum {CAT_TURN, DOG_TURN, TRANSITION} game_state_t;

    game_state_t state, state_nxt;
    logic [23:0] transition_timer;
    logic        throw_trigger_prev;

    logic [7:0]  throw_power_reg;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= CAT_TURN;
            throw_trigger_prev <= 0;
            transition_timer <= 0;
            throw_power_reg <= 0;
        end else begin
            state <= state_nxt;
            throw_trigger_prev <= throw_trigger;

            if (throw_trigger && !throw_trigger_prev) begin
                throw_power_reg <= throw_power;
            end

            if (state == TRANSITION) begin
                transition_timer <= transition_timer + 1;
            end else begin
                transition_timer <= 0;
            end
        end
    end

    always_comb begin
        state_nxt = state;
        case (state)
            CAT_TURN: if(cat_throw_complete) state_nxt = TRANSITION;
            DOG_TURN: if(dog_throw_complete) state_nxt = TRANSITION;
            TRANSITION: if(transition_timer > 2000000)
                state_nxt = (state == CAT_TURN) ? DOG_TURN : CAT_TURN;
        endcase
    end

    assign cat_turn = (state == CAT_TURN);
    assign dog_turn = (state == DOG_TURN);
    assign throw_command = throw_trigger && !throw_trigger_prev && (state != TRANSITION);
    assign power_out = throw_power_reg;

    endmodule