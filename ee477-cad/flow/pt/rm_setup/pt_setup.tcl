puts "RM-Info: Running script [info script]\n"

##########################################################################################
# PrimeTime Variables PrimeTime Reference Methodology script
# Script: pt_setup.tcl
# Version: G-2012.06 (July 2, 2012)
# Copyright (C) 2008-2012 Synopsys All rights reserved.
##########################################################################################

source ./rm_setup/common_setup.tcl

######################################
# Report and Results Directories
######################################

# make PT_REPORTS_DIR
if { ! [file exists $PT_REPORTS_DIR] } { file mkdir ${PT_REPORTS_DIR} }
# make PT_RESULTS_DIR
if { ! [file exists $PT_RESULTS_DIR] } { file mkdir ${PT_RESULTS_DIR} }

######################################
# Library and Design Setup
######################################

### Mode : Generic

set search_path    ". $ADDITIONAL_SEARCH_PATH $search_path"
set target_library $TARGET_LIBRARY_FILES
set link_path      "* $target_library $ADDITIONAL_LINK_LIB_FILES"

# Provide list of Verilog netlist files. It can be compressed --- example "A.v B.v C.v"
set NETLIST_FILES  ""

######################################
# Back Annotation File Section
######################################
# PARASITIC Files --- example "top.sbpf A.sbpf"
# The path (instance name) and name of the parasitic file --- example "top.spef A.spef"
# Each PARASITIC_PATH entry corresponds to the related PARASITIC_FILE for the specific block"
# For a single toplevel PARASITIC file please use the toplevel design name in PARASITIC_PATHS variable."
set PARASITIC_PATHS  ""
set PARASITIC_FILES  ""

######################################
# Constraint Section Setup
######################################
set CONSTRAINT_FILES ""

######################################
# End
######################################

### End of PrimeTime Runtime Variables ###
puts "RM-Info: Completed script [info script]\n"
