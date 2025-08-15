module turn_remote_fsm (
    input  logic clk,
    input  logic rst,
    input  logic space,
    input  logic cat_turn,
    output logic enable_draw,
    output logic [1:0] index,
    output logic throw_enable,
    output logic turn_done
);

    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SP1    = 2'b01,
        SP0    = 2'b10,
        SP0_2  = 2'b11
    } state_t;
    state_t state;

    localparam ONE_SECOND = 65000000;
    logic [31:0] counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            state        <= IDLE;
            enable_draw  <= 0;
            index        <= 0;
            throw_enable <= 0;
            counter      <= 0;
            turn_done    <= 0;
        end
        else begin

            if (!cat_turn) begin
                state        <= IDLE;
                enable_draw  <= 0;
                index        <= 0;
                throw_enable <= 0;
                counter      <= 0;
                turn_done    <= 0;
            end else begin
                
                case (state)
                    IDLE: begin
                        index        <= 0;
                        enable_draw  <= 0;
                        throw_enable <= 0;
                        counter      <= 0;
                        turn_done    <= 0;
                        if (space)
                            state <= SP1;
                        else
                            state <= IDLE;
                    end

                    SP1: begin
                        index        <= 1;
                        enable_draw  <= 1;
                        throw_enable <= 0;
                        counter      <= 0;
                        turn_done    <= 0;
                        if (!space)
                            state <= SP0;
                        else
                            state <= SP1;
                    end

                    SP0: begin
                        index        <= 2;
                        enable_draw  <= 0;
                        throw_enable <= 1;
                        turn_done    <= 0;
                        if (counter < ONE_SECOND-1) begin
                            counter <= counter + 1;
                            state   <= SP0;
                        end else begin
                            counter <= 0;
                            state   <= SP0_2;
                        end
                    end

                    SP0_2: begin
                        index        <= 2;
                        enable_draw  <= 0;
                        throw_enable <= 0;
                        counter      <= 0;
                        state        <= IDLE;
                        turn_done    <= 1;
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
