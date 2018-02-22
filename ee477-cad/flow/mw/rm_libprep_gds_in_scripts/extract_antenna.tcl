##########################################################################
# Physical Library Preparation Reference Methodology <extract_antenna> for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# extract_antenna.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

echo "\n${flow_info_prefix} Running step \"extract_antenna\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Input CLF file (if used):   $antenna_clf_file"
echo "Diffusion layer:            $diffusion_layer"
echo "Poly layer:                 $poly_layer"
echo "Contact layer:              $cont_layer"
echo "V0 layer:                   $v0_layer"
echo "M0 layer for poly:          $m0_poly_layer"
echo "M0 layer for diffusion:     $m0_diff_layer"
echo "Contact layer for M0:       $cont_m0_diff_layer"
echo "Additional gate class:      $gate_class"
echo "Thick gate mask1 layer:     $thick_mask1_layer"
echo "Thick gate mask2 layer:     $thick_mask2_layer"
echo "Thick gate mask3 layer:     $thick_mask3_layer"
echo "CLF dump for checking:      $flow_dump_clf_file"
echo ""

# 2) Sanity checks:
if {$diffusion_layer == "" && $antenna_clf_file == ""} {
   echo "${flow_err_prefix} Diffusion layer variable \$diffusion_layer not set."
   exit
}
if {[file exists $antenna_clf_file] == 0 && $antenna_clf_file != ""} {
   echo "${flow_err_prefix} Antenna CLF file $antenna_clf_file does not exist."
   exit
}

# Extract the antenna properties (unless a CLF file is provided):
if {$antenna_clf_file == ""} {

   # 3) Create list of cell to process - read from previosly stored list of cells
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


   # 4) Extract and store the antenna properties
   signoffHierAntenna
   formDefault signoff_hierarchical_antenna_report
   setFormField signoff_hierarchical_antenna_report library_name $ref_lib$library_name
   #setFormField signoff_hierarchical_antenna_report library_path $ref_lib
   setFormField signoff_hierarchical_antenna_report diffusion $diffusion_layer
   setFormField signoff_hierarchical_antenna_report poly $poly_layer
   setFormField signoff_hierarchical_antenna_report contact $cont_layer
   setFormField "Signoff Hierarchical Antenna Report" "V0 (between M1 and M0)" $v0_layer
   setFormField "Signoff Hierarchical Antenna Report" "M0 (for Poly connection)" $m0_poly_layer
   setFormField "Signoff Hierarchical Antenna Report" "M0 (for Diffusion connection)" $m0_diff_layer
   setFormField "Signoff Hierarchical Antenna Report" "Contact (between M0 and Diffusion)" $cont_m0_diff_layer
   if {$gate_class} {
   setFormField "Signoff Hierarchical Antenna Report" "Additional Gate Thickness Class" "1"
   #formButton "Signoff Hierarchical Antenna Report" "Gate_Class"
   setFormField "Signoff Hierarchical Antenna Report" "Thick gate mask 1" $thick_mask1_layer
   setFormField "Signoff Hierarchical Antenna Report" "Thick gate mask 2" $thick_mask2_layer
   setFormField "Signoff Hierarchical Antenna Report" "Thick gate mask 3" $thick_mask3_layer
   subFormHide "Signoff Hierarchical Antenna Report" 1
   }
 
   set _cell_counter 0
   foreach _current_cell $_cell_list {
      incr _cell_counter
      echo "\n${flow_info_prefix} Processing cell $_current_cell \($_cell_counter of [llength $_cell_list]\)"
      setFormField signoff_hierarchical_antenna_report cell_name $_current_cell
      formApply signoff_hierarchical_antenna_report
   }

   formCancel signoff_hierarchical_antenna_report

   # 5) Close library - may be open more than once from previous command
   set sh_continue_on_error true
   while { [dbGetCurrentLibId]} {
      dbCloseLib [dbGetCurrentLibId]
   }
   set sh_continue_on_error false

} else {
   # 6) Alternatively, read in CLF file with antenna properties
   echo "${flow_info_prefix} Loading antenna CLF file $antenna_clf_file\."
   auLoadCLF
   setFormField load_clf_file load_clf_file_without_timing_related_information 1
   setFormField load_clf_file library_name $ref_lib$library_name
   setFormField load_clf_file clf_file_name $antenna_clf_file
   formOK load_clf_file
}

# 7) Dump CLF file for checking
auDumpCLF
formDefault dump_clf_file
setFormField dump_clf_file clf_file_name $flow_dump_clf_file
setFormField dump_clf_file library_name $ref_lib$library_name
formOK dump_clf_file

echo "${flow_info_prefix} Antenna properties dumped to file $flow_dump_clf_file\."


exec touch touchfiles/extract_antenna

exit
