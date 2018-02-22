##########################################################################
# Physical Library Preparation  Reference Methodology <check_lib> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# check_lib.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

echo "\n${flow_info_prefix} Running step \"check_lib\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo ""

# 2) Set library check options for std cell checking:
set_check_library_physical_options \
  -routeability \
  -view_cmp \
  -antenna \
  -phys_property place

# 3) Run the check
open_mw_lib $ref_lib$library_name

check_library

close_mw_lib $ref_lib$library_name

dbDumpGPortTable $ref_lib$library_name dump/Gports_final.out

# 4) Remove lock file
if [file exists $ref_lib$library_name/.lock] {
    exec rm -rf $ref_lib$library_name/.lock
}

exec touch touchfiles/${library_name}.check_lib

exit
