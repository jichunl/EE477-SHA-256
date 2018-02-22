##########################################################################
# Physical Library Preparation  Reference Methodology <bpv> for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# bpv.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_step} {

echo "\n${flow_info_prefix} Running step \"bpv\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Preferred pin layer:        $std_cell_pin_layer"
echo "Power rail metal:           $bpv_power_rail_metal"
echo "Ground rail metal:          $bpv_ground_rail_metal"
echo "BPV variable file:          $bpv_flag_file"
echo "Skip LEF syntax:            $bpv_skip_lef_syntax"
echo "Pin text layer for poly:    $poly_pin_text_layer"
echo "      ---\"---      metal1:  $m1_pin_text_layer"
echo "      ---\"---      metal2:  $m2_pin_text_layer"
echo "      ---\"---      metal3:  $m3_pin_text_layer"
echo "      ---\"---      metal4:  $m4_pin_text_layer"
echo "      ---\"---      metal5:  $m5_pin_text_layer"
echo "      ---\"---      metal6:  $m6_pin_text_layer"
echo "      ---\"---      metal7:  $m7_pin_text_layer"
echo "      ---\"---      metal8:  $m8_pin_text_layer"
echo "      ---\"---      metal9:  $m9_pin_text_layer"
echo "      ---\"---     metal10:  $m10_pin_text_layer"
echo "      ---\"---     metal11:  $m11_pin_text_layer"
echo "      ---\"---     metal12:  $m12_pin_text_layer"
echo "Must-connect layer for poly: $poly_must_connect_layer"
echo "      ---\"---        metal1: $m1_must_connect_layer"
echo "      ---\"---        metal2: $m2_must_connect_layer"
echo "      ---\"---        metal3: $m3_must_connect_layer"
echo "      ---\"---        metal4: $m4_must_connect_layer"
echo "      ---\"---        metal5: $m5_must_connect_layer"
echo "      ---\"---        metal6: $m6_must_connect_layer"
echo "      ---\"---        metal7: $m7_must_connect_layer"
echo "      ---\"---        metal8: $m8_must_connect_layer"
echo "      ---\"---        metal9: $m9_must_connect_layer"
echo "      ---\"---       metal10: $m10_must_connect_layer"
echo "      ---\"---       metal11: $m11_must_connect_layer"
echo "      ---\"---       metal12: $m12_must_connect_layer"
echo "Contact codes for std cells:  $std_cell_contacts"
echo "Skip rotated contacts?:       $std_cell_skip_rotated_vias"
echo "Blockage setting for poly:    $block_macro_layer_poly"
echo "     ---\"---       metal1:  $block_macro_layer_m(1)"
echo "     ---\"---       metal2:  $block_macro_layer_m(2)"
echo "     ---\"---       metal3:  $block_macro_layer_m(3)"
echo "     ---\"---       metal4:  $block_macro_layer_m(4)"
echo "     ---\"---       metal5:  $block_macro_layer_m(5)"
echo "     ---\"---       metal6:  $block_macro_layer_m(6)"
echo "     ---\"---       metal7:  $block_macro_layer_m(7)"
echo "     ---\"---       metal8:  $block_macro_layer_m(8)"
echo "     ---\"---       metal9:  $block_macro_layer_m(9)"
echo "     ---\"---      metal10:  $block_macro_layer_m(10)"
echo "     ---\"---      metal11:  $block_macro_layer_m(11)"
echo "     ---\"---      metal12:  $block_macro_layer_m(12)"
echo "Threshold for merging:        $merge_threshold"
echo "Global edge distance:         $edge_distance"
echo "Rotation of I/O cells:        $pad_rotation"
echo "Extract FRAM property:        $extract_fram_property"
echo "Extract implant width:        $implant_width"
echo "Extract diffusion:            $diffusion_width_height"
echo "Source/Drain file:            $source_drain_annotation"
echo "unit tile for FRAM property:  $tile_name"
echo ""

set _tmp_file [open rm_bpv_variable.txt w]
puts $_tmp_file "define BPV_PRECISE_CUT_METAL_BLOCKAGE 1"
puts $_tmp_file "define BPV_PGPowerRailPatternByMaskNum $bpv_power_rail_metal"
puts $_tmp_file "define BPV_PGGroundRailPatternByMaskNum $bpv_ground_rail_metal"
if {$bpv_skip_lef_syntax} {
puts $_tmp_file "define BPV_SKIP_DESIGNRULEWIDTH_SPACING_SYNTAX 1"
}
close $_tmp_file

auLoadScmFileToLib
setFormField load_scheme_file scheme_file_name rm_bpv_variable.txt
setFormField load_scheme_file library_name $ref_lib$library_name
formOK load_scheme_file

# 2) Sanity checks:
if {$std_cell_pin_layer != "1" && $std_cell_pin_layer != "2" && $std_cell_pin_layer != "3"} {
   echo "\n${flow_err_prefix} Invalid value for \$std_cell_pin_layer = \"$std_cell_pin_layer\".\n"
   echo "                            Valid values are 1, 2 or 3."
   exit
}

# 3) Read list of standard cells - to be processed with auExtractBlockagePinVia:
set _std_cell_list ""
set _std_cell_list_fileid [open $flow_stdcell_file r]
while {![eof $_std_cell_list_fileid]} {
   set _line [gets $_std_cell_list_fileid]
   if {$_line != ""} {lappend _std_cell_list $_line}
}
close $_std_cell_list_fileid

# 4) Read list of other cells - to be processed with geNewMakeMacro:
set _other_cell_list ""
set _nonstd_cell_list_fileid [open $flow_nonstdcell_file r]
while {![eof $_nonstd_cell_list_fileid]} {
   set _line [gets $_nonstd_cell_list_fileid]
   if {$_line != ""} {lappend _other_cell_list $_line}
}
close $_nonstd_cell_list_fileid

####################

#set external_pin_file [lindex $max_db_models 0]
#dbSetMsgLevel h

####################

# 5) Create the FRAM views for Standard Cells:

if {$bpv_flag_file != ""} {
auLoadScmFileToLib
setFormField load_scheme_file scheme_file_name $bpv_flag_file
setFormField load_scheme_file library_name $ref_lib$library_name
formOK load_scheme_file
} 

set _cell_counter 0
if { [llength $_std_cell_list] != 0 } {
   auExtractBlockagePinVia
   formDefault extract_blockage
   setFormField extract_blockage library_name $ref_lib$library_name

   # Blockage settings:
   formButton extract_blockage extractBlkg
   setFormField extract_blockage routing_blockage_output_layer metBlk

   # Pin settings:
   formButton extract_blockage extractPin
   if { $std_cell_pin_layer != 1 } {
      setFormField extract_blockage extract_connectivity 1
      setToggleField extract_blockage through via1 0
      setToggleField extract_blockage through via2 0
      setToggleField extract_blockage through via3 0
      setToggleField extract_blockage through via4 0
      setToggleField extract_blockage through via5 0
      setToggleField extract_blockage through via6 0
      setToggleField extract_blockage through via11 0
      setToggleField extract_blockage through via10 0
      setToggleField extract_blockage through via9 0
      setToggleField extract_blockage through via8 0
      setToggleField extract_blockage through via7 0
   }
   if { $std_cell_pin_layer == 2 } {
      setToggleField extract_blockage through via1 1
#      setToggleField extract_blockage transfer_pin_on_layer m2 1
   }
   if { $std_cell_pin_layer == 3 } {
      setToggleField extract_blockage through via1 1
      setToggleField extract_blockage through via2 1
#      setToggleField extract_blockage transfer_pin_on_layer m2 1
#      setToggleField extract_blockage transfer_pin_on_layer m3 1
   }
   setFormField extract_blockage poly_text   $poly_pin_text_layer
   setFormField extract_blockage metal1_text $m1_pin_text_layer
   setFormField extract_blockage metal2_text $m2_pin_text_layer
   setFormField extract_blockage metal3_text $m3_pin_text_layer
   setFormField extract_blockage metal4_text $m4_pin_text_layer
   formButton   extract_blockage pinConnArea
   setFormField extract_blockage poly_pin $poly_must_connect_layer
   setFormField extract_blockage m1_pin   $m1_must_connect_layer
   setFormField extract_blockage m2_pin   $m2_must_connect_layer
   setFormField extract_blockage m3_pin   $m3_must_connect_layer
   setFormField extract_blockage m4_pin   $m4_must_connect_layer

   # Via settings:
   formButton   extract_blockage extractVia
   setFormField extract_blockage contact_selection $std_cell_contacts
   setFormField extract_blockage extract_via_region_up_to_metal [expr $std_cell_pin_layer + 1]
   setFormField extract_blockage skip_rotated_vias $std_cell_skip_rotated_vias

   foreach _current_cell_name $_std_cell_list {
      incr _cell_counter
      echo ""
      echo ""
      echo "${flow_info_prefix} Processing cell $_current_cell_name \($_cell_counter of [llength $_std_cell_list]\)"
      setFormField extract_blockage cell_name $_current_cell_name
      formApply    extract_blockage
   }
   formCancel extract_blockage
}

# 6) Create the FRAM views for Macros, pads, etc. May need some adjustments depending on the cell content!
set _cell_counter 0
if { [llength $_other_cell_list] != 0 } {
   geNewMakeMacro
   formDefault make_macro
   setFormField make_macro library_name $ref_lib$library_name
   #setFormField make_macro hierarchical_smash 0 ; # Default = 0

   # ---Blockage settings (may require changes)---
   # All options for blockages are listed first with the default values,
   # followed by the settings taken from the configuration file.
   formButton make_macro extractBlkg

   setFormField make_macro preserve_all_metal_blockage      0 ; # Default = 0
   setFormField make_macro treat_all_blockage_as_thin_wire  0 ; # Default = 0
   setFormField make_macro open_soft_macro_push-down_shapes 0 ; # Default = 0

   setFormField make_macro routing_blockage_output_layer metBlk ; # Default = rGuide   Available = zeroG, metBlk, rGuide

   setFormField make_macro poly_blockage_as_thin    0 ; # Default = 0
   setFormField make_macro metal1_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal2_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal3_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal4_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal5_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal6_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal7_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal8_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal9_blockage_as_thin  0 ; # Default = 0
   setFormField make_macro metal10_blockage_as_thin 0 ; # Default = 0
   setFormField make_macro metal11_blockage_as_thin 0 ; # Default = 0
   setFormField make_macro metal12_blockage_as_thin 0 ; # Default = 0

   setFormField make_macro poly     "block all" ; # Default = "block all"
   setFormField make_macro metal_1  "block all" ; # Default = "block all"
   setFormField make_macro metal_2  "block all" ; # Default = "block all"
   setFormField make_macro metal_3  "block all" ; # Default = "block all"
   setFormField make_macro metal_4  "block all" ; # Default = "block all"
   setFormField make_macro metal_5  "block all" ; # Default = "block all"
   setFormField make_macro metal_6  "block all" ; # Default = "block all"
   setFormField make_macro metal_7  "block all" ; # Default = "block all"
   setFormField make_macro metal_8  "block all" ; # Default = "block all"
   setFormField make_macro metal_9  "block all" ; # Default = "block all"
   setFormField make_macro metal_10 "block all" ; # Default = "block all"
   setFormField make_macro metal_11 "block all" ; # Default = "block all"
   setFormField make_macro metal_12 "block all" ; # Default = "block all"

   setFormField make_macro poly_x-threshold     $merge_threshold ; # Default = 0.000
   setFormField make_macro poly_y-threshold     $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_1_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_1_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_2_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_2_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_3_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_3_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_4_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_4_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_5_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_5_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_6_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_6_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_7_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_7_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_8_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_8_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_9_x-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_9_y-threshold  $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_10_x-threshold $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_10_y-threshold $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_11_x-threshold $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_11_y-threshold $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_12_x-threshold $merge_threshold ; # Default = 0.000
   setFormField make_macro metal_12_y-threshold $merge_threshold ; # Default = 0.000

   setFormField make_macro poly_feedthru_layer     "" ; # Default = ""
   setFormField make_macro metal_1_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_2_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_3_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_4_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_5_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_6_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_7_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_8_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_9_feedthru_layer  "" ; # Default = ""
   setFormField make_macro metal_10_feedthru_layer "" ; # Default = ""
   setFormField make_macro metal_11_feedthru_layer "" ; # Default = ""
   setFormField make_macro metal_12_feedthru_layer "" ; # Default = ""

   # Settings from setup.tcl
   if {$block_macro_layer_poly == "none"} {setFormField make_macro poly merge}
   if {$block_macro_layer_poly == "merge"} {
      setFormField make_macro poly merge
      setFormField make_macro poly_core_blockage $edge_distance
   }
   for {set ly 1} {$ly <= 12} {incr ly} {
      if {$block_macro_layer_m($ly) == "none"} {setFormField make_macro metal_$ly merge}
      if {$block_macro_layer_m($ly) == "merge"} {
         setFormField make_macro metal_$ly merge
         setFormField make_macro metal_$ly\_core_blockage $edge_distance
      }
   }

   # ---Pin settings---
   # All options for pin are listed with the default values

   formButton make_macro extractPin
   setFormField make_macro identify_macro_pin_by_pin_text 1 ; # Default = 0
   setFormField make_macro extract_connectivity 0 ; # Default = 0

   setToggleField make_macro through polycont 0 ; # Default = 0
   setToggleField make_macro through via1     1 ; # Default = 1
   setToggleField make_macro through via2     1 ; # Default = 1
   setToggleField make_macro through via3     1 ; # Default = 1
   setToggleField make_macro through via4     1 ; # Default = 1
   setToggleField make_macro through via5     1 ; # Default = 1
   setToggleField make_macro through via6     1 ; # Default = 1
   setToggleField make_macro through via7     1 ; # Default = 1
   setToggleField make_macro through via8     1 ; # Default = 1
   setToggleField make_macro through via9     1 ; # Default = 1
   setToggleField make_macro through via10    1 ; # Default = 1
   setToggleField make_macro through via11    1 ; # Default = 1

   setFormField make_macro expand_small_pin_on_blockage_for_contact_connection 0 ; # Default = 0
   setFormField make_macro text_fall_through   0 ; # Default = 0
   setFormField make_macro double_fall_through 0 ; # Default = 0

   # Settings from setup.tcl
   setFormField make_macro poly_text   $poly_pin_text_layer
   setFormField make_macro metal1_text $m1_pin_text_layer
   setFormField make_macro metal2_text $m2_pin_text_layer
   setFormField make_macro metal3_text $m3_pin_text_layer
   setFormField make_macro metal4_text $m4_pin_text_layer
   setFormField make_macro metal5_text $m5_pin_text_layer
   setFormField make_macro metal6_text $m6_pin_text_layer
   setFormField make_macro metal7_text $m7_pin_text_layer
   setFormField make_macro metal8_text $m8_pin_text_layer
   setFormField make_macro metal9_text $m9_pin_text_layer
   setFormField make_macro metal10_text $m10_pin_text_layer
   setFormField make_macro metal11_text $m11_pin_text_layer
   setFormField make_macro metal12_text $m12_pin_text_layer

   # Settings from setup.tcl
   formButton   make_macro pinConnArea
   setFormField make_macro poly_pin $poly_must_connect_layer
   setFormField make_macro m1_pin $m1_must_connect_layer
   setFormField make_macro m2_pin $m2_must_connect_layer
   setFormField make_macro m3_pin $m3_must_connect_layer
   setFormField make_macro m4_pin $m4_must_connect_layer
   setFormField make_macro m5_pin $m5_must_connect_layer
   setFormField make_macro m6_pin $m6_must_connect_layer
   setFormField make_macro m7_pin $m7_must_connect_layer
   setFormField make_macro m8_pin $m8_must_connect_layer
   setFormField make_macro m9_pin $m9_must_connect_layer
   setFormField make_macro m10_pin $m10_must_connect_layer
   setFormField make_macro m11_pin $m11_must_connect_layer
   setFormField make_macro m12_pin $m12_must_connect_layer

   formButton make_macro pinAutoArea
   setFormField make_macro poly_pin_connect_area_width_threshold 0.000 ; # Default = 0.000
   setFormField make_macro m1_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m2_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m3_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m4_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m5_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m6_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m7_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m8_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m9_pin_connect_area_width_threshold   0.000 ; # Default = 0.000
   setFormField make_macro m10_pin_connect_area_width_threshold  0.000 ; # Default = 0.000
   setFormField make_macro m11_pin_connect_area_width_threshold  0.000 ; # Default = 0.000
   setFormField make_macro m12_pin_connect_area_width_threshold  0.000 ; # Default = 0.000


   # ---Via settings - normally not used for macros---
   setFormField make_macro extract_vias_within_pin_area_only 0 ; # Default = 0
   setToggleField make_macro extract polycont 0 ; # Default = 0
   setToggleField make_macro extract via1     0 ; # Default = 0
   setToggleField make_macro extract via2     0 ; # Default = 0
   setToggleField make_macro extract via3     0 ; # Default = 0
   setToggleField make_macro extract via4     0 ; # Default = 0
   setToggleField make_macro extract via5     0 ; # Default = 0
   setToggleField make_macro extract via6     0 ; # Default = 0
   setToggleField make_macro extract via7     0 ; # Default = 0
   setToggleField make_macro extract via8     0 ; # Default = 0
   setToggleField make_macro extract via9     0 ; # Default = 0
   setToggleField make_macro extract via10    0 ; # Default = 0
   setToggleField make_macro extract via11    0 ; # Default = 0

   # Run the command for each non-standard cell:
   foreach _current_cell_name $_other_cell_list {
      incr _cell_counter
      echo ""
      echo "\n${flow_info_prefix} Processing cell $_current_cell_name \($_cell_counter of [llength $_other_cell_list]\)"
      setFormField make_macro cell_name $_current_cell_name\.SMASH
      formApply make_macro
   }
   formCancel make_macro
}

set fram_property_options ""
   if {$implant_width} {
      set option "-implant_width true"
      append fram_property_options $option
   }
   if {$diffusion_width_height} {
      set option " -diffusion_width_height true"
      append fram_property_options $option
      }
   if {$source_drain_annotation != ""} {
      set option " -source_drain_annotation $source_drain_annotation"
      append fram_property_options $option
      }
   if {$tile_name != ""} {
      set option " -unit_tile $tile_name"
      append fram_property_options $option
      }

if {$extract_fram_property} {
      foreach _current_cell_name $_std_cell_list {
      incr _cell_counter
      eval extract_fram_property -lib $ref_lib$library_name \
      -cell $_current_cell_name \
      $fram_property_options
      echo ""
      echo ""
      echo "${flow_info_prefix} Processing cell for FRAM property extraction $_current_cell_name \($_cell_counter of [llength $_std_cell_list]\)"
  }
  report_fram_property -lib $ref_lib$library_name -cell * -output dump/report_fram_property.out    
} 

# 7) Rotate I/O cells:
if {$pad_rotation != ""} {
   if { [file size $flow_iocell_file] != 0 } {
      echo "\n${flow_info_prefix} >> Rotating all I/O cells by $pad_rotation degrees."
      set _clf_fileid [open $flow_padrotate_clf_file w]
      puts $_clf_fileid "definePad \"*\" \"$pad_rotation\""
      close $_clf_fileid

      auLoadCLF
      setFormField load_clf_file load_clf_file_without_timing_related_information 1
      setFormField load_clf_file library_name $ref_lib$library_name
      setFormField load_clf_file clf_file_name $flow_padrotate_clf_file
      formOK load_clf_file
   } else {
      echo "\n${flow_warn_prefix} No I/O cells found in the library."
      echo "                              No rotation can be applied."
   }
}

#dbDumpGPortTable $ref_lib$library_name dump/Gports_initial.out

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"bpv\" step (variable \$run_step = 0)."
}
exec touch touchfiles/bpv

exit
