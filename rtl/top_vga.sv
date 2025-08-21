/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Cat vs Dog - UEC2 Final Project
 *
 *  Maciej Rogoż, Artur Sadłoń
 */

module top_vga (
        input  logic clk65MHz,
        input  logic rst,
        input  logic btn_space_remote,
        input  logic btn_enter_remote,
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
    vga_if vga_rect_dog_if();
    vga_if vga_rect_cat_if();

    // VGA signals form draw_projectile
    vga_if vga_projectile_dog_if();
    
    vga_if vga_projectile_cat_if();
    vga_if vga_projectile_dog_reg_if();

    // VGA signals from health_bars
    vga_if vga_hp_if();

    // VGA signals from draw_start
    vga_if vga_start_if();
     
    // VGA signals from draw_over
    vga_if vga_over_if();

    //VGA signals from draw_wind
    vga_if vga_wind_if();

    //VGA signals from draw_wind_background
    vga_if vga_wind_bg_if();

    //signals for draw_player_dog and dog_rom
    logic [14:0] dog_addr;
    logic [11:0] rgb_dog;

    //signals for draw_player_cat and cat_rom
    logic [13:0] cat_addr;
    logic [11:0] rgb_cat;

    //signals for game controller
    logic cat_turn, dog_turn;

    // Keyboard signals
    logic [15:0] ps2_keycode;
    logic       space;
    logic       enter;
    logic space_remote;
    logic enter_remote;
    
    logic       enable_draw_cat;
    logic       enable_draw_dog;
    logic [1:0] state_dog;
    logic [1:0] state_cat;

    //signals for throw_ctl
    logic [11:0] x_pos_dog;
    logic [11:0] y_pos_dog;

    logic [11:0] x_pos_cat;
    logic [11:0] y_pos_cat;

    logic [6:0] wind_force;





    /**
     * Signals assignments
     */

    assign vs = vga_start_if.vsync;
    assign hs = vga_start_if.hsync;
    assign {r,g,b} = vga_start_if.rgb[11:0];

    assign SPACE_TX = space;
    assign ENTER_TX = enter;

    assign space_remote = SPACE_RX || btn_space_remote;
    assign enter_remote = ENTER_RX || btn_enter_remote;


    logic [11:0] rgb_background;
    logic [19:0] bg_addr;

    logic [19:0] start_addr;
    logic [11:0] rgb_start;

    logic [19:0] over_addr;
    logic [11:0] rgb_over;

    logic [9:0]  throw_force_dog;
    logic [9:0]  throw_force_cat;


    logic bar_on;
    logic [11:0] rgb_bar;

    logic [9:0] hp_local;
    logic [9:0] hp_remote;

    logic throw_enable_dog;
    logic throw_enable_cat;

    logic turn_done_remote;
    logic turn_done_local;

    logic hit_cat;
    logic hit_dog;

    logic [2:0] game_state;

    logic next_turn;
    logic enter_start_remote;
    logic reset_hp;

    logic is_throwing_dog;
    logic is_throwing_cat;


    /**
     * Submodules instances
     */


    game_fsm u_game_fsm (
        .clk(clk65MHz),
        .rst(rst),
        .enter_pressed_local    (enter),
        .enter_pressed_remote   (enter_remote),
        .turn_done_cat          (turn_done_remote),
        .turn_done_dog          (turn_done_local),
        .hp_local               (hp_local),
        .hp_remote              (hp_remote),
        .dog_turn               (dog_turn),
        .cat_turn               (cat_turn),
        .state_game_fsm         (game_state),
        .next_turn              (next_turn),
        .enter_start_remote     (enter_start_remote),
        .reset_hp               (reset_hp)
    );

    turn_local_fsm u_turn_local_fsm (
        .clk            (clk65MHz),
        .rst            (rst),
        .dog_turn       (dog_turn),
        .space          (space),
        .enable_draw    (enable_draw_dog),
        .index          (state_dog),
        .throw_enable   (throw_enable_dog)
    );

    turn_remote_fsm u_turn_remote_fsm (
        .clk            (clk65MHz),
        .rst            (rst),
        .cat_turn       (cat_turn),
        .enable_draw    (enable_draw_cat),
        .space          (space_remote),
        .index          (state_cat),
        .throw_enable   (throw_enable_cat)
    );

    keyboard_controller u_keyboard (
        .clk        (clk65MHz),
        .keycode    (ps2_keycode),
        .space      (space),
        .enter      (enter)
    );

    draw_start u_draw_start (
        .clk        (clk65MHz),
        .rst        (rst),
        .game_state (game_state),
        .rgb_start  (rgb_start),
        .start_addr (start_addr),
        .vga_in     (vga_over_if.vga_in),
        .vga_out    (vga_start_if.vga_out)
    );

    draw_over u_draw_over (
        .clk        (clk65MHz),
        .rst        (rst),
        .game_state (game_state),
        .rgb_over   (rgb_over),
        .over_addr  (over_addr),
        .vga_in     (vga_wind_if.vga_in),
        .vga_out    (vga_over_if.vga_out)
    );

    draw_rectangle_cat u_draw_rectangle_cat (
        .clk            (clk65MHz),
        .rst            (rst),
        .space          (enable_draw_cat),
        .throw_force    (throw_force_cat),
        .vga_in         (vga_rect_dog_if.vga_in),
        .vga_out        (vga_rect_cat_if.vga_out)
    );

    draw_rectangle_dog u_draw_rectangle_dog (
        .clk            (clk65MHz),
        .rst            (rst),
        .space          (enable_draw_dog),
        .throw_force    (throw_force_dog),
        .vga_in         (vga_bg_if.vga_in),
        .vga_out        (vga_rect_dog_if.vga_out)
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

    

    draw_bg u_draw_bg (
        .clk(clk65MHz),
        .rst,

        .vcount_in          (vcount_tim),
        .vsync_in           (vsync_tim),
        .vblnk_in           (vblnk_tim),
        .hcount_in          (hcount_tim),
        .hsync_in           (hsync_tim),
        .hblnk_in           (hblnk_tim),
        .rgb_background     (rgb_background),
        .bg_addr            (bg_addr),

        .bar_on             (bar_on),
        .rgb_bar            (rgb_bar),

        .vga_out            (vga_bg_if.vga_out)

    );

    image_rom u_image_rom_background (
        .clk        (clk65MHz),
        .address    (bg_addr),
        .rgb        (rgb_background)
    );

    start_rom u_start_rom (
        .clk        (clk65MHz),
        .address    (start_addr),
        .rgb        (rgb_start)
    );
    
    over_rom u_over_rom (
        .clk        (clk65MHz),
        .address    (over_addr),
        .rgb        (rgb_over)
    );

    draw_player_dog u_draw_player_dog (
        .clk            (clk65MHz),
        .rst            (rst),
        .hit_dog        (hit_dog),

        .rgb_dog        (rgb_dog),
        .dog_addr       (dog_addr),
        .vga_in         (vga_rect_cat_if.vga_in),
        .vga_out        (vga_dog_if.vga_out)
    );

    image_rom_dog u_image_rom_dog (
        .clk        (clk65MHz),
        .address    (dog_addr),
        .rgb        (rgb_dog),
        .state      (state_dog)
    );


    draw_player_cat u_draw_player_cat (
        .clk            (clk65MHz),
        .rst            (rst),
        .hit_cat        (hit_cat),

        .rgb_cat        (rgb_cat),
        .cat_addr       (cat_addr),
        .vga_in         (vga_dog_if.vga_in),
        .vga_out        (vga_cat_if.vga_out)
    );

    image_rom_cat u_image_rom_cat (
        .clk        (clk65MHz),
        .address    (cat_addr),
        .state      (state_cat),
        .rgb        (rgb_cat)
    );

    throw_ctl_dog u_throw_ctl_dog (
        .clk            (clk65MHz),
        .rst            (rst),
        .enable         (throw_enable_dog),
        .throw_force    (throw_force_dog),
        .x_pos          (x_pos_dog),
        .y_pos          (y_pos_dog),
        .hit_dog        (hit_cat),
        .wind_force     (wind_force),
        .throw_done     (turn_done_local),
        .is_throwing    (is_throwing_dog)
    );

    throw_ctl_cat u_throw_ctl_cat (
        .clk            (clk65MHz),
        .rst            (rst),
        .enable         (throw_enable_cat),
        .throw_force    (throw_force_cat),
        .x_pos          (x_pos_cat),
        .y_pos          (y_pos_cat),
        .hit_cat        (hit_dog),
        .wind_force     (wind_force),
        .throw_done     (turn_done_remote),
        .is_throwing    (is_throwing_cat)
    );

    draw_projectile_dog u_draw_projectile_dog (
        .clk        (clk65MHz),
        .rst        (rst),
        .active     (is_throwing_dog),
        .x_pos      (x_pos_dog),
        .y_pos      (y_pos_dog),
        .vga_in     (vga_wind_bg_if.vga_in),
        .vga_out    (vga_projectile_dog_if.vga_out)
    );

    

    draw_projectile_cat u_draw_projectile_cat (
        .clk        (clk65MHz),
        .rst        (rst),
        .active     (is_throwing_cat),
        .x_pos      (x_pos_cat),
        .y_pos      (y_pos_cat),
        .vga_in     (vga_projectile_dog_if.vga_in),
        .vga_out    (vga_projectile_cat_if.vga_out)
    );

    health_bars u_health_bars(
        .clk            (clk65MHz),
        .rst            (rst),
        .hit_cat        (hit_cat),
        .hit_dog        (hit_dog),
        .hp_cat         (hp_remote),
        .hp_dog         (hp_local),
        .reset_hp       (reset_hp),
        .bar_on         (bar_on),
        .rgb_bar        (rgb_bar),
        .vga_in         (vga_cat_if.vga_in),
        .vga_out        (vga_hp_if.vga_out)
    );

    draw_wind u_draw_wind (
        .clk            (clk65MHz),
        .rst            (rst),
        .wind_force     (wind_force),
        .vga_in         (vga_projectile_cat_if.vga_in),
        .vga_out        (vga_wind_if.vga_out)
    );

    draw_wind_background u_draw_wind_background (
        .clk            (clk65MHz),
        .rst            (rst),
        .vga_in         (vga_hp_if.vga_in),
        .vga_out        (vga_wind_bg_if.vga_out)
    );

    wind_ctl u_wind_ctl (
        .clk                (clk65MHz),
        .rst                (rst),
        .enter_start_remote (enter_start_remote),
        .next_turn          (next_turn),
        .wind               (wind_force)
    );
    
endmodule