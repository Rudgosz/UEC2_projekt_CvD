module health_bars (
    input  logic        clk,
    input  logic        rst,
    input  logic        hit_cat, // damage dla kota
    input  logic        hit_dog,
    output logic [11:0] rgb_bar,
    output logic        bar_on,
    output logic [9:0]  hp_cat,
    output logic [9:0]  hp_dog,
    vga_if.vga_in       vga_in,
    vga_if.vga_out      vga_out
);

localparam HEALTH_MAX = 500;
localparam DAMAGE = 50;

localparam Y_START = 6;
localparam Y_END = 26;

localparam CAT_X_START = 8;
localparam CAT_X_END = 508;

localparam DOG_X_START = 516;
localparam DOG_X_END = 1016;

localparam FRAME_X_START = 3;
localparam FRAME_X_END   = 1020;
localparam FRAME_Y_START = 3;
localparam FRAME_Y_END   = 29;

logic [9:0] health_cat;
logic [9:0] health_dog;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        health_cat <= HEALTH_MAX;
        health_dog <= HEALTH_MAX;
    end else begin
        if (hit_cat) begin
            if (health_cat > DAMAGE)
                health_cat <= health_cat - DAMAGE;
            else
                health_cat <= 0;
        end
        
        if (hit_dog) begin
            if (health_dog > DAMAGE)
                health_dog <= health_dog - DAMAGE;
            else
                health_dog <= 0;
        end
    end
end

assign hp_cat = health_cat;
assign hp_dog = health_dog;

always_comb begin
    rgb_bar = vga_in.rgb;
    bar_on = 0;


    if (vga_in.hcount >= FRAME_X_START && vga_in.hcount < FRAME_X_END &&
    vga_in.vcount >= FRAME_Y_START && vga_in.vcount < FRAME_Y_END) begin
    bar_on  = 1;
    rgb_bar = 12'hFF0; // żółty
    end

    if (vga_in.vcount >= Y_START && vga_in.vcount < Y_END &&
        vga_in.hcount >= (CAT_X_END - health_cat) && vga_in.hcount < CAT_X_END) begin
            bar_on = 1;
            rgb_bar = 12'hF00;
        end

    if (vga_in.vcount >= Y_START && vga_in.vcount < Y_END &&
        vga_in.hcount >= DOG_X_START && vga_in.hcount < (DOG_X_START + health_dog)) begin
            bar_on = 1;            
            rgb_bar = 12'hF00;
        end
    end

assign vga_out.hcount = vga_in.hcount;
assign vga_out.vcount = vga_in.vcount;
assign vga_out.hsync = vga_in.hsync;
assign vga_out.vsync = vga_in.vsync;
assign vga_out.hblnk = vga_in.hblnk;
assign vga_out.vblnk = vga_in.vblnk;
assign vga_out.rgb = bar_on ? rgb_bar : vga_in.rgb;

endmodule