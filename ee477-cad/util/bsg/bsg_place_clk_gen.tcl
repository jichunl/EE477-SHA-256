#bsg_place_clk_gen clk_gen_core_inst 2360 567
#bsg_place_clk_gen clk_gen_iom_inst  2700 800

proc bsg_place_clk_gen { name base_x base_y } {

puts "## Movebounding clock generator ${name}"

if {[sizeof_collection [get_flat_cells -quiet $name/clk_gen_osc_inst/btc/blss/*]] == 0} {
    puts "## skipping clock generator placement; missing cell"
    return
}

#bsg_bound_creator $name/clk_gen_osc_inst/btc [expr $base_x+80]  $base_y 55 78
bsg_silent_remove_bounds $name/clk_gen_osc_inst/btc
create_bounds -name $name/clk_gen_osc_inst/btc -type hard -coordinate [list [expr $base_x+80] $base_y [expr $base_x+135] [expr $base_y + 45]] [get_flat_cells -quiet ${name}/clk_gen_osc_inst/btc/* -filter undefined(rp_group_name)]
update_bounds -name $name/clk_gen_osc_inst/btc -add [get_flat_cells -quiet $name/clk_gen_osc_inst/btc/blss/*]
bsg_bound_creator $name/mux_inst [expr $base_x+40] $base_y 40 36
bsg_bound_creator $name/clk_gen_osc_inst     $base_x            $base_y 135 82
bsg_bound_creator $name/clk_gen_ds_inst  [expr $base_x+135] $base_y 75  82
bsg_bound_creator $name/btc_ds           [expr $base_x+205] $base_y 60  82

# unnecessary; above covers all gates
# bsg_bound_creator $name                  [expr $base_x-10]  [expr $base_y-10] 275 100

# iom
puts "## adding compression to components"
set_rp_group_options [get_attribute $name/clk_gen_osc_inst/adt/M1 rp_group_name] -placement_type compression
set_rp_group_options [get_attribute $name/clk_gen_osc_inst/cdt/M1 rp_group_name]  -placement_type compression


puts "## combining fdt and cdt"
create_rp_group ${name}_gen_fdt_cdt -design bsg_chip -columns 5 -rows 1
add_to_rp_group bsg_chip::${name}_gen_fdt_cdt -hier [get_attribute $name/clk_gen_osc_inst/fdt/I4_3 rp_group_name] -column 0 -row 0
add_to_rp_group bsg_chip::${name}_gen_fdt_cdt -hier [get_attribute $name/clk_gen_osc_inst/cdt/M1 rp_group_name] -column 1 -row 0

puts "## adding osc bsg_client receive"
add_to_rp_group bsg_chip::${name}_gen_fdt_cdt -hier [get_attribute $name/clk_gen_osc_inst/btc/z_recv/macro_dff/reg_b0 rp_group_name]       -column 2 -row 0
puts "## adding osc bsg_client send"
add_to_rp_group bsg_chip::${name}_gen_fdt_cdt -hier [get_attribute $name/clk_gen_osc_inst/btc/tag_data_reg/macro_gate/stack_b0 rp_group_name] -column 3 -row 0
add_to_rp_group bsg_chip::${name}_gen_fdt_cdt -hier [get_attribute $name/clk_gen_osc_inst/btc/tag_data_mux/macro_gate/stack_b0 rp_group_name] -column 4 -row 0

puts "\#\# assembling ds bsg_client"
create_rp_group ${name}_ds_btc -design bsg_chip -columns 3 -rows 1
add_to_rp_group bsg_chip::${name}_ds_btc -hier [get_attribute $name/btc_ds/z_recv/macro_dff/reg_b0 rp_group_name]       -column 0 -row 0
add_to_rp_group bsg_chip::${name}_ds_btc -hier [get_attribute $name/btc_ds/tag_data_reg/macro_gate/stack_b0 rp_group_name] -column 1 -row 0
add_to_rp_group bsg_chip::${name}_ds_btc -hier [get_attribute $name/btc_ds/tag_data_mux/macro_gate/stack_b0 rp_group_name] -column 2 -row 0

puts "## assembling ds strobe"
create_rp_group ${name}_ds_strobe -design bsg_chip -columns 7 -rows 1

#add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/muxi2_S_n/macro_gate/MXI2X1_b0 rp_group_name]        -column 0 -row 0
#add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/xnor_S_n/macro_xnor_gate/XNOR2X1_b0 rp_group_name]    -column 1 -row 0
#add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/S_reg/macro_dff/reg_b0 rp_group_name]              -column 2 -row 0
#add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/andr/andr_macro_andr/b0123 rp_group_name]          -column 3 -row 0
#add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/C_reg/macro_dff/reg_b0 rp_group_name]              -column 4 -row 0
#add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/nand_C_n/macro_nand_gate/NAND2X1_b0 rp_group_name] -column 5 -row 0
#add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/nor3_C_n/macro_nor3_gate/NOR3X1_b0 rp_group_name]  -column 6 -row 0

add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/S_reg/macro_dff/reg_b0 rp_group_name]              -column 6 -row 0
add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/muxi2_S_n/macro_gate/stack_b0 rp_group_name]        -column 5 -row 0
add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/xnor_S_n/macro_xnor_gate/stack_b0 rp_group_name]    -column 4 -row 0
add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/andr/andr_macro_andr/b0123 rp_group_name]          -column 3 -row 0
add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/nand_C_n/macro_nand_gate/stack_b0 rp_group_name] -column 2 -row 0
add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/nor3_C_n/macro_nor3_gate/stack_b0 rp_group_name]  -column 1 -row 0
add_to_rp_group bsg_chip::${name}_ds_strobe -hier [get_attribute $name/clk_gen_ds_inst/strobe/C_reg/macro_dff/reg_b0 rp_group_name]              -column 0 -row 0


puts "## combining adt and fdt_cdt"
create_rp_group ${name}_gen_adg_fdt -design bsg_chip -columns 1 -rows 2
add_to_rp_group bsg_chip::${name}_gen_adg_fdt -hier [get_attribute $name/clk_gen_osc_inst/adt/M1 rp_group_name]  -column 0 -row 0
add_to_rp_group bsg_chip::${name}_gen_adg_fdt -hier bsg_chip::${name}_gen_fdt_cdt -column 0 -row 1


create_rp_group ${name}_mux_inst -design bsg_chip -columns 1 -rows 2
add_to_rp_group bsg_chip::${name}_mux_inst -hier [get_attribute $name/mux_inst/macro_b1_m/stack_b0 rp_group_name] -column 0 -row 0
add_to_rp_group bsg_chip::${name}_mux_inst -hier [get_attribute $name/mux_inst/macro_b1_i/stack_b0 rp_group_name] -column 0 -row 1


#add_to_rp_group bsg_chip::${name}_cnode_data -hier [get_attribute $name/cnode_inst/def_data_dst_reg/macro_dff/reg_b8 rp_group_name] -column 0 -row 0
#add_to_rp_group bsg_chip::${name}_cnode_data -hier [get_attribute $name/cnode_inst/def_data_r_reg/macro_dff/reg_b8 rp_group_name] -column 1 -row 0
#add_to_rp_group bsg_chip::${name}_cnode_data -hier [get_attribute $name/cnode_inst/shift_reg_data/macro_gate/DFFX1_b0 rp_group_name] -column 2 -row 0

}

proc bsg_place_clk_gen_mux { x y {w 30} {h 30} } {
  puts "## Trying to movebound clock out mux"
  if {[sizeof_collection [get_flat_cells -quiet *clk_out_mux_inst*]] > 0} {
    bsg_bound_creator clk_out_mux_inst $x $y $w $h
  }
}

proc bsg_place_clk_gen_btm { x y {w 150} {h 150} } {
  puts "## Trying to movebound tag master"
  if {[sizeof_collection [get_flat_cells -quiet *btm/*]] > 0} {
    bsg_bound_creator btm/ $x $y $w $h
  }
}

