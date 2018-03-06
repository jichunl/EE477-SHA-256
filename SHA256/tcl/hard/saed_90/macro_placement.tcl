proc bsg_place_macro { name x_origin y_origin orientation {x_cord 0} {y_cord 0} } {
    set obj [get_cells -all $name]
    set_attribute -quiet $obj origin [list $x_origin $y_origin]
    set_attribute -quiet $obj orientation $orientation
    set_attribute -quiet $obj is_placed true
    set_attribute -quiet $obj is_fixed true
    set_attribute -quiet $obj is_soft_fixed false
    set_attribute -quiet $obj eco_status eco_reset

    set macro_bbox [get_attribute $obj bbox]
    set macro_ll_x [lindex [lindex $macro_bbox 0] 0]
    set macro_ll_y [lindex [lindex $macro_bbox 0] 1]
    set macro_ur_x [lindex [lindex $macro_bbox 1] 0]
    set macro_ur_y [lindex [lindex $macro_bbox 1] 1]

    set pr_blk_pad 10.0
    create_route_guide \
        -name preroute_block_$name \
        -coordinate [list [expr $macro_ll_x - $pr_blk_pad] [expr $macro_ll_y - $pr_blk_pad] [expr $macro_ur_x + $pr_blk_pad] [expr $macro_ur_y + $pr_blk_pad]] \
        -no_preroute_layers {M1} \
        -no_snap

    set place_blk_pad 10.0
    create_placement_blockage \
        -coordinate [list [expr $macro_ll_x - $place_blk_pad] [expr $macro_ll_y - $place_blk_pad] [expr $macro_ur_x + $place_blk_pad] [expr $macro_ll_y]] \
        -name "${name}_x_${x_cord}_y_${y_cord}_bottom_blockage"
        create_placement_blockage \
        -coordinate [list [expr $macro_ll_x - $place_blk_pad] [expr $macro_ur_y] [expr $macro_ur_x + $place_blk_pad] [expr $macro_ur_y + $place_blk_pad]] \
        -name "${name}_x_${x_cord}_y_${y_cord}_top_blockage"
        create_placement_blockage \
        -coordinate [list [expr $macro_ll_x - $place_blk_pad] [expr $macro_ll_y - $place_blk_pad] [expr $macro_ll_x] [expr $macro_ur_y + $place_blk_pad]] \
        -name "${name}_x_${x_cord}_y_${y_cord}_left_blockage"
        create_placement_blockage \
        -coordinate [list [expr $macro_ur_x] [expr $macro_ll_y - $place_blk_pad] [expr $macro_ur_x + $place_blk_pad] [expr $macro_ur_y + $place_blk_pad]] \
        -name "${name}_x_${x_cord}_y_${y_cord}_right_blockage"
}


# TODO: Define where you want your macros here!

#bsg_place_macro <name> <x location> <y location> <orientation = N,S,E,W>
#	bsg_place_macro guts/n_2__clnt_clnt/genblk1_node/bm/y_0__x_0__tile/proc/h_z/bnkd_xbar/z_0__m1rw_mask/macro_mem 2866 2073.62 N
#	bsg_place_macro guts/n_2__clnt_clnt/genblk1_node/bm/y_0__x_0__tile/proc/h_z/vanilla_core/imem_0/macro_mem 2886 4148.18 N

