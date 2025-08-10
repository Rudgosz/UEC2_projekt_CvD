module turn_local_fsm (
    input  logic clk,
    input  logic rst,
    input  logic space,
    output logic enable_draw,
    output logic [1:0] index,
    output logic space_pin_tx,
    output logic throw_enable
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

    always_ff @(posedge clk) begin : seq_blk
        if (rst) begin : seq_rst_blk
            state  <= IDLE;
            enable_draw  <= 0;
            index  <= 0;
            throw_enable  <= 0;
            counter <= 0;
            space_pin_tx <= 0;
        end
        else begin : seq_run_blk
            case (state)
                IDLE: begin
                    enable_draw <= 0;
                    index <= 0;
                    space_pin_tx   <= 0;
                    throw_enable <= 0;
                    counter <= 0;
                    if (space)
                        state <= SP1;
                    else
                        state <= IDLE;
                end

                SP1: begin
                    enable_draw <= 1;
                    index <= 1;
                    space_pin_tx   <= 1;
                    throw_enable <= 0;
                    counter <= 0;
                    if (!space)
                        state <= SP0;
                    else
                        state <= SP1;
                end

                SP0: begin
                    enable_draw <= 0;
                    index <= 2;
                    space_pin_tx   <= 0;
                    throw_enable <= 1;
                    if (counter < ONE_SECOND-1) begin
                        counter <= counter + 1;
                        state <= SP0;
                    end else begin
                        counter <= 0;
                        state <= SP0_2;
                    end
                end

                SP0_2: begin
                    enable_draw <= 0;
                    index <= 2;
                    space_pin_tx   <= 0;
                    throw_enable <= 0;
                    counter <= 0;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule