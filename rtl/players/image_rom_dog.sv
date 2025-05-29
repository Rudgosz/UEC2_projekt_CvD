module image_rom_dog (
        input  logic clk ,
        input  logic [14:0] address,
        output logic [11:0] rgb
    );


    /**
     * Local variables and signals
     */

    reg [11:0] rom [0:24779];

    

    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh("../../rtl/data/players/dog_throw.dat", rom);


    /**
     * Internal logic
     */

    always_ff @(posedge clk)
        rgb <= rom[address];

endmodule