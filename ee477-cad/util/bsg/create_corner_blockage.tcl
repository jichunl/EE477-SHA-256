#-----------------------------------------------------------------------------
#  University of California, San Diego
#-----------------------------------------------------------------------------
#  create_corner_blockage.tcl
#
#  Purpose: Create derived placement blockage straps around an object
#
#-----------------------------------------------------------------------------

proc create_corner_blockage {args} {

  parse_proc_arguments -args $args pargs

  # to be printed later
  set full_command "create_corner_blockage"

  # get object
  if {[info exists pargs(-object)]} {
    set object $pargs(-object)
    if {$object == ""} {
      puts "Error: A target object must be specified for create_corner_blockage."
      return
    }
  } else {
    puts "Error: A target object must be specified for create_corner_blockage."
    return
  }
  append full_command " -object $object"

  # get name_prefix
  if {[info exists pargs(-name_prefix)]} {
    set name_prefix $pargs(-name_prefix)
    if {$name_prefix == ""} {
      puts "Error: A blockage name_prefix must be specified for create_corner_blockage."
      return
    }
  } else {
    puts "Error: A blockage name_prefix must be specified for create_corner_blockage."
    return
  }
  append full_command " -name_prefix $name_prefix"

  # get margin
  if {[info exists pargs(-margin)]} {
    set margin $pargs(-margin)
    if {$margin <= 0} {
      puts "Error: The value specified by -margin option must be greater than 0."
      return
    }
  } else {
    set margin 10
    puts "Info: Using default margin (10) for create_corner_blockage."
  }
  append full_command " -margin $margin"

  # get edge_coverage
  if {[info exists pargs(-edge_coverage)]} {
    set edge_coverage $pargs(-edge_coverage)
    if {$edge_coverage < 0 || $edge_coverage > 1} {
      puts "Error: Please specify a valid edge_coverage between \[0, 1\]"
      return
    }
  } else {
    set edge_coverage 0.2
    puts "Info: Using default edge_coverage 0.2 for create_corner_blockage."
  }
  append full_command " -edge_coverage $edge_coverage"

  # get type
  if {[info exists pargs(-type)]} {
    set type $pargs(-type)
    if {$type != "hard" && $type != "soft" && $type != "partial"} {
      puts "Error: Please specify a valid type \[hard | soft | partial\]!"
      return
    }
  } else {
    set type "hard"
    puts "Info: Using default type \"hard\" for create_corner_blockage."
  }
  append full_command " -type $type"

  # get blocked_percentage
  if {[info exists pargs(-blocked_percentage)]} {
    set blocked_percentage $pargs(-blocked_percentage)
    if {$blocked_percentage < 0 || $blocked_percentage > 100} {
      puts "Error: Please specify a valid blocked_percentage between \[0, 100\]"
      return
    }
    append full_command " -blocked_percentage $blocked_percentage"
  }

  puts "\n$full_command\n"

  # build options for IC Compiler create_placement_blockage command.
  set extra_opts "-type $type"
  if {[info exists pargs(-blocked_percentage)]} {
    append extra_opts " -blocked_percentage " $blocked_percentage
  }

  # get core boundaries for bounding blockages
  set core_bbox [get_attribute [get_core_area] bbox]
  if { $core_bbox == "" } {
    puts "Error: Can not obtain core area!"
  }
  # get core area coordinates, lower left (x, y) and upper right (x, y).
  set core_ll_x [lindex [lindex $core_bbox 0] 0]
  set core_ll_y [lindex [lindex $core_bbox 0] 1]
  set core_ur_x [lindex [lindex $core_bbox 1] 0]
  set core_ur_y [lindex [lindex $core_bbox 1] 1]

  set obj_bbox [get_attribute $object bbox]
  if { $obj_bbox == "" } {
    puts "Error: Can not obtain [get_attribute $object name] area!"
  }
  set obj_ll_x [lindex [lindex $obj_bbox 0] 0]
  set obj_ll_y [lindex [lindex $obj_bbox 0] 1]
  set obj_ur_x [lindex [lindex $obj_bbox 1] 0]
  set obj_ur_y [lindex [lindex $obj_bbox 1] 1]

  set obj_len_x [expr $obj_ur_x - $obj_ll_x]
  set obj_len_y [expr $obj_ur_y - $obj_ll_y]

  set blkg_len_y [expr $margin + $obj_len_y * $edge_coverage / 2]
  set blkg_len_x [expr $margin + $obj_len_x * $edge_coverage / 2]

  if {$obj_ll_x - $margin < $core_ll_x} {
    set blkg_ll_x $core_ll_x
  } else {
    set blkg_ll_x [expr $obj_ll_x - $margin]
  }
  if {$obj_ll_y - $margin < $core_ll_y} {
    set blkg_ll_y $core_ll_y
  } else {
    set blkg_ll_y [expr $obj_ll_y - $margin]
  }
  if {$obj_ur_x + $margin > $core_ur_x} {
    set blkg_ur_x $core_ur_x
  } else {
    set blkg_ur_x [expr $obj_ur_x + $margin]
  }
  if {$obj_ur_y + $margin > $core_ur_y} {
    set blkg_ur_y $core_ur_y
  } else {
    set blkg_ur_y [expr $obj_ur_y + $margin]
  }

  set blkg_ll_v_bbox [list $blkg_ll_x \
                           $blkg_ll_y \
                           $obj_ll_x \
                           [expr $blkg_ll_y + $blkg_len_y]]
  eval "create_placement_blockage -bbox {$blkg_ll_v_bbox} -name ${name_prefix}_ll_v_blkg $extra_opts"

  set blkg_ll_h_bbox [list $blkg_ll_x \
                           $blkg_ll_y \
                           [expr $blkg_ll_x + $blkg_len_x] \
                           $obj_ll_y]
  eval "create_placement_blockage -bbox {$blkg_ll_h_bbox} -name ${name_prefix}_ll_h_blkg $extra_opts"

  set blkg_ul_v_bbox [list $blkg_ll_x \
                           [expr $blkg_ur_y - $blkg_len_y] \
                           $obj_ll_x \
                           $blkg_ur_y]
  eval "create_placement_blockage -bbox {$blkg_ul_v_bbox} -name ${name_prefix}_ul_v_blkg $extra_opts"

  set blkg_ul_h_bbox [list $blkg_ll_x \
                           $obj_ur_y \
                           [expr $blkg_ll_x + $blkg_len_x] \
                           $blkg_ur_y]
  eval "create_placement_blockage -bbox {$blkg_ul_h_bbox} -name ${name_prefix}_ul_h_blkg $extra_opts"

  set blkg_ur_v_bbox [list $obj_ur_x \
                           [expr $blkg_ur_y - $blkg_len_y] \
                           $blkg_ur_x \
                           $blkg_ur_y]
  eval "create_placement_blockage -bbox {$blkg_ur_v_bbox} -name ${name_prefix}_ur_v_blkg $extra_opts"

  set blkg_ur_h_bbox [list [expr $blkg_ur_x - $blkg_len_x] \
                           $obj_ur_y \
                           $blkg_ur_x \
                           $blkg_ur_y]
  eval "create_placement_blockage -bbox {$blkg_ur_h_bbox} -name ${name_prefix}_ur_h_blkg $extra_opts"

  set blkg_lr_v_bbox [list $obj_ur_x \
                           $blkg_ll_y \
                           $blkg_ur_x \
                           [expr $blkg_ll_y + $blkg_len_y]]
  eval "create_placement_blockage -bbox {$blkg_lr_v_bbox} -name ${name_prefix}_lr_v_blkg $extra_opts"

  set blkg_lr_h_bbox [list [expr $blkg_ur_x - $blkg_len_x] \
                           $blkg_ll_y \
                           $blkg_ur_x \
                           $obj_ll_y]
  eval "create_placement_blockage -bbox {$blkg_lr_h_bbox} -name ${name_prefix}_lr_h_blkg $extra_opts"

  puts "Total of 8 blockages are created."
  puts "  ${name_prefix}_ll_v_blkg"
  puts "  ${name_prefix}_ll_h_blkg"
  puts "  ${name_prefix}_ul_v_blkg"
  puts "  ${name_prefix}_ul_h_blkg"
  puts "  ${name_prefix}_ur_v_blkg"
  puts "  ${name_prefix}_ur_h_blkg"
  puts "  ${name_prefix}_lr_v_blkg"
  puts "  ${name_prefix}_lr_h_blkg"
}

define_proc_attributes create_corner_blockage \
  -info "create_corner_blockage - create derived placement blockage straps around an object (macro etc.)" \
  -define_args {
    {-object "a target object for which the derived blockages are created" "object" string required}
    {-name_prefix "a unique prefix for naming the derived blockages" "string" string required}
    {-margin "the blockage margin (thickness) specified in default units" "float" float optional}
    {-edge_coverage "the fraction \[0, 1\] to specify how much of an object's edge is covered by derived blockages" "float" float optional}
    {-type "specify the type of blockage to be created" "hard | soft | partial" string optional}
    {-blocked_percentage "specify the percentage \[0, 100\] of blockage for a partial blockage" "integer" int optional}
  }
