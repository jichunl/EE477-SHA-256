set bsg_track_height 5.04
set bsg_M2_pitch 0.66
set bsg_pin_offset 330.00

set bsg_core_dims [join [get_attribute [get_core_area] bbox]]
set bsg_min_x [lindex $bsg_core_dims 0]

# because of an oddity in our track alignment, the bottom track is missing
#set bsg_min_y [expr [lindex $bsg_core_dims 1] + $bsg_track_height]
set bsg_min_y [lindex $bsg_core_dims 1]
set bsg_max_x [lindex $bsg_core_dims 2]
set bsg_max_y [lindex $bsg_core_dims 3]

# suppress warnings about undo stack
suppress_message HDUEDIT-104

# mbt: I always forget this command
# to update the selection inside the ICC gui 
# change_selection [get_cells foo]   # update_selection
#

###################################################################
#
# generic helper functions
#
#
###################################################################


proc bsg_is_list {string} {
    return [expr {0 == [catch {llength $string}]}]
}


proc bsg_max {x y} {expr {$x>$y? $x: $y}}


# given a strings with a wildcard, and a subst_list, one-to-one replace wildcard
proc bsg_wildcard_map { string subst_list } {
    set result_list {}
    set string_parts [split $string *]
    foreach subst $subst_list {
        set new_string   [join $string_parts $subst]
        #puts "generated ${string} ${subst} --> $new_string"
        lappend result_list $new_string
    }
    return $result_list
}


###################################################################
#
# cell analysis and calculation functions
#
#
###################################################################

#
# gets aggregate area of a pattern
#

proc bsg_get_area { pattern } {
    set area_sum 0
    foreach_in_collection gate [get_flat_cells -quiet $pattern] {
        set area_sum [expr $area_sum + [get_attribute $gate area]];
    }
    return $area_sum
}

#
# odd overlaps happen if you use X coordinates that are not track aligned
# bsg_track_align_x aligns an X coordinate
#

proc bsg_track_align_x { x } {
    global bsg_min_x
    global bsg_M2_pitch
    set x [expr $x*1.0]
    set x_track [expr ($x - $bsg_min_x) / $bsg_M2_pitch]
    set x_track int($x_track)*1.0
    return [expr $x_track*$bsg_M2_pitch+$bsg_min_x];
}

proc bsg_track_align_y { y } {
    global bsg_min_y
    global bsg_track_height
    #set bsg_min_y 595.700
    set y [expr $y*1.0]
    set y_track [expr ($y - $bsg_min_y) / $bsg_track_height]
    set y_track int($y_track)*1.0
    return [expr $y_track*$bsg_track_height+$bsg_min_y];
}


proc bsg_space_round_down_to_align_x { x } {
    global bsg_M2_pitch
    set x       [expr $x * 1.0]
    set x_track [expr $x / $bsg_M2_pitch]
    set x_track int($x_track)*1.0
    return [expr $x_track*$bsg_M2_pitch]
}


proc bsg_space_round_down_to_align_y { y } {
    global bsg_track_height
    set y       [expr $y * 1.0]
    set y_track [expr $y / $bsg_track_height]
    set y_track int($y_track)*1.0
    return [expr $y_track*$bsg_track_height]
}


proc bsg_track_adj_x { x offset } {
    global bsg_M2_pitch
    return [expr $x + $offset*$bsg_M2_pitch]
}

proc bsg_track_adj_x_dir { x offset dir } {
    global bsg_M2_pitch

    if {$dir == "WtoE"} {
        return [expr $x + $offset*$bsg_M2_pitch]
    } elseif {$dir == "EtoW"} {
        return [expr $x - $offset*$bsg_M2_pitch]
    }
}

proc bsg_track_adj_y { y offset } {
    global bsg_track_height
    return [expr $y + $offset*$bsg_track_height]
}

proc bsg_track_adj_y_rev {y offset rev} {
    global bsg_track_height

    # 1 -> -1
    # 0 -> 1

    set rev [expr -($rev-1)*2-1]

    return [expr $y + $offset*$bsg_track_height*$rev]
}

proc bsg_gate_get_origins { gate_list } {
    set origin_list [list]
    foreach gate $gate_list {
        lappend origin_list [get_attribute $gate origin]
    }
    return $origin_list
}

proc bsg_gate_get_x { gate } {
    set gate_list [collection_to_list -no_braces -name_only [get_flat_cells $gate]]
    set origin [get_attribute [lindex $gate_list 0] origin]
    return [lindex $origin 0]
}

proc bsg_gate_get_y { gate } {
    set gate_list [collection_to_list -no_braces -name_only [get_flat_cells $gate]]
    set origin [get_attribute [lindex $gate_list 0] origin]
    return [lindex $origin 1]
}


proc bsg_gate_offset_origins_x { origin_list x_offs { fix_x 0 } } {
    set output_origin_list [list]
    foreach origin $origin_list {
        set x $x_offs
        set y [lindex $origin 1]

        if {$fix_x == 0} {
            set x [expr [lindex $origin 0] + $x_offs]
        }

        lappend output_origin_list [list $x $y]
    }
    return $output_origin_list
}

proc bsg_gate_offset_origins_y { origin_list y_offs { fix_y 0} } {
    set output_origin_list [list]
    foreach origin $origin_list {
        set x [lindex $origin 0]
        set y $y_offs

        if {$fix_y == 0} {
            set y [expr [lindex $origin 1] + $y_offs]
        }

        lappend output_origin_list [list $x $y]
    }
    return $output_origin_list
}



###################################################################
#
# cell transformation functions
#
#
###################################################################

# this is for stacking a list of gates at a list of coordinates
# usage bsg_gate_strafe { a b c d } { 1 2 3 4} {5 6 7 8}
#

proc bsg_gate_strafe { gate_list origins } {
    foreach gate $gate_list origin $origins {
        if {$gate != "" && $origin != ""} {
            move_objects -x [lindex $origin 0] -y [lindex $origin 1] $gate -ignore_fixed
        }
    }
}


proc bsg_magnetize_pins { gate_list pin_name { logical_level 1} } {
    set pin_list {}
    global bsg_do_magnets

    foreach gate $gate_list {
        set_attribute -quiet $gate is_fixed 1
        set_dont_touch_placement $gate
        lappend pin_list ${gate}/${pin_name}
    }


    magnet_placement $pin_list -exclude_buffers -logical_level $logical_level
}

#
# use rp groups instead!
#
#

proc bsg_rf_place { pos_x pos_y words name_prefix name_suffix cell_direction minimize_size {downward 0} {y_sec 1} {y_gap 0} {bit_order 0} } {
    set tmp_x $pos_x

    set row_quiet 15

    set missing_rows {}

    if {$words > $row_quiet} {
        puts -nonewline "bsg_rf_place: Laying out rows: "
    }
    for {set p 0} {$p < $words} {incr p} {

        set pattern ${name_prefix}${p}${name_suffix}

        if {$words > $row_quiet} {puts -nonewline "$p "; flush stdout; }

        set sort 1

        if {$bit_order!=0} {
            set gates {}
            foreach gate [bsg_wildcard_map $pattern $bit_order] {
                lappend gates [collection_to_list -no_braces -name_only [get_flat_cell $gate -quiet]]
            }
            set sort 0
            # puts $gates
        } else {
            set gate_col [get_flat_cells $pattern -quiet]
            set gates    [collection_to_list -no_braces -name_only $gate_col]
        }

        if {[llength $gates] > 0} {
            set tmp_x [bsg_stack_list_gaps $tmp_x $pos_y $gates $cell_direction $sort $minimize_size $downward $y_sec $y_gap]
            # double advance

            # fixme: for now, only magnetize manually sequenced gates, and give extra X-room
            if {$sort == 0} {
                set extra_x_tracks 15
                set tmp_x [bsg_track_adj_x_dir $tmp_x $extra_x_tracks $cell_direction]
                bsg_magnetize_pins  $gates Q 4
            }

        } else {
            lappend missing_rows $p
        }
    }
    if {$words > $row_quiet} {puts "";}

    if {[llength $missing_rows]} {
        puts "bsg_rf_place: missing rows (${name_prefix}): ${missing_rows}";
    }

    return $tmp_x;
}


proc minimize_cell { gate } {
    set beat_me [get_attribute $gate area];
    set current_best $beat_me
    set alternate 0

    #cool, but does not find min
    #set choices [filter_collection [get_alternative_lib_cells $gate] area<$current_best]

    foreach alter [collection_to_list -no_braces -name_only [get_alternative_lib_cells $gate]] {
        # we skip XL cells, they are too strange for carte blanche replacement
        if {[string first XL $alter] == -1} {
            set compare [get_attribute $alter area]
            #puts "${current_best} v ${compare}"
            if {[expr $current_best * 1.001] < $compare} {
                # do nothing if the current best is better
            } else {
                set alternate $alter
                set current_best $compare
            }
        }
    }

    if {$alternate!=0} {
        set original_type [get_attribute $gate ref_name]
        puts "BSG: $gate ($original_type-->$alternate) ($beat_me -> $current_best)"
        size_cell $gate $alternate
    }
}

# side-effect: moves the cell to the origin
proc bsg_normalize_orientation { gate direction } {
    set orientation [get_attribute $gate orientation]
    set bogus {1000 1000}

    if {$direction=="WtoE"} {
        if {$orientation=="S"} { set_cell_location -coordinates $bogus -orientation "FS" $gate }
        if {$orientation=="FN"} { set_cell_location -coordinates $bogus -orientation "N"  $gate }
    }

    if {$direction=="EtoW"} {
        if {$orientation=="FS"} { set_cell_location -coordinates $bogus -orientation "S"  $gate }
        if {$orientation=="N"} { set_cell_location  -coordinates $bogus -orientation "FN"  $gate }
    }
}



#
# minimize == 1: minimize cell (for register files)
# orient   == 1: orient cell according to cell_direction
# cell_direction   -- "WtoE" or "EtoW"
#
# returns: width of widest cell
#

proc bsg_minimize_orient_measure { gates cell_direction minimize orient } {
    set max_width 0.00000

    foreach gate $gates {
        if {$minimize} {
            minimize_cell $gate
        }
        if {$orient} {
            bsg_normalize_orientation $gate $cell_direction
        }
        set max_width [bsg_max [get_attribute $gate width] $max_width]
    }

    return $max_width
}


# this stacks a list of gates
#
# pos_x, pos_y = lower left hand corner
# cell_direction = "WtoE" or "EtoW"
# for name: guts_comm_link_channel_0__ssi_baf_bsg_sync_mem_clock_cross_reg_${word}__*_
# name_prefix =  guts_comm_link_channel_0__ssi_baf_bsg_sync_mem_clock_cross_reg_
# name_suffix =  __*_

proc bsg_stack_list { pos_x pos_y gates cell_direction sort minimize {downward 0}} {
    global bsg_track_height

    if {$sort} {
        set gates [lsort -dictionary $gates]
    }

    set max_width [bsg_minimize_orient_measure $gates $cell_direction $minimize 1]

    set tmp_y $pos_y

    foreach gate $gates {
        #set_attribute -quiet $gate is_fixed 0
        if {$cell_direction == "EtoW"} {  move_objects -x [expr $pos_x - $max_width] -y $tmp_y $gate -ignore_fixed  }
        if {$cell_direction == "WtoE"} {  move_objects -x $pos_x -y $tmp_y $gate  -ignore_fixed                 }
        #set_attribute -quiet $gate is_fixed 1
        if {$downward} {
            set tmp_y [expr $tmp_y - $bsg_track_height]
        } else {
            set tmp_y [expr $tmp_y + $bsg_track_height]
        }
    }

    if {$cell_direction == "WtoE" } { return [expr $pos_x + $max_width] }
    if {$cell_direction == "EtoW" } { return [expr $pos_x - $max_width] }
}



# allows for a list of patterns to be provided as well as a signal pattern

proc bsg_stack { pos_x pos_y pattern cell_direction sort minimize {downward 0}} {

    if {[llength $pattern] > 1} {
        #puts "bsg stacking pattern: ${pattern}"
        set gates {}
        foreach pat $pattern {
            set gates [concat $gates [collection_to_list -no_braces -name_only [get_flat_cells $pat]]]
            #puts $gates
        }
    } else {
        set gates [collection_to_list -no_braces -name_only [get_flat_cells $pattern]]
    }

    return [bsg_stack_list $pos_x $pos_y $gates $cell_direction $sort $minimize $downward]
}

proc bsg_stack_list_gaps { pos_x pos_y gates cell_direction sort minimize {downward 0} {y_sec 1} {y_gap 4}} {
    set tmp_y $pos_y
    set tmp_x $pos_x

    if {$y_sec == 1} {
        return [bsg_stack_list $pos_x $pos_y $gates $cell_direction $sort $minimize $downward];
    } else {
        if {$sort} {
            set gates [lsort -dictionary $gates]
        }
        set num_gates [llength $gates]
        set gate_run [expr ($num_gates + $y_sec - 1) / $y_sec];
        set gates_placed 0
        set run_index 0

        set max_x -1
        while {$gates_placed < $num_gates} {
            # puts "bsg_stack_list ${num_gates} ${gate_run} ${gates_placed} ${run_index} x=${tmp_x} y={$tmp_y}"
            set start_pos [expr $run_index * $gate_run]
            set end_pos   [expr $start_pos + $gate_run - 1]
            set gate_list [lrange $gates $start_pos $end_pos]
            set gates_placed [expr $gates_placed + $gate_run]
            set run_index [expr $run_index + 1]
            # puts "bsg_stack_list_gaps gate_list ${gate_list}"
            set local_x [bsg_stack_list $tmp_x $tmp_y $gate_list $cell_direction 0 $minimize $downward]
            set max_x [bsg_max $local_x $max_x]
            if {$downward} {
                set tmp_y [bsg_track_adj_y $tmp_y [expr -1 * ($y_gap+$gate_run)]]
            } else {
                set tmp_y [bsg_track_adj_y $tmp_y [expr $gate_run + $y_gap]]
            }
        }
        set tmp_x $max_x
    }
    return $tmp_x;
}


# rev == 1: go right to left
# rev != 1: go left to right

# note: shadow placing versus I/O's can result in overlap of cells
# because the I/O's are often not aligned to the M2 grid.
#

proc bsg_shadow_place { reference_gates_list new_gates_list offs_x offs_y rev {fix_x 0} {fix_y 0}} {
    set max_width [bsg_minimize_orient_measure $new_gates_list "NA" 0 0]
    set ref_origins [bsg_gate_get_origins $reference_gates_list]

    if {$rev==1} { set offs_x [expr $offs_x - $max_width] }

    set offs_origins [bsg_gate_offset_origins_x $ref_origins $offs_x $fix_x]
    set offs_origins [bsg_gate_offset_origins_y $offs_origins $offs_y $fix_y]
    bsg_gate_strafe $new_gates_list $offs_origins

    return $max_width
}

proc bsg_shadow_place_regexp { ref_gates_regexp new_gates_regexp offs_x offs_y rev {fix_x 0} {fix_y 0}} {
    set ref_gates_list [collection_to_list -no_braces -name_only [get_flat_cells $ref_gates_regexp]]
    set new_gates_list [collection_to_list -no_braces -name_only [get_flat_cells $new_gates_regexp]]

    set ref_length [llength $ref_gates_list]
    set new_length [llength $new_gates_list]
    if { $ref_length != $new_length } {
        puts "bsg_shadow_place_regexp: noting length mismatch ${ref_length} ${new_length} ${ref_gates_regexp}"
        #puts $ref_gates_list
        #puts $new_gates_list
    }

    return [bsg_shadow_place $ref_gates_list $new_gates_list $offs_x $offs_y $rev $fix_x $fix_y]
}



#
# minimize == 1: minimize cell (for register files)
# orient   == 1: orient cell according to cell_direction
# cell_direction   -- "WtoE" or "EtoW"
#
# returns: width of widest cell
#

proc bsg_minimize_orient_measure { gates cell_direction minimize orient } {
    set max_width 0.00000

    foreach gate $gates {
        if {$minimize} {
            minimize_cell $gate
        }
        if {$orient} {
            bsg_normalize_orientation $gate $cell_direction
        }
        set max_width [bsg_max [get_attribute $gate width] $max_width]
    }

    return $max_width
}



###################################################################
#
# bulk fixing and unfixing
#
#
#
###################################################################



proc bsg_fix_all_placed {} {
    foreach_in_collection itr [get_flat_cell *] {
        if {[get_attribute $itr is_placed]} {
            set_attribute $itr is_fixed 1 -quiet
            set_dont_touch_placement $itr
        }
    }
}

proc bsg_unplace_all {} {
    foreach_in_collection itr [get_flat_cell *] {
        if {[get_attribute -quiet $itr dont_touch]==0} {
            set_attribute $itr is_fixed 0 -quiet
            set_attribute $itr is_placed 0 -quiet
            remove_dont_touch_placement $itr
        }
    }

    remove_placement -object_type standard_cell
}




###################################################################
#
# bounds and blockage creator
#
#
#
###################################################################

proc bsg_silent_remove_bounds { name } {
    foreach_in_collection x [get_bounds -quiet $name] {
	puts "removing bounds ${x}"
	remove_bounds -name $x
    }
}


proc bsg_bound_creator { name x y ofs_x ofs_y { exclusive 0} } {
    set name_wildcard [join [list "*" ${name} "*"] ""]
    bsg_silent_remove_bounds  $name
    puts "creating_bound ${name} (=${name_wildcard}) from ${x} ${y} with ${ofs_x} ${ofs_y}"
    puts  [list $x $y [expr $x+$ofs_x] [expr $y+$ofs_y]]
    create_bounds -name $name -type hard -coordinate [list $x $y [expr $x+$ofs_x] [expr $y+$ofs_y]] [get_flat_cells -quiet $name_wildcard]
}

proc bsg_bound_creator_exclusive { name x y ofs_x ofs_y { exclusive 0} } {
    set name_wildcard [join [list "*" ${name} "*"] ""]
    bsg_silent_remove_bounds  $name
    puts "creating_bound ${name} (=${name_wildcard}) from ${x} ${y} with ${ofs_x} ${ofs_y}"
    puts  [list $x $y [expr $x+$ofs_x] [expr $y+$ofs_y]]
    create_bounds -name $name -type hard -exclusive -coordinate [list $x $y [expr $x+$ofs_x] [expr $y+$ofs_y]] [get_flat_cells -quiet $name_wildcard]
}



proc bsg_bound_creator_abs { name x y x2 y2 { exclusive 0} } {
    set name_wildcard [join [list "*" ${name} "*"] ""]
    bsg_silent_remove_bounds  $name
    puts "creating_bound ${name} (=${name_wildcard}) from ${x} ${y} with ${x2} ${y2}"
    puts  [list $x $y [expr $x2] [expr $y2]]
    create_bounds -name $name -type hard -coordinate [list $x $y $x2 $y2] [get_flat_cells -quiet $name_wildcard]
}


proc bsg_bound_creator_abs_list { bound_name name_list x y x2 y2 { exclusive 0} } {
    puts "# BEGIN creating bound ${bound_name}"
    bsg_silent_remove_bounds  $bound_name
    create_bounds -name $bound_name -type hard -coordinate [list $x $y $x2 $y2]
    foreach name $name_list {
        set name_wildcard [join [list "*" ${name} "*"] ""]
        puts "adding to bound ${bound_name} (=${name_wildcard}) from ${x} ${y} with ${x2} ${y2}"
        puts  [list $x $y [expr $x2] [expr $y2]]
        update_bounds -name $bound_name -add [get_flat_cells -quiet $name_wildcard]
    }
    puts "# END creating bound ${bound_name}"
}


proc bsg_bound_creator_abs_soft { name x y x2 y2 { exclusive 0} } {
    set name_wildcard [join [list "*" ${name} "*"] ""]

    bsg_silent_remove_bounds  $name

    puts "creating_bound ${name} (=${name_wildcard}) from ${x} ${y} with ${x2} ${y2}"
    puts  [list $x $y [expr $x2] [expr $y2]]
    create_bounds -name $name -coordinate [list $x $y $x2 $y2] [get_flat_cells -quiet $name_wildcard]
}


proc bsg_bound_creator_irregular { name coords } {
    set name_wildcard [join [list "*" ${name} "*"] ""]
    bsg_silent_remove_bounds  $name
    puts "creating_bound ${name} (=${name_wildcard}) from ${coords}"
    create_bounds -name $name -type hard -coordinate $coords [get_flat_cells -quiet $name_wildcard]
}


proc bsg_blockage_creator { name x y ofs_x ofs_y { exclusive 0} } {
    set name_wildcard [join [list "*" ${name} "*"] ""]
    remove_placement_blockage -name ${name}_block
    puts "creating_placement_blockage ${name} (=${name_wildcard}) from ${x} ${y} with ${ofs_x} ${ofs_y}"
    puts  [list $x $y [expr $x+$ofs_x] [expr $y+$ofs_y]]

    set sort_x [lsort -real [list $x [expr $x+$ofs_x]]]
    set sort_y [lsort -real [list $y [expr $y+$ofs_y]]]

    create_placement_blockage -name ${name}_block -type hard -coordinate [list [lindex $sort_x 0] [lindex $sort_y 0] [lindex $sort_x 1] [lindex $sort_y 1]]

}
