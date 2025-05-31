module image_rom_cat (
        input  logic clk ,
        input  logic [13:0] address,
        input  logic [1:0]  state,
        output logic [11:0] rgb
    );


    /**
     * Local variables and signals
     */

    reg [11:0] rom [0:12869];
    reg [11:0] rom_throw1 [0:12869];
    reg [11:0] rom_throw2 [0:12869];

    

    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh("../../rtl/data/players/cat_throw.dat", rom);
    initial $readmemh("../../rtl/data/players/cat_throw.dat", rom_throw1);
    initial $readmemh("../../rtl/data/players/cat_throw.dat", rom_throw2);

// TU DAC ODPOWIEDNIE PLIKI .DAT

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin
        case(state)
        2'b00: rgb <= rom[address];
        2'b01: rgb <= rom_throw1[address];
        2'b10: rgb <= rom_throw2[address];
        default: rgb <= rom[address];
        endcase
    end

endmodule