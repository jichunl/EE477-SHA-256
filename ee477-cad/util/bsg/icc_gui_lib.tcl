#-----------------------------------------------------------------------------
#  University of California, San Diego
#-----------------------------------------------------------------------------
#  icc_gui_lib.tcl
#
#  Purpose: Library for efficient GUI manipulation in ICC
#-----------------------------------------------------------------------------

#----------------------
# Procedure gui_zoom_to
#
proc gui_zoom_to {object} {

  set obj_bbox [get_attribute $object bbox]
  if { $obj_bbox == "" } {
    puts "Error: Can not obtain [get_attribute $object name] area!"
  }

  eval "gui_zoom -window [gui_get_current_window -view] -rect {$obj_bbox} -exact"
}

define_proc_attributes gui_zoom_to \
  -info "gui_zoom_to - Zoom-in to the specified object in IC Compiler." \
  -define_args {
    {object "a target object to be viewed" "object" string required}
  }
#
# Procedure gui_zoom_to
#----------------------
