/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

module top_vga (
        input  logic clk65MHz,
        input  logic rst,
        input  logic btnU,
        input  logic PS2Clk,
        input  logic PS2Data,
        input  logic SPACE_RX, 
        input  logic ENTER_RX, 
        output logic SPACE_TX, 
        output logic ENTER_TX, 
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    // VGA signals from timing
    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    // VGA signals from background
    vga_if vga_bg_if();

    // VGA signals from draw_player_dog
    vga_if vga_dog_if();

    // VGA signals from draw_player_cat
    vga_if vga_cat_if();

    // VGA signals from draw_rectangle
    vga_if vga_rect_if();

    // VGA signals form draw_projectile
    vga_if vga_projectile_if();

    // VGA signals from health_bars
    vga_if vga_hp_if();

    // Keyboard signals
    logic throw_keyboard_trigger;
    logic [7:0] throw_keyboard_power;

    //signals for draw_player_dog and dog_rom
    logic [14:0] dog_addr;
    logic [11:0] rgb_dog;
    logic [1:0]  dog_state;

    //signals for draw_player_cat and cat_rom
    logic [13:0] cat_addr;
    logic [11:0] rgb_cat;
    logic [1:0]  cat_state;

    //signals for game controller
    logic cat_turn, dog_turn;
    logic throw_command;
    logic cat_throw_complete, dog_throw_complete;
    logic [7:0] throw_power_out;

    logic [15:0] ps2_keycode;
    logic       ps2_key_valid;
    logic       space;
    logic       enable_draw;
    logic [1:0] state_dog;

    //signals for throw_ctl
    logic [11:0] x_pos;
    logic [11:0] y_pos;



    /**
     * Signals assignments
     */

    assign vs = vga_projectile_if.vsync;
    assign hs = vga_projectile_if.hsync;
    assign {r,g,b} = vga_projectile_if.rgb[11:0];

    assign throw_keyboard_trigger = space;

    logic [11:0] rgb_background;
    logic [19:0] bg_addr;

    logic rectangle_on;
    logic [11:0] rgb_rectangle;
    logic [9:0]  throw_force;


    logic bar_on;
    logic [11:0] rgb_bar;

    /**
     * Submodules instances
     */

    keyboard_controller u_keyboard (
        .clk(clk65MHz),
        .keycode(ps2_keycode),
        .space(space)
    );

    draw_rectangle u_draw_rectangle (
        .clk(clk65MHz),
        .rst(rst),
        .space(enable_draw),
        .rectangle_on(rectangle_on),
        .rgb_rectangle(rgb_rectangle),
        .throw_force(throw_force),
        .vga_in(vga_bg_if.vga_out),
        .vga_out(vga_rect_if.vga_out)
    );

    turn_local_fsm u_turn_local_fsm (
        .clk(clk65MHz),
        .rst(rst),
        .space(space),
        .enable_draw(enable_draw),
        .index(state_dog),
        .space_pin_tx(SPACE_TX),
        .throw_enable(throw_enable)
);

    PS2Receiver u_ps2_receiver (
        .clk        (clk65MHz),
        .kclk       (PS2Clk),
        .kdata      (PS2Data),
        .keycode    (ps2_keycode),
        .oflag()
    );

    vga_timing u_vga_timing (
        .clk    (clk65MHz),
        .rst,
        .vcount (vcount_tim),
        .vsync  (vsync_tim),
        .vblnk  (vblnk_tim),
        .hcount (hcount_tim),
        .hsync  (hsync_tim),
        .hblnk  (hblnk_tim)
    );

    game_controller u_game_controller (
        .clk(clk65MHz),
        .rst,
        .throw_trigger      (throw_keyboard_trigger),
        .throw_power        (throw_keyboard_power),
        .cat_throw_complete (cat_throw_complete),
        .dog_throw_complete (dog_throw_complete),
        .cat_turn           (cat_turn),
        .dog_turn           (dog_turn),
        .throw_command      (throw_command),
        .power_out          (throw_power_out)
    );

    draw_bg u_draw_bg (
        .clk(clk65MHz),
        .rst,

        .vcount_in  (vcount_tim),
        .vsync_in   (vsync_tim),
        .vblnk_in   (vblnk_tim),
        .hcount_in  (hcount_tim),
        .hsync_in   (hsync_tim),
        .hblnk_in   (hblnk_tim),
        .rgb_background (rgb_background),
        .bg_addr (bg_addr),

        .rectangle_on(rectangle_on),
        .rgb_rectangle(rgb_rectangle),

        .bar_on(bar_on),
        .rgb_bar(rgb_bar),

        .vga_out    (vga_bg_if.vga_out)

    );

    image_rom u_image_rom_background (
        .clk(clk65MHz),
        .address(bg_addr),
        .rgb(rgb_background)
    );

    draw_player_dog u_draw_player_dog (
        .clk(clk65MHz),
        .rst,

        .turn_active(dog_turn),
        .throw_command(throw_command),
        .throw_power(throw_power_out),
        .dog_state(dog_state),
        .throw_complete(dog_throw_complete),

        .rgb_dog(rgb_dog),
        .dog_addr(dog_addr),
        .vga_in     (vga_rect_if.vga_in),
        .vga_out    (vga_dog_if.vga_out)
    );

    image_rom_dog u_image_rom_dog (
        .clk(clk65MHz),
        .address(dog_addr),
        .rgb(rgb_dog),
        .state(state_dog)
    );


    draw_player_cat u_draw_player_cat (
        .clk(clk65MHz),
        .rst,

        .turn_active(cat_turn),
        .throw_command(throw_command),
        .throw_power(throw_power_out),
        .cat_state(cat_state),
        .throw_complete(cat_throw_complete),

        .rgb_cat(rgb_cat),
        .cat_addr(cat_addr),
        .vga_in     (vga_dog_if.vga_in),
        .vga_out    (vga_cat_if.vga_out)
    );

    image_rom_cat u_image_rom_cat (
        .clk(clk65MHz),
        .address(cat_addr),
        .rgb(rgb_cat)
    );

    throw_ctl u_throw_ctl (
        .clk(clk65MHz),
        .rst(rst),
        .enable(throw_enable),
        .throw_force(throw_force),
        .x_pos(x_pos),
        .y_pos(y_pos)
    );

    draw_projectile u_draw_projectile (
        .clk(clk65MHz),
        .rst(rst),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .vga_in(vga_hp_if.vga_in),
        .vga_out(vga_projectile_if.vga_out)
    );

    health_bars u_health_bars(
        .clk(clk65MHz),
        .rst(rst),
        .hit_cat(),
        .hit_dog(),
        .hp_cat(),
        .hp_dog(),
        .bar_on(bar_on),
        .rgb_bar(rgb_bar),
        .vga_in(vga_cat_if.vga_in),
        .vga_out(vga_hp_if.vga_out)
    );
    
endmodule