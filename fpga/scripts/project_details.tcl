# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {

    ../rtl/vga_timing.sv
    ../rtl/vga_if.sv
    ../rtl/top_vga.sv
    ../rtl/health_bars.sv
    ../rtl/game_controller.sv
    ../rtl/keyboard/keyboard_controller.sv
    ../rtl/keyboard/PS2Receiver.sv
    ../rtl/throw/throw_ctl.sv
    ../rtl/throw/draw_projectile.sv
    ../rtl/draw_rectangle.sv
    ../rtl/turn_local_fsm.sv
    rtl/top_vga_basys3.sv
    ../rtl/background/vga_pkg.sv
    ../rtl/background/draw_bg.sv
    ../rtl/background/image_rom.sv
    ../rtl/players/draw_player_cat.sv
    ../rtl/players/draw_player_dog.sv
    ../rtl/players/image_rom_cat.sv
    ../rtl/players/image_rom_dog.sv

}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    rtl/clk_wiz_0_clk_wiz.v
    ../rtl/keyboard/debouncer.v
}

# Specify VHDL design files location            -- EDIT
# set vhdl_files {
#    path/to/file.vhd
# }

# Specify files for a memory initialization     -- EDIT
set mem_files {
   ../rtl/data/background/BG.dat
   ../rtl/data/players/cat_full.dat
   ../rtl/data/players/dog_full.dat
}
