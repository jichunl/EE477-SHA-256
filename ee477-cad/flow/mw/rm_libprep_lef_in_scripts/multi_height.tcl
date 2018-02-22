##########################################################################
# Physical Library Preparation Reference Methodology <multi_height> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# multi_height.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_step} {

# 2) Do nothing if the library does not contain any standard cells:
set _std_cell_list ""
set _std_cell_list_fileid [open $flow_stdcell_file r]
while {![eof $_std_cell_list_fileid]} {
   set _line [gets $_std_cell_list_fileid]
   if {$_line != ""} {lappend _std_cell_list $_line}
}
close $_std_cell_list_fileid

if { [llength $_std_cell_list] == 0 } {
   echo "\n${flow_info_prefix} No standard cells in the library - skipping step multi_height."
   exec touch touchfiles/${library_name}.multi_height
   exit
}

echo "\n${flow_info_prefix} Running step \"multi_height\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo ""

# 3) Run cmSetMultiHeightProperty on the FRAM views of all standard cells in the library:
set _cell_counter 0

cmSetMultiHeightProperty
formDefault set_multiple_height_pr_boundary
setFormField set_multiple_height_pr_boundary library_name $ref_lib$library_name
setFormField set_multiple_height_pr_boundary cell_name ".*.FRAM"

foreach _current_cell_name $_std_cell_list {
   incr _cell_counter
   echo "\n${flow_info_prefix} Processing cell $_current_cell_name \($_cell_counter of [llength $_std_cell_list]\)"
   setFormField set_multiple_height_pr_boundary cell_name "$_current_cell_name.FRAM"
   formApply set_multiple_height_pr_boundary
}

formCancel set_multiple_height_pr_boundary

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"multi-height\" step (variable \$run_step = 0)."
}

exec touch touchfiles/${library_name}.multi_height

exit
