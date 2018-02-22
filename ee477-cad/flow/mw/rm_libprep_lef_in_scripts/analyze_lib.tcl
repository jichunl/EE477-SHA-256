##########################################################################
# Physical Library Preparation Reference Methodology <analyze_lib> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# analyze_lib.tcl

source [getenv FLOW_CONFIG]

if {$run_pin_access} {

echo "\n${flow_info_prefix} Running step \"analyze_lib\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Technology file:            $mw_techfile"
echo "Run routing:                $run_routing"
echo "Selected check cells:       $check_cell_list"
echo "Utility:                    ./rm_libprep_lef_in_scripts/check_std_cell_pin_access_$icc_platform.bin"
echo ""

# Do nothing if the library does not contain any standard cells
set _std_cell_list ""
set _std_cell_list_fileid [open $flow_stdcell_file r]
while {![eof $_std_cell_list_fileid]} {
   set _line [gets $_std_cell_list_fileid]
   if {$_line != ""} {lappend _std_cell_list $_line,}
}
close $_std_cell_list_fileid

if { [llength $_std_cell_list] == 0 } {
   echo "\n${flow_info_prefix} No standard cells in the library - skipping step analyze_lib."
   exec touch touchfiles/${library_name}.analyze_lib
   exit
}

# Run pin access check for standard cells in the library:
#rename_mw_lib -from check_lib.mw -to check_lib.mw_org
source ./rm_libprep_lef_in_scripts/check_std_cell_pin_access_$icc_platform.bin

if {$check_cell_list == "" && $run_routing == 1} {
check_std_cell_pin_access -std_lib_path $ref_lib$library_name -technology $mw_techfile -num_cells_per_parallel_run 100 -pin_access_check_tcl_path ./rm_libprep_lef_in_scripts/check_std_cell_pin_access_$icc_platform.bin
}

if {$check_cell_list == "" && $run_routing == 0} {
check_std_cell_pin_access -std_lib_path $ref_lib$library_name -technology $mw_techfile -num_cells_per_parallel_run 100 -pin_access_check_tcl_path ./rm_libprep_lef_in_scripts/check_std_cell_pin_access_$icc_platform.bin -skip_routing
}

if {$check_cell_list != "" && $run_routing == 1} {
check_std_cell_pin_access -std_lib_path $ref_lib$library_name -technology $mw_techfile -num_cells_per_parallel_run 100 -pin_access_check_tcl_path ./rm_libprep_lef_in_scripts/check_std_cell_pin_access_$icc_platform.bin -cells $check_cell_list -check_against_all_lib_cells
}

if {$check_cell_list != "" && $run_routing == 0} {
check_std_cell_pin_access -std_lib_path $ref_lib$library_name -technology $mw_techfile -num_cells_per_parallel_run 100 -pin_access_check_tcl_path ./rm_libprep_lef_in_scripts/check_std_cell_pin_access_$icc_platform.bin -cells $check_cell_list -check_against_all_lib_cells -skip_routing
}

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"analyze_lib\" step (variable \$run_pin_access = 0)."
}

exec touch touchfiles/${library_name}.analyze_lib

exit
