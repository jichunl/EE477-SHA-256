##########################################################################
# Physical Library Preparation Reference Methodology <read_final_gds> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# read_final_gds.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_final_gds} {

echo "\n${flow_info_prefix} Running step \"read_final_gds\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "GDS input file:             $gds_file"
echo "Global cell type:           $gds_all_cell_type"
echo "Cell type mapping file:     $gds_cell_type_file"
echo "Delete LM views:            $delete_LM_views"
echo ""


# 2) Sanity checks:
if { $gds_file == "" || [file exists $gds_file] == 0 } {
   echo "${flow_err_prefix} GDS file $gds_file not found or variable \$gds_file not set."
   exit
}
if { $gds_all_cell_type == "" && $gds_cell_type_file != "" && [file exists $gds_cell_type_file] == 0 } {
   echo "${flow_err_prefix} GDS cell type file $gds_cell_type_file not found."
   echo ""
   exit
}

# 3) Auto-create cell type file
if {$gds_all_cell_type != ""} {
   echo "${flow_info_prefix} All cells will be marked as type $gds_all_cell_type."
   set _cell_type_fileid [open $flow_celltype_file w]
   puts $_cell_type_fileid "$gds_all_cell_type *"
   close $_cell_type_fileid
   set gds_cell_type_file $flow_celltype_file
}


# 4) Read list of all cells in library
set _cell_list ""

set _std_cell_list_fileid [open $flow_stdcell_file r]
while {![eof $_std_cell_list_fileid]} {
   set _line [gets $_std_cell_list_fileid]
   if {$_line != ""} {lappend _cell_list $_line}
}
close $_std_cell_list_fileid

set _nonstd_cell_list_fileid [open $flow_nonstdcell_file r]
while {![eof $_nonstd_cell_list_fileid]} {
   set _line [gets $_nonstd_cell_list_fileid]
   if {$_line != ""} {lappend _cell_list $_line}

}
close $_nonstd_cell_list_fileid

set _unspecified_cell_list ""
set _unspecified_cell_list_fileid [open $flow_unspecifiedcell_file r]
while {![eof $_unspecified_cell_list_fileid]} {
   set _line [gets $_unspecified_cell_list_fileid]
   if {$_line != ""} {lappend _unspecified_cell_list $_line}

}
close $_unspecified_cell_list_fileid


# 5) Purge old CEL views, unneeded FRAM views and all SMASH views
open_mw_lib $ref_lib$library_name

geDeleteCell
setFormField delete_cell pattern_match 1
foreach_in_collection _current_cell [get_mw_cels] {
   set _current_cell_name [get_attribute $_current_cell name]
   if { $_current_cell_name != "unitTile" } {
      setFormField delete_cell cell_name $_current_cell_name\.CEL\;.*
      formApply delete_cell
   }
   if { [lsearch -exact $_cell_list $_current_cell_name] == -1 } {
      setFormField delete_cell cell_name $_current_cell_name\.FRAM\;.*
      formApply delete_cell
   }
   if {$_current_cell_name != "unitTile" && [lsearch -exact $_unspecified_cell_list $_current_cell_name] != -1 } {
      setFormField delete_cell cell_name $_current_cell_name\.*\;.*
      formApply delete_cell
   }
}
setFormField delete_cell cell_name .*\.SMASH\;.*
formApply delete_cell
exec /bin/rm -rf ${ref_lib}${library_name}/SMASH

if {$delete_LM_views} {
   setFormField delete_cell cell_name .*\.LM\;.*
   formApply delete_cell
   exec /bin/rm -rf ${ref_lib}${library_name}/LM
}
formCancel delete_cell


# 6) Only keep the newest version of the unitTile cell
gePurgeCell
setFormField purge_cell cell_name unitTile
setFormField purge_cell reset_version 1
formOK purge_cell

close_mw_lib $ref_lib$library_name

# 7) Read GDS file again - no layer mapping this time
auStreamInRectilinearBoundary 1

read_gds -lib_name $ref_lib$library_name \
         -cell_type $gds_cell_type_file \
         $gds_file

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"read_final_gds\" step (variable \$run_final_gds = 0)."
}

exec touch touchfiles/${library_name}.read_final_gds

exit
