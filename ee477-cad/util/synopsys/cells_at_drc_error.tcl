# 2014 Synopsys, Inc. All rights reserved.
#
# This script is proprietary and confidential information of Synopsys, Inc. and
# may be used and disclosed only as authorized per your agreement with Synopsys,
# Inc. controlling such use and disclosure.

# Solvnet:
#   Original name of this script: CellsAtDRCError.tcl
#   Related article: https://solvnet.synopsys.com/retrieve/1541297.html

# This script lists the cells that intersect each DRC error in the design.

# When you source the CellsAtDRCError.tcl script, it generates a report similar to the following report:

#   Cells at error 523352 are I_RISC_CORE/I_DATA_PATH/U63
#   Cells at error 523353 are I_RISC_CORE/I_DATA_PATH/U62
#   Cells at error 523354 are I_RISC_CORE/I_DATA_PATH/U61
#   Cells at error 523355 are I_BLENDER_1/mult_50_L43980_C203_I2/U795 I_SDRAM_TOP/I_SDRAM_WRITE_FIFO/data_out_sync_reg_1_ I_BLENDER_1/result_reg_4_
#   ...
#   Cells at error 523376 are I_BLENDER_1/mult_50_L43980_C203_I2/U739

foreach_in_collection errors [get_drc_errors] {
  set error [get_object_name $errors]
  set cells [get_cells -intersect [get_attribute -class drc_error [get_drc_errors -error_id $error] bbox]]
  set full_name [get_attribute $cells full_name]
  echo "Cells at error $error are $full_name"
}
