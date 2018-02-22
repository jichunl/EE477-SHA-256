##########################################################################
# Physical Library Preparation Reference Methodology <wire_tracks> for LEF_IN flow
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
   exec touch touchfiles/${library_name}.wire_tracks
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
#open_mw_cel -readonly unitTile

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
if {1} {
   setFormField define_wire_track m1_offset $unit_tile_m1_offset
   setFormField define_wire_track m1dir horizontal
   setFormField define_wire_track m2_offset $unit_tile_m2_offset
   setFormField define_wire_track m2dir vertical
   setFormField define_wire_track m3_offset $unit_tile_m3_offset
   setFormField define_wire_track m3dir horizontal
   setFormField define_wire_track m4_offset $unit_tile_m4_offset
   setFormField define_wire_track m4dir vertical
   setFormField define_wire_track m5_offset $unit_tile_m5_offset
   setFormField define_wire_track m5dir horizontal
   setFormField define_wire_track m6_offset $unit_tile_m6_offset
   setFormField define_wire_track m6dir vertical
   setFormField define_wire_track m7_offset $unit_tile_m7_offset
   setFormField define_wire_track m7dir horizontal
   setFormField define_wire_track m8_offset $unit_tile_m8_offset
   setFormField define_wire_track m8dir vertical
   setFormField define_wire_track m9_offset $unit_tile_m9_offset
   setFormField define_wire_track m9dir horizontal
   setFormField define_wire_track m10_offset $unit_tile_m10_offset
   setFormField define_wire_track m10dir vertical
   setFormField define_wire_track m11_offset $unit_tile_m11_offset
   setFormField define_wire_track m11dir horizontal
   setFormField define_wire_track m12_offset $unit_tile_m12_offset
   setFormField define_wire_track m12dir vertical
   # End of manual method
}

formOK define_wire_track

close_mw_lib $ref_lib$library_name

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"wire_tracks\" step (variable \$run_step = 0)."
}

exec touch touchfiles/${library_name}.wire_tracks

exit


