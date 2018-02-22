##########################################################################################
# Version: G-2012.06-SP4 (Jan 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
##########################################################################################

source -echo ./rm_setup/icc_setup.tcl

open_mw_cel $ICC_METAL_FILL_CEL -lib $MW_DESIGN_LIBRARY

  ########################
  #     SIGNOFF DRC      #
  ########################

if {[file exists [which $SIGNOFF_DRC_RUNSET]] } {

  if {$SIGNOFF_DRC_ENGINE == "HERCULES"} {
    set_physical_signoff_options -exec_cmd hercules -drc_runset $SIGNOFF_DRC_RUNSET
  } elseif { $SIGNOFF_DRC_ENGINE == "ICV"} {
    set_physical_signoff_options -exec_cmd icv -drc_runset $SIGNOFF_DRC_RUNSET
  }

  ## WA for STAR 9000440426 - Hercules - Could not open layer mapping file ../layer.map for reading,
  #  which will be fixed in ICC version 2010.12-SP5 and the WA will be removed in next RM release.
  #  WA is to use [which $SIGNOFF_MAPFILE] for HERCULES, the "which" ensures full path is used.
  if {$SIGNOFF_MAPFILE != "" && $SIGNOFF_DRC_ENGINE != "HERCULES"} {
    set_physical_signoff_options -mapfile $SIGNOFF_MAPFILE
  }
  if {$SIGNOFF_MAPFILE != "" && $SIGNOFF_DRC_ENGINE == "HERCULES"} {
    set_physical_signoff_options -mapfile [which $SIGNOFF_MAPFILE]
  }

  report_physical_signoff_options
  signoff_drc

}

exit
