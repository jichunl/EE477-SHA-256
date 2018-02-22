##########################################################################
# Physical Library Preparation  Reference Methodology <check_wire_tracks> for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# check_wire_tracks.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_step} {

# 2) Do nothing if the library does not contain any standard cells
if { [file size $flow_stdcell_file] == 0 } {
   echo "\n${flow_info_prefix} No standard cells in the library - skipping step check_wire_tracks."
   exec touch check_wire_tracks
   exit
}


echo "\n${flow_info_prefix} Running step \"check_wire_tracks\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Detailed report:            $detailed_wire_track_report"    
echo ""

# 3) Run axgCheckWireTrack
if {$detailed_wire_track_report} {set enable_check_wire_track_detail true}

axgCheckWireTrack
formDefault  check_wire_track
setFormField check_wire_track library_name $ref_lib$library_name
formOK       check_wire_track

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"check_wire_tracks\" step (variable \$run_step = 0)."
}

exec touch touchfiles/check_wire_tracks

exit

