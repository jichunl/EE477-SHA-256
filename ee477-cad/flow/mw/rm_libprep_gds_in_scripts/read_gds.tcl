##########################################################################
# Physical Library Preparation Reference Methodology <read_gds> for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# read_gds.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

echo "\n${flow_info_prefix} Running step \"read_gds\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Top macro name:             $top_macro_name"
echo "GDS input file:             $gds_file"
echo "Global cell type:           $gds_all_cell_type"
echo "Cell type mapping file:     $gds_cell_type_file"
echo "Cell boundary layer:        $gds_boundary_layer"
echo "Layer mapping file:         $gds_layer_file"
echo ""


# 2) Sanity checks:
if { $gds_file == "" || [file exists $gds_file] == 0 } {
   echo "${flow_err_prefix} GDS file $gds_file not found or variable \$gds_file not set."
   exit
}
if { $gds_layer_file != "" && [file exists $gds_layer_file] == 0 } {
   echo "${flow_err_prefix} GDS layer file $gds_layer_file not found."
   exit
}
if { $gds_all_cell_type == "" && $gds_cell_type_file != "" && [file exists $gds_cell_type_file] == 0 } {
   echo "${flow_err_prefix} GDS cell type file $gds_cell_type_file not found."
   exit
}

# 3) Auto-create cell type file:
if {$gds_all_cell_type != ""} {
   echo "${flow_info_prefix} All cells will be marked as type $gds_all_cell_type."
   set _cell_type_fileid [open $flow_celltype_file w]
   puts $_cell_type_fileid "$gds_all_cell_type *"
   close $_cell_type_fileid
   set gds_cell_type_file $flow_celltype_file
}


# 4) Read GDS file:
auStreamInRectilinearBoundary 1

if { $gds_boundary_layer != "" } {
   read_gds -lib_name $ref_lib$library_name \
            -cell_type $gds_cell_type_file \
            -use_boundary_layer_as_geometry \
            -boundary_layer_map $gds_boundary_layer \
            -layer_mapping $gds_layer_file \
            $gds_file
} else {
   read_gds -lib_name $ref_lib$library_name \
            -cell_type $gds_cell_type_file \
            -layer_mapping $gds_layer_file \
            $gds_file
}

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

exec touch touchfiles/read_gds

exit
