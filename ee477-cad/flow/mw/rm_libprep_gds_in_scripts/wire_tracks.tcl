##########################################################################
# Physical Library Preparation Reference Methodology <wire_tracks> for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# wire_tracks.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_step} {

# 2) Do nothing if the library does not contain any standard cells:
if { [file size $flow_stdcell_file] == 0 } {
   echo "\n${flow_info_prefix} No standard cells in the library - skipping step wire_tracks."
   exec touch wire_tracks
   exit
}

echo "\n${flow_info_prefix} Running step \"wire_tracks\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Rails on metal1:            $metal1_pg_rail"
echo "Rails on metal2:            $metal2_pg_rail"

# 3) Sanity check:
if {$metal1_pg_rail == $metal2_pg_rail} {
   echo "\n${flow_info_prefix} Both metal1 and metal2 set as rail layers."
   echo "                               Please verify the track directions in the unit tile cell."
   exit
}

open_mw_lib $ref_lib$library_name
open_mw_cel -readonly unitTile

# 4) Retrieve number of layers and each layer's pitch from the technology info.
#    You can use the pitch values later to set half-pitch offsets.
#    The pitch is stored in the variables
#    $__layer_pitch(metal1), $__layer_pitch(metal2), and so on.

set _layer_count 0
foreach _layer_name [collection_to_list -name_only -no_braces [get_layers *]] {
   if { [string match metal* [get_technology_info -layer $_layer_name maskName]] } {
      incr _layer_count
      set _current_mask [get_technology_info -layer $_layer_name maskName]
      set _current_pitch [get_technology_info -layer $_layer_name pitch]
      set __layer_pitch($_current_mask) $_current_pitch
   }
}
echo "Number of layers:           $_layer_count (from tech file)"
echo ""

axgDefineWireTracks

# 6) Manual method - enter values for each layer:
if {0} {
   setFormField define_wire_track m1_offset 0.0000
   setFormField define_wire_track m1dir vertical
   setFormField define_wire_track m2_offset 0.0000
   setFormField define_wire_track m2dir horizontal
   setFormField define_wire_track m3_offset 0.0000
   setFormField define_wire_track m3dir vertical
   setFormField define_wire_track m4_offset 0.0000
   setFormField define_wire_track m4dir horizontal
   setFormField define_wire_track m5_offset 0.0000
   setFormField define_wire_track m5dir vertical
   setFormField define_wire_track m6_offset 0.0000
   setFormField define_wire_track m6dir horizontal
   setFormField define_wire_track m7_offset 0.0000
   setFormField define_wire_track m7dir vertical
   setFormField define_wire_track m8_offset 0.0000
   setFormField define_wire_track m8dir horizontal
   setFormField define_wire_track m9_offset 0.0000
   setFormField define_wire_track m9dir vertical
   setFormField define_wire_track m10_offset 0.0000
   setFormField define_wire_track m10dir horizontal
   setFormField define_wire_track m11_offset 0.0000
   setFormField define_wire_track m11dir vertical
   setFormField define_wire_track m12_offset 0.0000
   setFormField define_wire_track m12dir horizontal
   # End of manual method
}

formOK define_wire_track

close_mw_lib $ref_lib$library_name

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"wire_tracks\" step (variable \$run_step = 0)."
}

exec touch touchfiles/wire_tracks

exit


