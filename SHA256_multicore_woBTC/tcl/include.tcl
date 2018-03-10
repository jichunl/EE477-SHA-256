# include.tcl
#
# This file defines a list of directories to search for `include files
# required to synthesize and simulate the design.
#


# bsg repo dirs
#
# These envvars define the path to all the cad repos used in the
# flow. These envvars should be set in the  chip repo
# Makefile.design.include file.
#
set bsg_ip_cores_dir         $::env(BSG_IP_CORES_DIR)
set bsg_designs_dir          $::env(BSG_DESIGNS_DIR)
set bsg_designs_target_dir   $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir        $::env(BSG_PACKAGING_DIR)
set bsg_manycore_dir        $::env(BSG_MANYCORE_DIR)


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
# is a list of all include directories needed for the design. Include
# directories are where the tools should look for files that are
# included via the `include command. This is particularly important
# for making sure the packaing and IO cells are correctly instantiated.
#
# Note: we use the 'portable' packaging foundry, even if that is not
#       the target packaging foundry. We do this so that the design
#       will perform RTL simulation. As part of the dc flow, this will
#       be swapped with the correct packaging foundry.
#
# FIXME: potential fix this^^^ caveat to be more intuitive (hard folder swap?)
#
set bsg_sverilog_include_paths [join "
  $bsg_ip_cores_dir/bsg_misc
  $bsg_ip_cores_dir/bsg_noc
  $bsg_manycore_dir/v
  $bsg_manycore_dir/v/vanilla_bean
  $bsg_packaging_dir/common/portable/v
  $bsg_packaging_dir/pinouts/$bsg_pinout/common/v
  $bsg_packaging_dir/pinouts/$bsg_pinout/$bsg_pinout_foundry/v
  $bsg_packaging_dir/pinouts/$bsg_pinout/$bsg_pinout_foundry/v/iopad_mappings/$bsg_pinout_iopad_mapping
"]

