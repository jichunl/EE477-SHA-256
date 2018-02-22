##########################################################################
# Physical Library Preparation  Reference Methodology <setup file> for LEF_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################
#
# 2013.03 Version 1.0 Mar 18, 2013

# Library Preparation Script Environment
# GDS + Milkyway Tech File

# Variables:
# ----------
# FLOW_CONFIG points to the configuration file to be used by the flow. By  
# default, this is ./config/setup.tcl; but you may change to another config 
# file by either modifyingthe file name here, or by starting the flow target(s) 
# like this:
#
# % make complete FLOW_CONFIG=./config/my_config_file.tcl
#FLOW_CONFIG=./rm_setup/libprep_setup.tcl

# Make the config file location known to the unix shell (don't remove this):
export FLOW_CONFIG

# ACODE contains the Milkyway launch command. You may add a path, but be sure 
# to not remove the -tcl switch.
# If a different path is needed to access Hercules (for example, an Astro 
# installation), change the HCODE variable accordingly.#
ACODE=Milkyway -tcl
HCODE=Milkyway -tcl
ICODE=icc_shell -64

# The variable OPTIONS is used for each launch of Milkyway, and determines the 
# graphics mode for the Milkyway runs.
OPTIONS=-nullDisplay
OPTIONS+=-nogui
#OPTIONS=-iconic

# VPATH tells the gmake utility to create and look for the target 
# touchfiles in a certain directory. You should not modify this variable.
VPATH=touchfiles

LIBPREP_LOGS_DIR=logs/libprep

# Here are the flow targets. If you make any changes, be careful to maintain a 
# valid dependency chain.

create_ref_libs:
	$(ACODE) -file rm_libprep_lef_in_scripts/create_ref_libs.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

read_lef: create_ref_libs
	$(ACODE) -file rm_libprep_lef_in_scripts/read_lef.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)
        
smash: read_lef
	$(ACODE) -file rm_libprep_lef_in_scripts/smash.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)
        
set_port_types: smash
	$(ACODE) -file rm_libprep_lef_in_scripts/set_port_types.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)
        
bpv: set_port_types
	$(ACODE) -file rm_libprep_lef_in_scripts/bpv.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

pr_bdry: bpv
	$(ACODE) -file rm_libprep_lef_in_scripts/pr_bdry.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

multi_height: pr_bdry
	$(ACODE) -file rm_libprep_lef_in_scripts/multi_height.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

wire_tracks: multi_height
	$(ACODE) -file rm_libprep_lef_in_scripts/wire_tracks.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)
        
check_wire_tracks: wire_tracks
	$(ACODE) -file rm_libprep_lef_in_scripts/check_wire_tracks.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)
        
diode_ports: check_wire_tracks
	$(ACODE) -file rm_libprep_lef_in_scripts/diode_ports.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

lib_db: diode_ports
	$(ACODE) -file rm_libprep_lef_in_scripts/lib_db.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

read_final_gds: lib_db
	$(ACODE) -file rm_libprep_lef_in_scripts/read_final_gds.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

extract_antenna: read_final_gds
	$(HCODE) -file rm_libprep_lef_in_scripts/extract_antenna.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)

check_lib: extract_antenna
	$(ACODE) -file rm_libprep_lef_in_scripts/check_lib.tcl -cmd $(CMD_FILE) -log $(LOG_FILE).$@ $(OPTIONS)
        
analyze_lib: check_lib
	$(ICODE) -f rm_libprep_lef_in_scripts/analyze_lib.tcl |tee log/analyze_lib.log

complete: check_lib
	touch touchfiles/complete

libprep: complete
	@# alias...
        
start_mw:
	$(ACODE) -cmdd log/Milkyway -logd log/Milkyway

