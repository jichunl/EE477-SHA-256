##########################################################################
# Physical Library Preparation  Reference Methodology <create_ref_libs> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# create_ref_libs.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

# 2) Sanity checks:
if { $mw_techfile == "" || [file exists $mw_techfile] == 0 } {
   echo "${flow_err_prefix} Tech file not found or variable \$mw_techfile not set."
   exit
}
if { $library_name == "" } {
   echo "${flow_err_prefix} Library name variable \$library_name not set."
   exit
}

echo "\n${flow_info_prefix} Running step \"create_ref_libs\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Technology file:            $mw_techfile"
echo "Bus naming style:           $busstyle"
echo "Extended layer mode:        $extended_layer"
echo ""

# 3) Remove ref_lib directory so that we start anew
exec rm -rf $ref_lib$library_name

# 4) Create ref_lib directory
exec mkdir -p $ref_lib

if { [file exists $ref_lib] == 0 } {
   echo "${flow_err_prefix} Reference library directory $ref_lib could not be created."
   exit
}

# 5) Create the library
if {$extended_layer} {
   extend_mw_layers
}

create_mw_lib -case_sensitive \
              -technology $mw_techfile \
              -bus_naming_style $busstyle \
              $ref_lib$library_name

# 6) Check if the library was created successfully, create .avntrc with default library name
if { [file exists $ref_lib$library_name] == 0 } {
   echo "${flow_err_prefix} Reference library $ref_lib$library_name could not be created."
   exit
} else {
   set _tmp_file [open .avntrc w]
   puts $_tmp_file "\(setFieldDefault \"Open Library\" \"Library Name\" \"$ref_lib$library_name\"\)"
   close $_tmp_file
}

exec touch touchfiles/${library_name}.create_ref_libs
exit


