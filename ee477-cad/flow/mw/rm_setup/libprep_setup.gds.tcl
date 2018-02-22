puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Variables for Libprep-RM
# Script: libprep_setup.tcl
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################################

# Setup file for library preparation based on GDS
# and an existing Milkyway Technology file.
#
# 2013.03 Version 1.0 Mar 29, 2013

##############################################################################

# Is extended layer mode for schema v7?
# --------------------------------------
# Milkyway database and tech file support up to 4095 layer
# Routing layer is limited to 1-187
# MW reserved layer section is 4001-4095
# ----------------------------------
set extended_layer 0 ; # 1=yes 0=no

# Name of the library to be created:
# ----------------------------------
set library_name ""

# Name of the top macro cell:
# Suggest to specify the top cell name for hierarchical hard macro
# Only support one string for the input
# ----------------------------------
set top_macro_name "" ; # The cell list is NOT supported

# The name of the Milkyway technology file:
# -----------------------------------------
set mw_techfile ""

# Are there timing in Liberty compressed (.db) format?
# ----------------------------------------------------
set db_models 1 ; # 1=yes 0=no

# Update bias_pg and diode type from .db to FRAM view
# ----------------------------------------------------
set update_bias_pg 1 ; # 1=yes 0=no
set update_dio_type 1 ; # 1=yes 0=no

# .db files to annotate pin direction to FRAM
# -------------------------------
# Enter one of the following in each of these variables:
# - a single filename
# - a list of filenames, separated by spaces
# - a directory name = all .db files in this directory will be used
# - nothing
set min_db_models ""    ; # Best, fastest, or min .db file(s)
set nom_db_models ""     ; # Typical, normal, or nom .db file(s)
set max_db_models ""     ; # Worst, slowest, or max .db file(s)"
set other_db_models ""    ; # List of other .db files(s)

# Keep or delete the LM view directory
# ------------------------------------
# Should the LM view directory be deleted at the end of the flow?
# LM views are not used by IC Compiler, but are needed for Astro.
set delete_LM_views 1 ; # 0 = keep them, 1 = delete them

# Using LEF advanced mode or not?
# --------------------------------------
# LEF auto-mode is designed to accommodate the most common (and default) libprep
# options, but not intended to support all libprep options.
# Suggest to set the variable to 1 for 45nm process and below, which will turn on
# advanced-mode.
# --------------------------------------
# Advanced-mode(manually) by default
# Always set run_step 1 for GDS_IN flow
set run_step 1

# Read final GDS or skip?
# ------------------------------------- 
# The golden GDS information must reside in the CEL view of each referenced cell. 
# In both the LEF and GDS based dataprep flows, you may need this final step to 
# create the clean streamout CEL view
# --------------------------------------
# On by default for LEF_IN flow
set run_final_gds 0

# Specify an GDS file containing the library cells:
# -------------------------------------------------
set gds_file ""

# Bus naming style:
# -----------------
# Enclose the entry in curly brackets.
# Example: set busstyle {[%d]}
set busstyle {[%d]}

# Layer to be used to define the cell boundaries:
# -----------------------------------------------
# Leave empty if no layer is to be used.
set gds_boundary_layer ""

# Cell type definition file for stream in:
# ----------------------------------------
# You can also use the variable "gds_all_cell_type" to set one
# type for all cells in the library.
set gds_cell_type_file ""

# Cell type definition globally for the entire library:
# -----------------------------------------------------
# This setting will override any cell type mapping file content.
#
# Allowed values (the same as in the map file, if used):
#   gdsMacroCell      marks all cells as macro cells
#   gdsStandardCell   marks all cells as standard cells
#   gdsCornerCell     marks all cells as corner cells
#   gdsPadCell        marks all cells as pad cells
#   gdsStdFillerCell  marks all cells as standard filler cells
#   gdsPadFillerCell  marks all cells as pad filler cells
#   gdsFCDriverCell   marks all cells as flip-chip drivers
#   gdsFCPadCell      marks all cells as flip-chip pads (bumps)
# Leave empty if no global cell type is to be used.
set gds_all_cell_type ""

# Layer mapping file for stream in:
# ---------------------------------
# Leave empty if none is to be used
set gds_layer_file ""

# Smashing level:
# ---------------
# Define how many GDS levels down the tool should smash
# (flatten) the cells. Default: 20
set smash_level "20"

# Character to be used for truncating pin names:
# ----------------------------------------------
# If the pins have a naming like "A:I", "VDD:P", etc, enter
# a ":" in the variable. Leave empty if no truncating is to be done.
# Curly braces are needed since some characters have special meanings in tcl.
set pin_name_truncate_string {}

# Characters to be replaced in the smashed CEL views:
# ---------------------------------------------------
# If you need to change the bus naming style, enter two up to two
# replacement pairs. Leave empty if no replacement is to be done.
# Example: to replace all occurances of "<" by "[", enter:
#   set replace_char_from_1 {<}
#   set replace_char_to_1 {[}
# Curly braces are needed since some characters have special meanings in tcl.
set replace_char_from_1 {}
set replace_char_to_1 {}
set replace_char_from_2 {}
set replace_char_to_2 {}

# Power cell pin definitions:
# ---------------------------
# List all pin names that are to be marked as type "Power"
# Example: "VDD VDDA VDDB"
set power_pin_list "VDD"
set bias_power_pin_list ""

# Ground cell pin definitions:
# ----------------------------
# List all pin names that are to be marked as type "Ground"
# Example: "VSS VSSA VSSB"
set ground_pin_list "VSS"
set bias_ground_pin_list ""

# First horizontal layer definition for prBoundary:
# ------------------------------------------------
# Set metal1_pg_rail 0, metal2_pg_rail 1: unit tile width is based on metal1 pitch
# Set metal1_pg_rail 1, metal2_pg_rail 0: unit tile width is based on metal2 pitch (default)
# Set metal1_pg_rail 1, metal2_pg_rail 1: unit tile width is based on metal3 pitch
set metal1_pg_rail 1 ; # 1=yes 0=no
set metal2_pg_rail 0 ; # 1=yes 0=no

# BPV variable: Extract different metal layer P/G rails for stdcell
# ----------------------------------------------------------------
# define BPV_PGPowerRailPatternByMaskNum #
# define BPV_PGGroundRailPatternByMaskNum #
# where # belongs to metal {1,2, ..., 15}
# Default: 1 (metal 1)
set bpv_power_rail_metal "1"
set bpv_ground_rail_metal "1"

# BPV variable: Force to skip LEF DESIGNRULEWIDTH and SPACING syntax
# ----------------------------------------------------------------
set bpv_skip_lef_syntax 0 ; # 1=skip 0=keep

# Set user specified BPV variables in a file:
# -------------------------------------------------
set bpv_flag_file ""

# For standard cells: which layers should pins be created on, when
# pin data exists on more than one layer:
# ----------------------------------------------------------------
# Enter the metal layer number - 1 for metal1, 2 for metal2, or
# 3 for metal3.
# Valid values: 1, 2 or 3.
set std_cell_pin_layer 3

# Layers containing pin texts:
# ----------------------------
# For the layers poly-metal12, enter the layer:datatype or layer
# numbers. Leave empty if no mapping is to be used, i.e. when the
# pin texts are on the same layers as the metal polygons.
#
# Only poly through metal4 are used for standard cells.
#
# Example: set m1_pin_text_layer "26:12"
# Example: set m2_pin_text_layer "72"
set poly_pin_text_layer ""
set m1_pin_text_layer ""
set m2_pin_text_layer ""
set m3_pin_text_layer ""
set m4_pin_text_layer ""
set m5_pin_text_layer ""
set m6_pin_text_layer ""
set m7_pin_text_layer ""
set m8_pin_text_layer ""
set m9_pin_text_layer ""
set m10_pin_text_layer ""
set m11_pin_text_layer ""
set m12_pin_text_layer ""

# Layers containing must-connect polygons:
# ----------------------------------------
# For the layers poly-metal12, enter the layer:datatype or layer numbers.
# Leave empty if no must-connect areas are desired.
#
# Only poly through metal4 are used for standard cells.
#
# Example: set m1_must_connect_layer "26:12"
# Example: set m2_must_connect_layer "72"
set poly_must_connect_layer ""
set m1_must_connect_layer ""
set m2_must_connect_layer ""
set m3_must_connect_layer ""
set m4_must_connect_layer ""
set m5_must_connect_layer ""
set m6_must_connect_layer ""
set m7_must_connect_layer ""
set m8_must_connect_layer ""
set m9_must_connect_layer ""
set m10_must_connect_layer ""
set m11_must_connect_layer ""
set m12_must_connect_layer ""

# List of contact codes to be used for std cell pins:
# ---------------------------------------------------
# Enter the list with commas as separator. Only these contacts
# will be used for std cell pin via regions. Leave empty to use
# the default contacts only. Don't put any spaces in the list.
#
# Example: set std_cell_contacts "11,31,61"
set std_cell_contacts ""

# Define if rotated vias are allowed or not for std cell pins:
# ------------------------------------------------------------
# Values: 0 or 1
# Default: 0 (rotated vias are allowed)
set std_cell_skip_rotated_vias 0

# How to treat each layer for macros, pads, etc:
# ----------------------------------------------
# For each layer, enter one of the following:
#    all or empty: block all layer (default)
#    merge       : merge blockages, automatic calculation of core margin
#    none        : No blockage generation
set block_macro_layer_poly ""
set block_macro_layer_m(1) ""
set block_macro_layer_m(2) ""
set block_macro_layer_m(3) ""
set block_macro_layer_m(4) ""
set block_macro_layer_m(5) ""
set block_macro_layer_m(6) ""
set block_macro_layer_m(7) ""
set block_macro_layer_m(8) ""
set block_macro_layer_m(9) ""
set block_macro_layer_m(10) ""
set block_macro_layer_m(11) ""
set block_macro_layer_m(12) ""

# Threshold for merging polygons in macro FRAM views:
# ---------------------------------------------------
# For some macros, it may be better to merge the blockages
# using a threshold. Leave it at "0" if no merging should
# be done. Note that there is only one global value; you
# have to edit the bpv.tcl script to use different
# thresholds per layer.
set merge_threshold "0"

# Distance from boundary to complete blockage in macro FRAM views:
# ----------------------------------------------------------------
# For some macros, you can let the tool block the entire
# layer. If the pins are not on the boundary, you have to
# enter the distance to the outer pin edge here. Note that
# there is only one global value; you have to edit the
# bpv.tcl script to use different values per layer.
set edge_distance "0"

# Height of unit tile (or sometimes called site):
# -----------------------------------------------
# Enter a numeric value. If you leave this empty,
# Milkyway will try to create the PR boundary and
# unitTile automatically, which sometimes does not
# produce the correct result.
set unit_tile_height ""

# This is needed for the ICV antenna property extraction.
# Enter one single layer, or several layers separated by commas.
# Example: set diffusion_layer "16,18"
set diffusion_layer ""
set poly_layer ""
set cont_layer ""
set v0_layer ""
set m0_poly_layer ""
set m0_diff_layer ""
set cont_m0_diff_layer ""

# Using additional gate thickness class or not?
# --------------------------------------
set gate_class 0   ; # 1=yes 0=no 
set thick_mask1_layer ""
set thick_mask2_layer ""
set thick_mask3_layer ""

# Antenna CLF file to load:
# -------------------------
# Instead of using Hercules to extract antenna properties,
# you can enter a CLF file name here. If a filename is
# entered, the Hercules extraction will be skipped.
set antenna_clf_file ""

# List of diode cells in the library:
# -----------------------------------
# Enter list with spaces as delimiters.
# Leave empty if there are no diode cells.
# Example: set diode_cells "diode1 diode2 diode4 diode8"
set diode_cells ""

# Diode pin name:
# ---------------
# Enter the name of the diode pins.
set diode_pin ""

# I/O cell rotation:
# ------------------
# If you want to apply a rotation to all the I/O cells in
# the library, specify it here. Leave empty if no rotation
# is wanted.
# Valid values: 0, 90, 180, 270 (or empty)
set pad_rotation ""

# Standard cell pin access check setup:
# -------------------------------------
# The "Pin Access Checking Utility" analyze a physical library 
# and find potential pin accessibility issues in analyzed_lib
# stage. The detault is OFF.
# The estimated runtime with routing to analyze all stdcells in a library:
# - around 24 hours for 1000 cell counts in 4 threads run
# - around 5 hours for 250 cell counts in 4 threads run
set run_pin_access 0 ;# 1=run 0=skip(default)

# Run or skip routing for all pin access checking cells
set run_routing 1 ; # 1=run(default) 0=skip

# Check selected cell(s) against all cells in the input standard cell library or libraries
# Example: set check_cell_list {cell1 cell2 cell3}
set check_cell_list {}

# Select ICC platform for utility: amd64, linux, suse32, suse64
set icc_platform "amd64"

# FRAM property extraction setup:
# -------------------------------------
# Extracts  application-specific  cell  information  needed by the
# placer or router, and attaches  that  information  to  the  FRAM views.
# Command: extract_fram_property
set extract_fram_property 0 ; # 1=run(default) 0=skip
set implant_width 1 ; # 1=true 0=false
set diffusion_width_height 1 ; # 1=true 0=false
set source_drain_annotation "" ; # file name for source drain annotation information 
set tile_name "" ; #  The default name is "unitTile".

# Wire tracks checking setup:
# -------------------------------------
set detailed_wire_track_report 0 ; # 1=true 0=false

##############################################################################
#                                                                            #
#    Flow control data - normally you should not have to change these.       #
#                                                                            #
##############################################################################

# The directory where the Milkyway library will go:
# -------------------------------------------------
set ref_lib "./ref_lib/"

# turn OFF the printing of window reconfiguration messages:
# ---------------------------------------------------------
#setConfigurationPrinting 0

# Files created in the flow:
# --------------------------
set flow_celltype_file "./dump/celltypes.txt"
set flow_stdcell_file "./dump/stdcells.txt"
set flow_nonstdcell_file "./dump/nonstdcells.txt"
set flow_iocell_file "./dump/iocells.txt"
set flow_unspecifiedcell_file "./dump/unspecified.txt"
set flow_porttype_file "./dump/porttypes.txt"
set flow_dump_clf_file "./dump/antenna_dump.clf"
set flow_padrotate_clf_file "./dump/rotate_pad.clf"

# Message prefixes:
# -----------------
set flow_info_prefix "GDS CELL PREP FLOW INFO >>"
set flow_warn_prefix "GDS CELL PREP FLOW WARNING >>"
set flow_err_prefix  "GDS CELL PREP FLOW ERROR >>"

