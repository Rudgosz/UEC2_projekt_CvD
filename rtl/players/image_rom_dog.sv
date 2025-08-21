/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

module image_rom_dog (
        input  logic clk ,
        input  logic [14:0] address,
        input  logic [1:0]  state,
        output logic [11:0] rgb
    );


    /**
     * Local variables and signals
     */


    localparam int IMAGE_SIZE = 21140;
    localparam int TOTAL_SIZE = 3 * IMAGE_SIZE;


    reg [11:0] rom [0:TOTAL_SIZE-1];

    

    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh("../../rtl/data/players/dog_full.dat", rom);



    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin
        rgb <= rom[address + state * IMAGE_SIZE];
    end

endmodule