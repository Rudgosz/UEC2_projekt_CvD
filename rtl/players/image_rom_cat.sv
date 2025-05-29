module image_rom_cat (
        input  logic clk ,
        input  logic [13:0] address,
        output logic [11:0] rgb
    );


    /**
     * Local variables and signals
     */

    reg [11:0] rom [0:12869];

    

    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh("../../rtl/data/players/cat_throw.dat", rom);


    /**
     * Internal logic
     */

    always_ff @(posedge clk)
        rgb <= rom[address];

endmodule