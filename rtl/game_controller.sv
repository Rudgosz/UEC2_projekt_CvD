    module game_controller (

        input  logic clk,
        input  logic rst,
        input  logic throw_button, // przycisk do rzucania
        input  logic cat_throw_complete,
        input  logic dog_throw_complete,
        output logic cat_turn,
        output logic dog_turn,
        output logic throw_command // komenda rzutu dla tego co ma ture
        
    );

    timeunit 1ns;
    timeprecision 1ps;

    typedef enum {CAT_TURN, DOG_TURN, TRANSITION} game_state_t;

    game_state_t state, state_nxt;
    logic [23:0] transition_timer;
    logic        throw_prev;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= CAT_TURN;
            throw_prev <= 0;
            transition_timer <= 0;
        end else begin
            state <= state_nxt;
            throw_prev <= throw_button;

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
    assign throw_command = throw_button && !throw_prev && (state != TRANSITION);

    endmodule