##########################################################################
# Physical Library Preparation  Reference Methodology <diode_ports> for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2014.09 Version 1.0 Sep 2, 2014

# diode_ports.tcl

# 1) load flow setup:
source [getenv FLOW_CONFIG]

echo "\n${flow_info_prefix} Running step \"diode_ports\" with the following settings:\n"
echo "Parameter                   Value"
echo "-----------------------     -------------------"
echo "Configuration file:         [getenv FLOW_CONFIG]"
echo "Library:                    $ref_lib$library_name"
echo "Diode cells in library:     $diode_cells"
echo "Name of diode pins:         $diode_pin"
echo ""

# 2) Sanity checks:
if {$diode_cells == ""} {
   echo "${flow_info_prefix} No diode cells to process."
}

if {$diode_cells != "" && $diode_pin == ""} {
   echo "${flow_err_prefix} No diode pin name defined (\$diode_pin)"
   exit
}

# 3) Convert the diode ports:
open_mw_lib $ref_lib$library_name

foreach _current_cell $diode_cells {
   open_mw_cel $_current_cell.FRAM
   set_attribute [current_mw_cel] mask_layout_type antenna
   close_mw_cel
}

foreach _current_cell $diode_cells {
   dbConvertPortToDiodePort [dbGetCurrentLibId] $_current_cell $diode_pin
}

close_mw_lib $ref_lib$library_name

exec touch touchfiles/diode_ports

exit
