###################################################################################
# IC Compiler Reference Methodology 
# Version: G-2012.06-SP4 (January 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
###################################################################################

Features
========

*  Provides self-documenting reference methodology scripts for place and route 
   using IC Compiler

*  Provides the baseline flow from netlist to GDS out

*  Includes the IC Compiler Design Planning Reference Methodology, which allows 
   you to explore different floorplans

*  Includes parallel flows for multivoltage and multicorner-multimode

*  Includes the IC Compiler Hierarchical Reference Methodology, which is available 
   in version A-2007.12-SP1 and later

*  Includes signoff_opt for optimization using the Synopsys sign-off extraction 
   and timing analysis tool

*  Includes design-for-test (DFT) and power optimization

*  Designed to work with the Design Compiler Reference Methodology as the 
   first step

*  Includes a Formality reference methodology script to perform verification of the 
   netlist going into IC Compiler versus the Verilog netlist created by IC Compiler


Description
===========

The IC Compiler Reference Methodology provides a set of reference scripts that you 
can use as a recommended guideline for developing IC Compiler scripts. 

You can run the scripts "out of the box" to get a fully optimized and routed 
design right away. In addition to the baseline flow, which includes the 
IC Compiler Design Planning Reference Methodology and sign-off-driven optimization, 
the scripts also provide the following parallel flows: 

*  Feasibility flow
*  Two-pass place_opt flow
*  Multivoltage flow for the IEEE 1801 based flow
   IEEE 1801 is also known as Unified Power Format (UPF).
*  Multicorner-multimode flow
*  Physical guidance flow
*  Flip-chip flow
*  Zroute flow
*  Design-for-test (DFT) scan chain reordering flow
*  Power optimization flow
*  Chip-finishing flow steps 
*  Signoff metal fill and signoff design rule checking (DRC) flows
*  Engineering change order (ECO) flow
*  Formality flow

The IC Compiler Reference Methodology can also include an MVRC Static Verification 
Reference Methodology script for static verification of multivoltage designs. This 
script is included only when you select TRUE for the Multivoltage or Multisupply 
option in RMgen.


Contents
========

The IC Compiler Reference Methodology includes the following files:

RMgen Option Settings
---------------------

*  ICC-RMsettings.txt        

   Reference methodology option settings that were selected when the scripts 
   were generated

README and Release Note Files
-----------------------------

*  README.ICC-RM.txt

   Information and instructions for setting up and running the IC Compiler 
   Reference Methodology scripts

*  Release_Notes.ICC-RM.txt

   Release notes for the IC Compiler Reference Methodology scripts listing the 
   incremental changes in each new version of the scripts

Setup Scripts
-------------

The setup scripts are in the rm_setup directory.

*  common_setup.tcl

   Common design setup variables for the reference methodologies. 

*  icc_setup.tcl

   IC Compiler-specific design setup variables used by all IC Compiler reference 
   methodologies 

Constraint and Optimization Scripts
-----------------------------------

*  rm_icc_scripts/init_design_icc.tcl 

   Script that reads the logic design netlist and constraints, creates the 
   floorplan or reads the floorplan via Design Exchange Format (DEF), and 
   generates a zero-interconnect timing report

*  rm_icc_scripts/place_opt_icc.tcl

   Script that runs placement and placement-based optimization 

*  rm_icc_scripts/clock_opt_cts_icc.tcl 

   Script that runs clock tree synthesis and optimization

*  rm_icc_zrt_scripts/clock_opt_psyn_icc.tcl

   Script that runs post-clock tree synthesis optimization

*  rm_icc_zrt_scripts/clock_opt_route_icc.tcl

   Script that routes the clocks with the specified nondefault routing rules

*  rm_icc_zrt_scripts/route_icc.tcl

   Script that runs routing with crosstalk delta delay enabled by default 

*  rm_icc_zrt_scripts/route_opt_icc.tcl

   Script that runs postroute optimization with crosstalk delta delay enabled by default

*  rm_icc_zrt_scripts/chipfinish_icc.tcl: 

   Script that runs several chip finishing steps, such as timing-driven metal fill, 
   detail route wire spreading to reduce the critical area, and antenna fixing 

*  rm_icc_zrt_scripts/outputs_icc.tcl

   Script that creates several output files: Verilog, Design Exchange Format (DEF), 
   Standard Parasitic Exchange Format (SPEF), GDS, and others

*  rm_icc_zrt_scripts/eco_icc.tcl

   Script that runs eco flow

*  rm_icc_zrt_scripts/focal_opt_icc.tcl

   Script that runs postroute optimization to fix setup, hold, or logical
   design rule checking (DRC) violations on the design by using focal_opt

*  rm_icc_scripts/fm.tcl

   Script that runs Formality after the outputs_icc step is completed. 
   Simply enter the following command:
   % fm_shell -f rm_icc_scripts/fm.tcl | tee logs_zrt/fm.log (or log/fm.log)	

Note: 
   If you select FALSE for the Zroute option in RMgen,  
   all the scripts mentioned above are in rm_icc_scripts directory.

The flat and hierarchical floorplanning scripts are in the rm_icc_dp_scripts 
directory. 

MVRC Static Verification Reference Methodology Files
----------------------------------------------------

*  README.MVRC-RM.txt

   Information and instructions for setting up and running the MVRC Static 
   Verification Reference Methodology scripts

*  Release_Notes.MVRC-RM.txt

   Release notes for the MVRC Static Verification Reference Methodology scripts 
   listing the incremental changes in each new version of the scripts

*  rm_icc_scripts/mvrc.tcl

   MVRC Static Verification Reference Methodology script used to perform static 
   verification of multivoltage designs for top-down place and route or for 
   block-level place and route in a hierarchical flow


Usage
=====

For the standard reference methodology flow, use the following commands. 

*  To run the reference methodology scripts, enter the following command:

   % make -f rm_setup/Makefile_zrt ic

*  To run the ECO flow, enter the following command:

   % make -f rm_setup/Makefile_zrt eco

*  To run the focal_opt flow, enter the following command:

   % make -f rm_setup/Makefile_zrt focal_opt

Note: 
   This usage is based on Zroute. If you select FALSE for the Zroute option in RMgen,  
   replace Makefile_zrt with Makefile in the invocation commands. 

For the Lynx-compatible reference methodology flow, run the tool from the 
working directory, rm_icc/tmp. Make sure that the working directory exists 
before you run the tool.

  *  To run the reference methodology scripts, enter the following command:
  
     % mkdir -p rm_icc/tmp
     % cd rm_icc/tmp
     % make -f ../../scripts_block/rm_setup/Makefile_zrt ic
  
  *  To run the ECO flow, enter the following command:
  
     % mkdir -p rm_icc/tmp
     % cd rm_icc/tmp
     % make -f ../../scripts_block/rm_setup/Makefile_zrt eco
  
  *  To run the focal_opt flow, enter the following command:
  
     % mkdir -p rm_icc/tmp
     % cd rm_icc/tmp
     % make -f ../../scripts_block/rm_setup/Makefile_zrt focal_opt

Note: 
   This usage is based on Zroute. If you select FALSE for the Zroute option in RMgen,  
   replace Makefile_zrt with Makefile in the invocation commands.

