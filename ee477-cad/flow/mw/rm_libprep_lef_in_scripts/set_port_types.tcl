##########################################################################
# Physical Library Preparation Reference Methodology <set_port_types> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# set_port_types.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

if {$run_step} {

echo "\n${flow_info_prefix} Running step \"set_port_types\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "List of power pins:         $power_pin_list"
echo "List of ground pins:        $ground_pin_list"
echo "List of bias power pins:    $bias_power_pin_list"
echo "List of bias ground pins:   $bias_ground_pin_list"
echo ""


# 2) Sanity checks
if {$power_pin_list == ""} {
   echo "${flow_warn_prefix} The power port list (\$power_pin_list) is empty."
   echo "                              No power ports will be marked in the library."
   echo ""
}
if {$ground_pin_list == ""} {
   echo "${flow_warn_prefix} The ground port list (\$ground_pin_list) is empty."
   echo "                              No ground ports will be marked in the library."
   echo ""
}
if {$bias_power_pin_list == ""} {
   echo "${flow_warn_prefix} The bias power port list (\$bias_power_pin_list) is empty."
   echo "                              No bias power ports will be marked in the library."
   echo ""
}
if {$bias_ground_pin_list == ""} {
   echo "${flow_warn_prefix} The bias ground port list (\$bias_ground_pin_list) is empty."
   echo "                              No bias ground ports will be marked in the library."
   echo ""
}

# 3) Generate file with power/ground port assignments
set _port_type_fileid [open $flow_porttype_file w]
puts $_port_type_fileid "dbSetCellPortTypes \"$ref_lib$library_name\" \"*\" \'("
foreach _port_name $power_pin_list {
   puts $_port_type_fileid "(\"$_port_name\" \"Inout\" \"Power\")"
}
foreach _port_name $ground_pin_list {
   puts $_port_type_fileid "(\"$_port_name\" \"Inout\" \"Ground\")"
}
foreach _port_name $bias_power_pin_list {
   puts $_port_type_fileid "(\"$_port_name\" \"Inout\" \"Power\")"
}
foreach _port_name $bias_ground_pin_list {
   puts $_port_type_fileid "(\"$_port_name\" \"Inout\" \"Ground\")"
}
puts $_port_type_fileid ") #f"
close $_port_type_fileid

# 4) Load the file containing the port type assignments
auLoadScmFileToLib
setFormField load_scheme_file library_name $ref_lib$library_name
setFormField load_scheme_file scheme_file_name $flow_porttype_file
formOK load_scheme_file

} else {
   echo "\n${flow_info_prefix} >> Skipping the \"set_port_types\" step (variable \$run_step = 0)."
}

exec touch touchfiles/${library_name}.set_port_types

exit
