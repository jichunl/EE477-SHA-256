##########################################################################
# Physical Library Preparation Reference Methodology <smash> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# smash.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_step} {

echo "\n${flow_info_prefix} Running step \"smash\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Smashing level:             $smash_level"
if {$pin_name_truncate_string != ""} {
   echo "Truncating texts after:     \"$pin_name_truncate_string\""
}

if {$replace_char_from_1 != ""} {
   echo "Replace characters:         \"$replace_char_from_1\" --> \"$replace_char_to_1\""
}
if {$replace_char_from_2 != ""} {
   echo "Replace characters:         \"$replace_char_from_2\" --> \"$replace_char_to_2\""
}
echo ""

# 2) Sanity check:
open_mw_lib $ref_lib$library_name
if {[sizeof_collection [get_mw_cels]] == 0} {
   echo "${flow_err_prefix} Library $ref_lib$library_name is empty."
   exit
}
close_mw_lib $ref_lib$library_name

# 3) Truncate pin names
if {$pin_name_truncate_string != ""} {
   open_mw_lib $ref_lib$library_name
   dbTruncateText [dbGetCurrentLibId] $pin_name_truncate_string
   close_mw_lib $ref_lib$library_name
}

# 4) Replace characters - i.e. to patch bus naming styles
if {$replace_char_from_1 != ""} {
   open_mw_lib $ref_lib$library_name
   dbReplaceTextChar [dbGetCurrentLibId] $replace_char_from_1 $replace_char_to_1
   close_mw_lib $ref_lib$library_name
}
if {$replace_char_from_2 != ""} {
   open_mw_lib $ref_lib$library_name
   dbReplaceTextChar [dbGetCurrentLibId] $replace_char_from_2 $replace_char_to_2
   close_mw_lib $ref_lib$library_name
}

# 5) Smash all cells
cmSmash
formDefault smash
setFormField smash library_name $ref_lib$library_name
setFormField smash level $smash_level
setFormField smash also_change_original_view_port_name 0
setFormField smash output_to "SMASH View"
setFormField smash other 1
formOK smash

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"smash\" step (variable \$run_step = 0)."
}

exec touch touchfiles/${library_name}.smash

exit
