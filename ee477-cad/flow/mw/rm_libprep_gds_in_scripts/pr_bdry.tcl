##########################################################################
# Physical Library Preparation Reference Methodology <pr_bdry> for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# pr_bdry.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_step} {

echo "\n${flow_info_prefix} Running step \"pr_bdry\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Unit tile height:           $unit_tile_height"
echo "Metal 1 PG rail:            $metal1_pg_rail"
echo "Metal 2 PG rail:            $metal2_pg_rail"
echo ""


# 2) Do nothing if the library does not contain any standard cells
set _std_cell_list ""
set _std_cell_list_fileid [open $flow_stdcell_file r]
while {![eof $_std_cell_list_fileid]} {
   set _line [gets $_std_cell_list_fileid]
   if {$_line != ""} {lappend _std_cell_list $_line,}
}
close $_std_cell_list_fileid

if { [llength $_std_cell_list] == 0 } {
   echo "\n${flow_info_prefix} No standard cells in the library - skipping step pr_bdry."
   exec touch pr_bdry
   exit
}

# 3) Sanity check
if {$unit_tile_height <= "0" || $unit_tile_height == ""} {
   echo "\n${flow_err_prefix} The unit tile height is incorrect or not defined.\n"
   exit
}

# 4) Create the unitTile cell and PR Boundaries in FRAM views

if { [llength $_std_cell_list] != 0 } {
auSetPRBdry
formDefault set_pr_boundary
setFormField set_pr_boundary library_name $ref_lib$library_name
setFormField set_pr_boundary allorn all
setFormField set_pr_boundary height specify
setFormField set_pr_boundary height_value $unit_tile_height
setFormField set_pr_boundary adjacent_rows "shared P/G (double-back)"
setFormField set_pr_boundary multiple_(2x,_3x) "based on cell height"
setFormField set_pr_boundary left_boundary specify
setFormField set_pr_boundary left_from "Origin (0,0)"
setFormField set_pr_boundary left_offset 0.00

if {$metal1_pg_rail == 1 && $metal2_pg_rail == 1} {
   setFormField set_pr_boundary 1st_layer_parallel_to_p/g_rail Metal2
   setFormField set_pr_boundary 1st_layer_perpendicular_to_p/g_rail Metal3
} elseif {$metal1_pg_rail == 0 && $metal2_pg_rail == 1} {
   setFormField set_pr_boundary 1st_layer_parallel_to_p/g_rail Metal2
   setFormField set_pr_boundary 1st_layer_perpendicular_to_p/g_rail Metal1
} else {
   setFormField set_pr_boundary 1st_layer_parallel_to_p/g_rail Metal1
   setFormField set_pr_boundary 1st_layer_perpendicular_to_p/g_rail Metal2
}
formOK set_pr_boundary
}
} else {
   echo "\n${flow_info_prefix} >> Skipping the \"pr_bdry\" step (variable \$run_step = 0)."
}

exec touch touchfiles/pr_bdry

exit
