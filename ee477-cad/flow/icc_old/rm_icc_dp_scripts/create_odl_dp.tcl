##########################################################################################
# Version: G-2012.06-SP4 (Jan 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
##########################################################################################
##########################################################################################
## create_odl_dp.tcl : create on demand netlist
##########################################################################################


source -echo ./rm_setup/icc_setup.tcl 


open_mw_lib $MW_DESIGN_LIBRARY
copy_mw_cel -from $ICC_DP_CREATE_PLANGROUPS_CEL -to $ICC_DP_CREATE_ODL_CEL
open_mw_cel $ICC_DP_CREATE_ODL_CEL
link


set create_on_demand_netlist_cmd "create_on_demand_netlist -plan_groups {$ICC_DP_PLAN_GROUPS} -on_demand_cell Design_ODN"
lappend create_on_demand_netlist_cmd -full_sdc_file [which $ICC_IN_SDC_FILE]
if {($ICC_DP_ODL_HOST_OPTION_POOL_OPTION == "lsf" || $ICC_DP_ODL_HOST_OPTION_POOL_OPTION == "grd") && $ICC_DP_ODL_HOST_OPTION_SUBMIT_OPTIONS != ""} {
set_host_options -name my_odl_host_options -pool $ICC_DP_ODL_HOST_OPTION_POOL_OPTION -submit_options $ICC_DP_ODL_HOST_OPTION_SUBMIT_OPTIONS
lappend create_on_demand_netlist_cmd -host_options my_odl_host_options
}
echo $create_on_demand_netlist_cmd
eval $create_on_demand_netlist_cmd

## Note: 
#  For larger designs, consider using a two step approach to further reduce run time.
#  Please refer to the example in rm_icc_dp_scripts/odl_two_step_approach_example 

open_mw_cel Design_ODN
report_on_demand_netlist

save_mw_cel -as $ICC_DP_CREATE_ODL_CEL


exit

