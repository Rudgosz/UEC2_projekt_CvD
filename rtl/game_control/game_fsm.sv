module game_fsm (
    input  logic clk,
    input  logic rst,
    input  logic enter_pressed_local,
    input  logic enter_pressed_remote,
    input  logic turn_done_cat,
    input  logic turn_done_dog,
    input  logic [9:0] hp_local,
    input  logic [9:0] hp_remote,
    output logic dog_turn,
    output logic cat_turn,
    output logic [2:0] state_game_fsm,
    output logic next_turn,
    output logic enter_start_remote,
    output logic reset_hp
);

    typedef enum logic [2:0] {
        START_SCREEN   = 3'b000,
        PLAYER_TURN    = 3'b001,
        OPPONENT_TURN  = 3'b010,
        CHECK_WIN      = 3'b011,
        GAME_OVER      = 3'b100
    } state_t;
    
    state_t state;

    assign state_game_fsm = state;

    always_ff @(posedge clk) begin
        if (rst) begin
            enter_start_remote <= 0;
            state       <= START_SCREEN;
            cat_turn    <= 0;
            dog_turn    <= 0;
            next_turn   <= 0;
            reset_hp    <= 0;
        end else begin
            case (state)
                START_SCREEN: begin
                    reset_hp    <= 1;
                    next_turn   <= 0;
                    if (enter_pressed_local) begin
                        reset_hp    <= 0;
                        dog_turn   <= 1;
                        cat_turn   <= 0;
                        state      <= PLAYER_TURN;
                    end else if (enter_pressed_remote) begin
                        reset_hp    <= 0;
                        enter_start_remote <= 1;
                        dog_turn   <= 0;
                        cat_turn   <= 1;
                        state      <= OPPONENT_TURN;
                    end
                end

                PLAYER_TURN: begin
                    enter_start_remote <= 0;
                    next_turn   <= 1;
                    if (turn_done_dog) begin
                        state <= CHECK_WIN;
                    end
                end

                OPPONENT_TURN: begin
                    enter_start_remote <= 0;
                    next_turn   <= 1;
                    if (turn_done_cat) begin
                        state <= CHECK_WIN;
                    end
                end

                CHECK_WIN: begin
                    enter_start_remote <= 0;
                    next_turn   <= 0;
                    // Sprawdź warunek zakończenia gry przed zmianą tury
                    if (hp_local == 0 || hp_remote == 0) begin
                        state <= GAME_OVER;
                    end else if (cat_turn) begin
                        dog_turn <= 1;
                        cat_turn <= 0;
                        state    <= PLAYER_TURN;
                    end else begin
                        dog_turn <= 0;
                        cat_turn <= 1;
                        state    <= OPPONENT_TURN;
                    end
                end

                GAME_OVER: begin
                    enter_start_remote <= 0;
                    next_turn   <= 0;
                    dog_turn <= 0;
                    cat_turn <= 0;
                    if (enter_pressed_local || enter_pressed_remote) begin
                        state      <= START_SCREEN;
                    end
                end

                default: begin
                    state    <= START_SCREEN;
                    dog_turn <= 0;
                    cat_turn <= 0;
                end
            endcase
        end
    end
endmodule