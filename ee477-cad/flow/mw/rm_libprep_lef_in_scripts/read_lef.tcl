##########################################################################
# Physical Library Preparation Reference Methodology <read_lef> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# read_lef.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

echo "\n${flow_info_prefix} Running step \"read_lef\" with the following settings:\n"
echo "Parameter                         Value"
echo "-----------------------           -------------------"
echo "Configuration file:               [getenv FLOW_CONFIG]"
echo "Library:                          $ref_lib$library_name"
echo "Top macro name:			$top_macro_name"
echo "Cell boundary from overlap layer: $boundary_by_overlap"
echo "LEF file:                         $lef_file"
if {$replace_char_from_1 != ""} {
   echo "Replace characters:         \"$replace_char_from_1\" --> \"$replace_char_to_1\""
}
if {$replace_char_from_2 != ""} {
   echo "Replace characters:         \"$replace_char_from_2\" --> \"$replace_char_to_2\""
}
echo ""

# 2) Sanity checks
if { $lef_file == "" || [file exists $lef_file] == 0 } {
   echo "${flow_err_prefix} LEF file not found or variable \$lef_file not set."
   exit
}

# 3) Patch lef file if character replacement is specified
#
set sed_script "busname_patch.sed"
set new_lef_file ./dump/square_[file tail $lef_file]

if {$replace_char_from_1 != ""} {
   redirect         $sed_script {echo "s/${replace_char_from_1}/${replace_char_to_1}/g"}
}
if {$replace_char_from_2 != ""} {
   redirect -append $sed_script {echo "s/${replace_char_from_2}/${replace_char_to_2}/g"}
}
if {[file exist $sed_script] == 1} {
   sh sed -f $sed_script $lef_file >$new_lef_file
} else {
   set new_lef_file $lef_file
}

# 4) Read LEF file:
if {$run_step} {
   echo "Turn on read_lef advanced mode"
 if {$boundary_by_overlap} {
   read_lef -lib_name $ref_lib$library_name \
         -layer_mapping $lef2MW_mapfile \
         -tech_lef_files $mw_tech_lef_file \
         -cell_lef_files $new_lef_file \
         -cell_boundary by_overlap_layer \
         -advanced_lib_prep_mode
 } else {
   read_lef -lib_name $ref_lib$library_name \
         -layer_mapping $lef2MW_mapfile \
         -tech_lef_files $mw_tech_lef_file \
         -cell_lef_files $new_lef_file \
         -advanced_lib_prep_mode
  }
} else {
   echo "Turn off read_lef advanced mode"
 if {$boundary_by_overlap} {
   read_lef -lib_name $ref_lib$library_name \
         -layer_mapping $lef2MW_mapfile \
         -tech_lef_files $mw_tech_lef_file \
         -cell_lef_files $new_lef_file \
         -cell_boundary by_overlap_layer 
 } else {
   read_lef -lib_name $ref_lib$library_name \
         -layer_mapping $lef2MW_mapfile \
         -tech_lef_files $mw_tech_lef_file \
         -cell_lef_files $new_lef_file 
  }
}

echo ""

### 4) Remove unneeded FRAM views
##
### Create a list of cells in the LEF file
##set keep_cell_list ""
##set _cell_list_fileid [open $new_lef_file r]
##while {![eof $_cell_list_fileid]} {
##   set _line [gets $_cell_list_fileid]
##   if {[string match "MACRO*" $_line]} {
##      set _tmp_list [split $_line]
##      echo "${flow_info_prefix} Found FRAM view to keep: [lindex $_tmp_list 1]"
##      lappend keep_cell_list [lindex $_tmp_list 1]
##   }
##}
##close $_cell_list_fileid
##
##
### Get all FRAM views
##open_mw_lib $ref_lib$library_name
##
##set _cell_list ""
##
##list_mw_cels -all_views > dump/lib_cells.txt
##
##set _cell_list_fileid [open dump/lib_cells.txt r]
##while {![eof $_cell_list_fileid]} {
##   set _line [gets $_cell_list_fileid]
##   if {[string match "*.FRAM" $_line]} {
##      lappend _cell_list [string replace $_line [string last "." $_line] 255]
##   }
##}
##close $_cell_list_fileid
##
### Remove all FRAM views except those to keep
##foreach candidate $_cell_list {
##   if {[lsearch $keep_cell_list $candidate] == -1} {
##      remove_mw_cel [string map {$ \\$} $candidate].FRAM
##   }
##}

# 5) Create lists of cells - used later in the flow
# The nonstd_cell list also contains the I/O cells
set _std_cell_list_fileid [open $flow_stdcell_file w]
set _io_cell_list_fileid [open $flow_iocell_file w]
set _nonstd_cell_list_fileid [open $flow_nonstdcell_file w]
set _unspecified_list_fileid [open $flow_unspecifiedcell_file w]

set _stdcell_count 0
set _nonstdcell_count 0
set _iocell_count 0
set _unspecified_count 0

open_mw_lib $ref_lib$library_name

suppress_message MWUI-068
foreach_in_collection _current_cell [get_mw_cels *] {
   set _current_cell_name [get_attribute $_current_cell name]
   open_mw_cel $_current_cell_name -readonly

   if { [string match -nocase "*unknow*" [get_attribute [current_mw_cel] mask_layout_type]] } {
      puts $_unspecified_list_fileid $_current_cell_name
      incr _unspecified_count
   } elseif { [string match -nocase "*std*" [get_attribute [current_mw_cel] mask_layout_type]] } {
      puts $_std_cell_list_fileid $_current_cell_name
      incr _stdcell_count
   } elseif {$top_macro_name==""}  {
      puts $_nonstd_cell_list_fileid $_current_cell_name
      incr _nonstdcell_count
   } elseif {$top_macro_name==$_current_cell_name} {
      puts $_nonstd_cell_list_fileid $top_macro_name
      incr _nonstdcell_count
   }

   if { [string match -nocase "*pad*" [get_attribute [current_mw_cel] mask_layout_type]] } {
      puts $_io_cell_list_fileid $_current_cell_name
      incr _iocell_count
   }

   close_mw_cel
}
unsuppress_message MWUI-068

close_mw_lib $ref_lib$library_name
close $_std_cell_list_fileid
close $_io_cell_list_fileid
close $_nonstd_cell_list_fileid

echo ""
echo "${flow_info_prefix} Summary of cells read into the library $ref_lib$library_name:"
echo "                           --------------------------------------------------------------"
echo "                           Total number of cells: [expr $_stdcell_count + $_nonstdcell_count + $_unspecified_count]"
echo "                               Unspecified cells: $_unspecified_count"
echo "                                  Standard cells: $_stdcell_count"
echo "                                       I/O cells: $_iocell_count"
echo "                               Other+macro cells: [expr $_nonstdcell_count - $_iocell_count]"

if { $_stdcell_count == 0 && $_nonstdcell_count == 0 && $_unspecified_count == 0 } {
   echo "${flow_err_prefix} Cells are not found in $flow_stdcell_file and $flow_nonstdcell_file."
   exit
}

convert_mw_lib -all $ref_lib$library_name

exec touch touchfiles/${library_name}.read_lef

exit
