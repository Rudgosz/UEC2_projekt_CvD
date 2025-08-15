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
	output logic start_game
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
			state       <= START_SCREEN;
			cat_turn  <= 0;
			dog_turn  <= 0;
			start_game <= 0;
		end else begin
			case (state)

				START_SCREEN: begin
					if (enter_pressed_local) begin
						dog_turn <= 1;
						cat_turn  <= 0;
						start_game <= 1;
						state <= PLAYER_TURN;
					end else if (enter_pressed_remote) begin
						dog_turn <= 0;
						cat_turn  <= 1;
						start_game <= 1;
						state <= OPPONENT_TURN;
					end
				end

				PLAYER_TURN: begin
					dog_turn <= 1;
					cat_turn  <= 0;
					if (turn_done_dog) begin
						dog_turn <= 0;
						cat_turn  <= 1;
						state <= CHECK_WIN;
					end
				end

				OPPONENT_TURN: begin
					dog_turn <= 0;
					cat_turn  <= 1;
					if (turn_done_cat) begin
						dog_turn <= 1;
						cat_turn  <= 0;
						state <= CHECK_WIN;
					end
				end

				CHECK_WIN: begin
					if (hp_local == 0 || hp_remote == 0) begin
						state <= GAME_OVER;
					end else if (dog_turn) begin
						dog_turn <= 1;
						cat_turn  <= 0;
						state <= PLAYER_TURN;
					end else begin
						dog_turn <= 0;
						cat_turn  <= 1;
						state <= OPPONENT_TURN;
					end
				end

				GAME_OVER: begin
					dog_turn <= 0;
					cat_turn  <= 0;
					if (enter_pressed_local || enter_pressed_remote)
						state <= START_SCREEN;
				end

				default: begin
					state <= START_SCREEN;
					dog_turn <= 0;
					cat_turn  <= 0;
				end
			endcase
		end
	end


endmodule