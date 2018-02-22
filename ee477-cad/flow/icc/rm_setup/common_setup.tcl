puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Variables common to all reference methodology scripts
# Script: common_setup.tcl
# Version: G-2012.06-SP4 (Jan 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
##########################################################################################

# The reference methodology root directory, where directories like
# "rm_setup, rm_icc_dp_scripts, rm_icc_scripts, and rm_icc_zrt_scripts" exist.
set RM_ROOT_PATH                  "[pwd]"

# The name of the top-level design
set DESIGN_NAME                   ""

# Absolute path prefix variable for library/design data.
# Use this variable to prefix the common absolute path to the common variables
# defined below. Absolute paths are mandatory for hierarchical methodology flow.
set DESIGN_REF_DATA_PATH          ""

##########################################################################################
# Hierarchical Flow Design Variables
##########################################################################################

# List of hierarchical block design names "DesignA DesignB" ...
set HIERARCHICAL_DESIGNS          ""

# List of hierarchical block cell instance names "u_DesignA u_DesignB" ...
set HIERARCHICAL_CELLS            ""

##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

# This should contain the directories where all the TARGET_LIBRARY_FILES (*.db)
# files are located.
set ADDITIONAL_SEARCH_PATH        ""

# Target technology logical libraries
set TARGET_LIBRARY_FILES          ""

# Extra link logical libraries not included in TARGET_LIBRARY_FILES
set ADDITIONAL_LINK_LIB_FILES     ""

# List of max min library pairs "max1 min1 max2 min2 max3 min3"...
set MIN_LIBRARY_FILES             ""

# Milkyway reference libraries (include IC Compiler ILMs here)
set MW_REFERENCE_LIB_DIRS         ""

# Reference Control file to define the Milkyway reference libs
set MW_REFERENCE_CONTROL_FILE     ""

# Milkyway technology file
set TECH_FILE                     ""

# Mapping file for TLUplus
set MAP_FILE                      ""

# Max TLUplus file
set TLUPLUS_MAX_FILE              ""

# Min TLUplus file
set TLUPLUS_MIN_FILE              ""

set MW_POWER_NET                  "VDD"
set MW_POWER_PORT                 "VDD"
set MW_GROUND_NET                 "VSS"
set MW_GROUND_PORT                "VSS"

# Min routing layer
set MIN_ROUTING_LAYER             ""

# Max routing layer
set MAX_ROUTING_LAYER             ""

# Tcl file with library modifications for dont_use
set LIBRARY_DONT_USE_FILE         ""

###########################################################################################
# Multivoltage Common Variables
#
# Define the following multivoltage common variables for the reference methodology scripts
# for multivoltage flows.
# Use as few or as many of the following definitions as needed by your design.
###########################################################################################

# Name of power domain/voltage area  1
set PD1                           ""

# Coordinates for voltage area 1
set VA1_COORDINATES               {}

# Power net for voltage area 1
set MW_POWER_NET1                 "VDD1"

# Name of power domain/voltage area  2
set PD2                           ""

# Coordinates for voltage area 2
set VA2_COORDINATES               {}

# Power net for voltage area 2
set MW_POWER_NET2                 "VDD2"

# Name of power domain/voltage area  3
set PD3                           ""

# Coordinates for voltage area 3
set VA3_COORDINATES               {}

# Power net for voltage area 3
set MW_POWER_NET3                 "VDD3"

# Name of power domain/voltage area  4
set PD4                           ""

# Coordinates for voltage area 4
set VA4_COORDINATES               {}

# Power net for voltage area 4
set MW_POWER_NET4                 "VDD4"

puts "RM-Info: Completed script [info script]\n"
