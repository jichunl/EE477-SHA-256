# include.tcl
#
# This file defines a list of additional directories to search
# for `include files required to simulate the design with this
# testbench.
#


# bsg repo dirs
#
# These envvars define the path to all the cad repos used in the
# flow. These envvars should be set in the  chip repo
# Makefile.design.include file.
#
set bsg_ip_cores_dir         $::env(BSG_OUT_DIR)/bsg_ip_cores
set bsg_designs_dir          $::env(BSG_OUT_DIR)/ee477-designs
set bsg_designs_target_dir   $::env(BSG_OUT_DIR)/ee477-designs/toplevels/$::env(BSG_DESIGNS_TARGET)
set bsg_packaging_dir        $::env(BSG_OUT_DIR)/ee477-packaging
set bsg_manycore_dir        $::env(BSG_OUT_DIR)/bsg_manycore
set bsg_boards_dir        $::env(BSG_OUT_DIR)/boards


# bsg packaging vars
#
# These envvars define while files should be found ensure the correct
# packaging and pinouts are used. These envvars should be set in the
# chip repo Makefile.design.include file.
#
set bsg_packaging_foundry    $::env(BSG_PACKAGING_FOUNDRY)
set bsg_pinout               $::env(BSG_PINOUT)
set bsg_pinout_foundry       $::env(BSG_PINOUT_FOUNDRY)
set bsg_pinout_iopad_mapping $::env(BSG_PINOUT_IOPAD_MAPPING)


# bsg_sverilog_include_paths
#
# DO NOT change the name of this variable. This special variable
# is a list of all additional include directories needed to simulate
# this design.
#
set bsg_testing_include_paths [join "
    $bsg_manycore_dir/v
    $bsg_manycore_dir/v/vanilla_bean
    $bsg_ip_cores_dir/bsg_noc
    $bsg_ip_cores_dir/bsg_misc
  $bsg_packaging_dir/common/portable/v
  $bsg_packaging_dir/pinouts/$bsg_pinout/common/v
  $bsg_packaging_dir/pinouts/$bsg_pinout/$bsg_pinout_foundry/v
  $bsg_packaging_dir/pinouts/$bsg_pinout/$bsg_pinout_foundry/v/iopad_mappings/$bsg_pinout_iopad_mapping
"]

