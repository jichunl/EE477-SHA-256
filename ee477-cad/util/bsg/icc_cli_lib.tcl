#-----------------------------------------------------------------------------
#  University of California, San Diego
#-----------------------------------------------------------------------------
#  icc_cli_lib.tcl
#
#  Purpose: Library for efficient ICC command line interface
#-----------------------------------------------------------------------------

#-----------------
# Procedure reload
#
proc reload {mw_cel} {
  close_mw_cel
  open_mw_cel $mw_cel
}

define_proc_attributes reload \
  -info "reload - Reload a Milkyway design library in IC Compiler." \
  -define_args {
    {mw_cel "a Milkyway design library to be opened" "mw_cel" string required}
  }

# Procedure reload
#-----------------
