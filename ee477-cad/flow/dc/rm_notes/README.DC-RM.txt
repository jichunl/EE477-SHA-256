####################################################################################
# Design Compiler Reference Methodology
# Version: G-2012.06-SP4 (January 11, 2013)
# Copyright (C) 2007-2013 Synopsys, Inc. All rights reserved.
####################################################################################

A reference methodology provides a set of reference scripts that serve as a good
starting point for running a tool. These scripts are not designed to run in their
current form. You should use them as a reference and adapt them for use in your
design environment.

The Design Compiler Reference Methodology includes options for running the
DFT Compiler and Power Compiler optimization steps. Note that additional licenses
are required when you run DFT Compiler or Power Compiler inside of Design Compiler.
The sections of the reference script that involve using DFT Compiler or
Power Compiler are marked clearly, which allows you to include or exclude these
sections when preparing your synthesis scripts.

For Design Compiler, the reference methodology provides a common set of scripts that
you can use to run Design Compiler in either wire load mode or topographical mode.
This common set of reference scripts also helps you to migrate your existing scripts
from wire load mode synthesis to topographical mode synthesis. The reference script
detects when Design Compiler is running in topographical mode (when you start the
tool by entering the dc_shell command with the -topographical_mode option) and
automatically executes additional steps related to topographical mode synthesis.

The Design Compiler Reference Methodology includes support for the following flows:

*  The top-down synthesis flow, including multivoltage synthesis with
   IEEE 1801, which is also known as Unified Power Format (UPF).

*  The hierarchical synthesis flow, including multivoltage synthesis with UPF.

The Design Compiler Reference Methodology includes Formality reference scripts
to verify your synthesis results for all flows.

The Design Compiler Reference Methodology can also include MVRC Static Verification
Reference Methodology scripts for static verification of multivoltage designs. These
scripts are included only when you select TRUE for the UPF Flow option in RMgen.

Note:
   All scripts are designed to work in both wire load mode and topographical mode.


Files Included With the Design Compiler Reference Methodology
=============================================================

------------------------------------------------------------------------------------
File                            Description
------------------------------------------------------------------------------------
DC-RMsettings.txt               Reference methodology option settings used to
                                generate the scripts.

README.DC-RM.txt                Information and instructions for setting up and
                                running the Design Compiler Reference Methodology
                                scripts.

Release_Notes.DC-RM.txt         Release notes for the Design Compiler Reference
                                Methodology scripts listing the incremental
                                changes in each new version of the scripts.

rm_setup/common_setup.tcl       Common design setup variables for the reference
                                methodologies.

rm_setup/dc_setup.tcl           Library setup for Design Compiler Reference
                                Methodology, including the Formality scripts
                                and the MVRC Static Verification Reference
                                Methodology scripts.

rm_setup/dc_setup_filenames.tcl File names setup for Design Compiler Reference
                                Methodology, including the Formality scripts
                                and the MVRC Static Verification Reference
                                Methodology scripts.

rm_dc_scripts/dc.tcl            Design Compiler Reference Methodology script for
                                top-down synthesis or block-level synthesis in a
                                hierarchical flow.

rm_dc_scripts/fm.tcl            Formality script to verify top-down synthesis
                                results or block-level synthesis results in a
                                hierarchical flow.

rm_dc_scripts/dc_top.tcl        Design Compiler Reference Methodology top-level
                                integration script for hierarchical flow
                                synthesis.

                                This file is included only if the reference
                                methodology scripts are configured for a
                                hierarchical flow.

rm_dc_scripts/fm_top.tcl        Formality top-level verification script for
                                hierarchical flow synthesis.

                                This file is included only if the reference
                                methodology scripts are configured for a
                                hierarchical flow.

rm_dc_scripts/dc.upf            Design Compiler Reference Methodology sample UPF
                                file for top-down multivoltage synthesis.

                                This file is included only if the reference
                                methodology scripts are configured for a
                                multivoltage flow.

rm_dc_scripts/
dc.mcmm.scenarios.tcl           Design Compiler Reference Methodology sample
                                setup file for scenarios in a multicorner-
                                multimode flow.

rm_dc_scripts/
dc.dft_autofix_config.tcl       Design Compiler Reference Methodology sample
                                design for test AutoFix configuration file.

rm_dc_scripts/
dc.dft_occ_config.tcl           Design Compiler Reference Methodology sample
                                design-for-test (DFT) on-chip clocking
                                configuration file.

                                This file is included only when the reference
                                methodology scripts are configured to include
                                on-chip clocking in the DFT flow.

README.MVRC-RM.txt              Information and instructions for setting up and
                                running the MVRC Static Verification Reference
                                Methodology scripts.

Release_Notes.MVRC-RM.txt       Release notes for the MVRC Static Verification
                                Reference Methodology scripts listing the incremental
                                changes in each new version of the scripts.

rm_dc_scripts/mvrc.tcl          MVRC Static Verification Reference Methodology
                                script used to perform static verification of
                                multivoltage designs for top-down synthesis or
                                for block-level synthesis in a hierarchical flow.

rm_dc_scripts/mvrc_top.tcl      MVRC Static Verification Reference Methodology
                                script used to perform static verification of
                                multivoltage designs at the full-chip level
                                in a hierarchical flow.
------------------------------------------------------------------------------------


Instructions:
Using the Design Compiler Reference Methodology for a Top-Down Flow
===================================================================

The file names in the following instructions refer to variable names that are
defined in the dc_setup_filenames.tcl file. Default file names are assigned for
all variables. You can customize your flow by changing the names to match the
names of the files used in your flow.

To run the Design Compiler Reference Methodology scripts in a top-down flow,

1.  Copy the reference methodology files to a new location.

2.  Edit common_setup.tcl to set the design name, search path, and library
    information for your design.

3.  Edit dc_setup.tcl to customize your Design Compiler setup.

    The dc_setup.tcl file is designed to work automatically with the values
    provided in common_setup.tcl.

    o  Include a list of your RTL files in the RTL_SOURCE_FILES variable.

       Use only file names and take advantage of the search_path setting to keep
       your files portable.

       Design Compiler can read and determine the dependencies between RTL files
       automatically. To use this capability, select AUTOREAD for the RTL Source
       Format option when you download the scripts from RMgen. You can specify a
       list of RTL files and RTL file directories with the RTL_SOURCE_FILES
       variable.

       Alternatively, you can use a separate script to read the RTL files in
       Design Compiler and Formality. To use this capability, select SCRIPT for
       the RTL Source Format option when you download the scripts from RMgen.
       The ${DCRM_RTL_READ_SCRIPT} and ${FMRM_RTL_READ_SCRIPT} variables in the
       dc_setup_filenames.tcl file define the names of these scripts.

    o  Set up multicore optimization, if desired, by using the set_host_options
       command.

       Ensure that you have sufficient cores and sufficient copies of all feature
       licenses to support your settings.

    o  Specify a common alib_library_analysis_path location if you want to save
       some runtime in subsequent Design Compiler sessions.

4.  Edit dc.tcl to customize the steps that you want to perform in your design
    synthesis.

    Read through this script carefully, note the comments, and choose the steps
    that you want to include in your synthesis. Remember that this is a reference
    example and it requires modification to work with your design.

    You can customize the file names for input files, output files, and reports
    by changing the file names in dc_setup_filenames.tcl.

5.  Ensure that you have all of the design-specific input files that you need to
    use in the flow.

    The tool picks up these files automatically from the search path defined in
    common_setup.tcl. The minimum set of recommended files consists of

    o  ${DCRM_CONSTRAINTS_INPUT_FILE}, which provides the logic design constraints

    o  ${DCRM_DCT_DEF_INPUT_FILE} or ${DCRM_DCT_FLOORPLAN_INPUT_FILE}, which
       provides the floorplan for topographical mode synthesis

    o  ${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE}, which provides the DFT signal
       definitions

    For a complete list of expected input files, see the list at the end
    of this README file.

6.  (Multivoltage flow only) Ensure that you have the additional input files
    that you need for this flow.

    The minimum set of recommended files consists of

    o  ${DCRM_MV_UPF_INPUT_FILE}, which is the UPF setup file

    o  ${DCRM_MV_SET_VOLTAGE_INPUT_FILE}, which provides the set_voltage commands

    o  ${DCRM_MV_DCT_VOLTAGE_AREA_INPUT_FILE}, which provides the
       create_voltage_area commands for topographical mode synthesis

    The dc.upf file shows examples of UPF input files.

    You can also use Visual UPF in Design Vision to generate a UPF template for
    your design. To open the Visual UPF dialog box, choose Power > Visual UPF.
    For information about Visual UPF, see the Power Compiler User Guide.

7.  (Multicorner-multimode flow only) Ensure that you have the additional input
    files that you need for this flow.

    The dc.mcmm.scenarios.tcl setup file shows a general example of a scenario
    setup file for a multicorner-multimode flow in Design Compiler.

    You must have the following file:

    o  ${DCRM_MCMM_SCENARIOS_SETUP_FILE}, which is the scenario setup file

    You also need scenario-specific versions of the following files:

    o  ${DCRM_CONSTRAINTS_INPUT_FILE}, which provides the logic design constraints

    o  ${DCRM_SDC_INPUT_FILE}, which provides the Synopsys Design Constraints (SDC)
       constraints

    o  ${DCRM_MV_SET_VOLTAGE_INPUT_FILE}, which provides the set_voltage commands

    Scenario-specific files should use the base file name defined in
    dc_setup_filenames.tcl and should include the scenario name
    somewhere in the file name. You can configure how the scenario name
    is added to the base file name by changing the dcrm_mcmm_filename
    Tcl procedure defined in dc_setup_filenames.tcl.

    This naming style applies to both input and output files in the
    multicorner-multimode flow.

8.  Run your synthesis by using the dc.tcl script.

    For the standard reference methodology flow, run the tool from the directory
    above the rm_setup directory.

    % dc_shell -topographical_mode -f rm_dc_scripts/dc.tcl | tee dc.log

    For the Lynx-compatible reference methodology flow, run the tool from the
    working directory, rm_dc/tmp. Make sure that both the working directory
    and the log directory, rm_dc/logs/dc, exist before you run the tool.

    % mkdir -p rm_dc/tmp rm_dc/logs/dc
    % cd rm_dc/tmp
    % dc_shell -topographical_mode \
               -f ../../scripts_block/rm_dc_scripts/dc.tcl | tee ../logs/dc/dc.log

9.  Verify the synthesis results by looking at your log file and studying the
    reports created in the ${REPORTS} directory.

    When you are satisfied that synthesis completed successfully, proceed to
    Formality verification in the next step.

10. Edit fm.tcl as needed for Formality verification.

11. (Multivoltage flow only) If you are mapping to retention registers, replace
    the technology library models of those cells with Verilog simulation models
    for Formality verification.

    See the following SolvNet article for details:

    https://solvnet.synopsys.com/retrieve/024106.html

12. Run your Formality verification by using the fm.tcl script.

    For the standard reference methodology flow, enter the following command:

    % fm_shell -f rm_dc_scripts/fm.tcl | tee fm.log

    For the Lynx-compatible reference methodology flow, enter the following
    commands:

    % cd rm_dc/tmp
    % fm_shell -f ../../scripts_block/rm_dc_scripts/fm.tcl | tee ../logs/dc/fm.log

13. (Multivoltage flow only) Perform static verification of the multivoltage design
    with MVRC by running the MVRC Static Verification Reference Methodology script
    mvrc.tcl.

    For more information, see README.MVRC-RM.txt.


Instructions:
Using the Design Compiler Reference Methodology for a Hierarchical Flow
=======================================================================

The file names in the following instructions refer to variable names that are
defined in the dc_setup_filenames.tcl file. Default file names are assigned for
all variables. You can customize your flow by changing the names to match the
names of the files used in your flow.

Note:
   The Design Compiler Reference Methodology is designed to be used together
   with the IC Compiler Hierarchical Reference Methodology, which is part of
   the IC Compiler Reference Methodology and is available as a separate download
   from SolvNet.

For general hierarchical flow overview information, consult the following
application notes, which are available on SolvNet:

*  Hierarchical Flow Support in Design Compiler Topographical Mode

   https://solvnet.synopsys.com/retrieve/021034.html

*  IEEE P1801 (UPF) based Design Compiler topographical and IC Compiler
   Hierarchical Design Methodology

   https://solvnet.synopsys.com/retrieve/026172.html

To run the Design Compiler Reference Methodology scripts for block-level synthesis
in a hierarchical flow,

1.  Edit common_setup.tcl to set the design name, search path, and library
    information for your design.

    Only the ${DESIGN_NAME} variable changes between your block-level synthesis
    runs.

    Note:
       For a hierarchical flow, the IC Compiler Hierarchical Reference
       Methodology requires the use of absolute paths
       in the common_setup.tcl file because this file is used at different
       UNIX path locations.

       Use the ${DESIGN_REF_DATA} absolute path prefix as much as possible
       for all your search_path and library specifications in order to keep
       your common_setup.tcl file portable.

    Example:
       # Absolute path prefix variable
       set DESIGN_REF_DATA "/designs/ProjectX/Rev3/design_data"

       set ADDITIONAL_SEARCH_PATH "${DESIGN_REF_DATA}/rtl \
                                    ${DESIGN_REF_DATA}/libs"

2.  Set up separate subdirectories for each hierarchical block, by using the design
    name, and ensure that the common_setup.tcl file for each block has the
    ${DESIGN_NAME} variable set to the block design name.

    The IC Compiler Hierarchical Reference Methodology does this automatically.

    Note:
       Even if you use the IC Compiler Hierarchical Reference Methodology to set
       up your block directories, you must copy the following files into each
       block subdirectory:

       rm_setup/dc_setup.tcl
       rm_setup/dc_setup_filenames.tcl
       rm_dc_scripts/*

3.  Follow the top-down flow instructions, described previously, to synthesize
    each of the hierarchical blocks by using the dc.tcl script.

4.  Ensure that you have all of the design-specific input files that you need for
    each hierarchical design.

    The tool picks up these files automatically from the search path defined in
    common_setup.tcl. The minimum set of recommended files consists of the
    following files:

    o  ${DCRM_SDC_INPUT_FILE} contains the budgeted block SDC constraints from the
       IC Compiler Hierarchical Reference Methodology

    o  ${DCRM_DCT_DEF_INPUT_FILE} contains the Design Exchange Format (DEF)
       block floorplan from the IC Compiler Hierarchical Reference Methodology

    o  ${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE} contains the DFT signal definitions
       for each block

    Ensure that you have DFT signal definition files for each block. This is
    not automated in the flow. Consult with your DFT engineer to obtain the
    correct setup for each block.

5.  (Multivoltage flow only) Ensure that you have the necessary additional files
    for each hierarchical design block.

    The minimum set of recommended files consists of

    o  ${DCRM_MV_UPF_INPUT_FILE}, which is the UPF setup file for each block

    o  ${DCRM_MV_SET_VOLTAGE_INPUT_FILE}, which provides the set_voltage commands
       for each block

    o  ${DCRM_MV_DCT_VOLTAGE_AREA_INPUT_FILE}, which provides the
       create_voltage_area commands for topographical mode synthesis

    The dc.upf file shows examples of UPF input files.

    You can also use Visual UPF in Design Vision to generate a UPF template for
    your design. To open the Visual UPF dialog box, choose Power > Visual UPF.
    For information about Visual UPF, see the Power Compiler User Guide.

    Include the create_voltage_area settings for nested power domains in
    each hierarchical design.  Get the block voltage area coordinates from
    the following IC Compiler Hierarchical Reference Methodology report:

    o  ${DESIGN_NAME}.icc_dp.voltage_area.rpt

    Make a "create_voltage_area" script file for each design with the
    following file name:

    o  ${DESIGN_NAME}.create_voltage_area.tcl

6.  (Multicorner-multimode flow only) Ensure that you have the additional
    input files that you need for each hierarchical design block.

    The dc.mcmm.scenarios.tcl file shows a general example of a scenario
    setup file for a multicorner-multimode flow in Design Compiler.

    You must have the following file:

    o  ${DCRM_MCMM_SCENARIOS_SETUP_FILE}, which is the scenario setup file

    You also need scenario-specific versions of the following files:

    o  ${DCRM_CONSTRAINTS_INPUT_FILE}, which provides the logic design constraints
    o  ${DCRM_SDC_INPUT_FILE}, which provides the SDC constraints
    o  ${DCRM_MV_SET_VOLTAGE_INPUT_FILE}, which provides the set_voltage commands

    Scenario-specific files should use the base file name defined in
    dc_setup_filenames.tcl and should include the scenario name
    somewhere in the file name. You can configure how the scenario name
    is added to the base file name by changing the dcrm_mcmm_filename
    Tcl procedure defined in dc_setup_filenames.tcl.

    This naming style applies to both input and output files in the
    multicorner-multimode flow.

7.  If you want to use Design Compiler ILMs, include the ILM creation step
    at the end of the script:

    create_ilm
    write -format ddc -hierarchy \
       -output ${RESULTS_DIR/${DCRM_FINAL_ILM_DDC_OUTPUT_FILE}

8.  Run synthesis in each of the block subdirectories:

    For the standard reference methodology flow, run the tool from the directory
    above the rm_setup directory.

    % cd ${BLOCK_DESIGN_NAME}
    % dc_shell -topographical_mode -f rm_dc_scripts/dc.tcl | tee dc.log

    For the Lynx-compatible reference methodology flow, run the tool from the
    working directory, ${BLOCK_DESIGN_NAME}/rm_dc/tmp. Make sure that both the working
    directory and the log directory, ${BLOCK_DESIGN_NAME}/rm_dc/dc/logs, exist before
    you run the tool.

    % mkdir -p ${BLOCK_DESIGN_NAME}/rm_dc/tmp ${BLOCK_DESIGN_NAME}/rm_dc/logs/dc
    % cd ${BLOCK_DESIGN_NAME}/rm_dc/tmp
    % dc_shell -topographical_mode \
               -f ../../scripts_block/rm_dc_scripts/dc.tcl | tee ../logs/dc/dc.log

9.  Verify the synthesis results by looking at your log file and studying
    the reports created in the ${REPORTS} directory.

    When you are satisfied that synthesis completed successfully, proceed to
    Formality verification in the next step.

10. Edit fm.tcl as needed for Formality verification.

11. (Multivoltage flow only) If you are mapping to retention registers, replace
    the technology library models of those cells with Verilog simulation models
    for Formality verification.

    For details, see the following SolvNet article:

    https://solvnet.synopsys.com/retrieve/024106.html

12. Verify each block synthesis run separately with Formality

    For the standard reference methodology flow, enter the following command:

    % cd ${BLOCK_DESIGN_NAME}
    % fm_shell -topographical_mode -f rm_dc_scripts/fm.tcl | tee fm.log

    For the Lynx-compatible reference methodology flow, enter the following
    commands:

    % cd ${BLOCK_DESIGN_NAME}/rm_dc/tmp
    % fm_shell -topographical_mode \
               -f ../../scripts_block/rm_dc_scripts/fm.tcl | tee ../logs/dc/fm.log

13. (Multivoltage flow only) Perform static verification of the multivoltage design
    with MVRC by running the MVRC Static Verification Reference Methodology script
    mvrc.tcl.

    For more information, see README.MVRC-RM.txt.

14. Verify that all of your block-level runs have been completed successfully.


To run the Design Compiler Reference Methodology scripts for top-level synthesis
in a hierarchical flow,

1.  Create an additional subdirectory for your top-level synthesis.

    Note that the IC Compiler Hierarchical Reference Methodology does this
    automatically.

2.  Edit common_setup.tcl at the top-level.

    o  Include the list of hierarchical design names and cell names in the
       common_setup.tcl variables shown in the following example:

       #############################################################################
       # Hierarchical Flow Design Variables
       #############################################################################

       set HIERARCHICAL_DESIGNS    "" ;# List of hierarchical block design names
                                         "DesignA DesignB" ...
       set HIERARCHICAL_CELLS      "" ;# List of hierarchical block cell instance
                                         names "u_DesignA u_DesignB" ...

    o  Add any IC Compiler ILMs and any IC Compiler block abstractions to the
       ${MW_REFERENCE_LIB_DIRS} variable.

       Specify the Milkyway design library that contains the IC Compiler ILM or
       block abstraction for the abstracted block.

3.  Define the hierarchical block design names in the dc_setup.tcl file:

    o  DDC_HIER_DESIGNS -- list of Synopsys logical database format (.ddc)
       hierarchical design names

    o  DC_ILM_HIER_DESIGNS -- list of Design Compiler ILM hierarchical design names

    o  ICC_ILM_HIER_DESIGNS -- list of IC Compiler ILM hierarchical design names

    o  ICC_BLOCK_ABSTRACTION_DESIGNS -- list of IC Compiler block abstraction
       design names

    o  DC_BLOCK_ABSTRACTION_DESIGNS  -- list of Design Compiler block abstraction
       hierarchical designs without transparent interface optimization

    o  DC_BLOCK_ABSTRACTION_DESIGNS_TIO --  list of Design Compiler block
       abstraction hierarchical designs with transparent interface optimization

4.  Ensure that you have all of the design-specific input files that you need
    to use in the flow.

    The tool picks up these files automatically from the search path defined in
    common_setup.tcl. The minimum set of recommended files consists of

    o  ${DCRM_CONSTRAINTS_INPUT_FILE}, which provides the logic design constraints

    o  ${DCRM_DCT_DEF_INPUT_FILE} or ${DCRM_DCT_FLOORPLAN_INPUT_FILE}, which
       provides the floorplan to use for topographical mode synthesis

    o  ${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE}, which provides the DFT signal
       definitions

    Use the same constraints for top-level synthesis that you would use for a
    top-down flow.

    o  For topographical mode synthesis, include the floorplan for the top-level
       design.

    o  Use a floorplan where the hierarchical blocks have been partitioned and
       have fixed placement at the top-level.

       The IC Compiler Hierarchical Reference Methodology creates an updated
       top-level floorplan with fixed placement information for the hierarchical
       blocks.

    A complete list of the expected input files is provided at the end of this
    README file.

5.  (Multivoltage flow only) Ensure that you have the additional files that you
    need for this flow.

    The minimum set of recommended files consists of

    o  ${DCRM_MV_UPF_INPUT_FILE}, which is the top-level UPF setup file

    o  ${DCRM_MV_SET_VOLTAGE_INPUT_FILE}, which provides the top-level
       set_voltage commands

    o  ${DCRM_MV_DCT_VOLTAGE_AREA_INPUT_FILE}, which provides the
       create_voltage_area commands for topographical mode synthesis

    Note:
       The UPF file for top-level synthesis should include UPF design information
       for the top-level design only. Block-level UPF information is propagated to
       the top-level design as a part of the flow.

    You can also use Visual UPF in Design Vision to generate a UPF template for
    your design. To open the Visual UPF dialog box, choose Power > Visual UPF.
    For information about Visual UPF, see the Power Compiler User Guide.

6.  (Multicorner-multimode flow only) Ensure that you have the input files that
    you need for this flow.

    The dc.mcmm.scenarios.tcl file shows a general example of a scenario
    setup file for a multicorner-multimode flow in Design Compiler.

    You must have the following file:

    o  ${DCRM_MCMM_SCENARIOS_SETUP_FILE}, which is the scenario setup file

    You also need scenario-specific versions of the following files:

    o  ${DCRM_CONSTRAINTS_INPUT_FILE}, which provides the logic design constraints
    o  ${DCRM_SDC_INPUT_FILE}, which provides the SDC constraints
    o  ${DCRM_MV_SET_VOLTAGE_INPUT_FILE}, which provides the set_voltage_commands

    Scenario-specific files should use the base file name defined in
    dc_setup_filenames.tcl and should include the scenario name
    somewhere in the file name. You can configure how the scenario name
    is added to the base file name by changing the dcrm_mcmm_filename
    Tcl procedure defined in dc_setup_filenames.tcl.

    This naming style applies to both input and output files in the
    multicorner-multimode flow.

7.  Run synthesis at the top-level:

    For the standard reference methodology flow, run the tool from the directory
    above the rm_setup directory.

    % cd ${TOP_DESIGN_NAME}
    % dc_shell -topographical_mode -f rm_dc_scripts/dc_top.tcl | tee dc.log

    For the Lynx-compatible reference methodology flow, run the tool from the
    working directory, ${TOP_DESIGN_NAME}/rm_dc/tmp. Make sure that both the working
    directory and the log directory, ${TOP_DESIGN_NAME}/rm_dc/dc/logs, exist before
    you run the tool.

    % mkdir -p ${TOP_DESIGN_NAME}/rm_dc/tmp ${TOP_DESIGN_NAME}/rm_dc/logs/dc
    % cd ${TOP_DESIGN_NAME}/rm_dc/tmp
    % dc_shell -topographical_mode \
             -f ../../scripts_block/rm_dc_scripts/dc_top.tcl | tee ../logs/dc/dc_top.log

8.  Verify the synthesis results by looking at your log file and studying the
    reports created in the ${REPORTS} directory.

    When you are satisfied that synthesis completed successfully, proceed to
    Formality verification in the next step.

9.  Edit fm_top.tcl as needed for Formality verification.

10. (Multivoltage flow only) Ensure that the UPF integration files are correct.

    The dc_top.tcl script writes out the following two UPF integration files
    automatically to facilitate verification of the top-level design in Formality:

    o  ${RESULTS}/${DESIGN_NAME}.full_chip.RTL.upf
    o  ${RESULTS}/${DESIGN_NAME}.full_chip.mapped.upf

    You are responsible for carefully examining these files for
    correctness.

11. Verify your top-level synthesis in Formality:

    For the standard reference methodology flow, enter the following command:

    % cd ${TOP_DESIGN_NAME}
    % fm_shell -topographical_mode -f rm_dc_scripts/fm_top.tcl | tee fm.log

    For the Lynx-compatible reference methodology flow, enter the following
    commands:

    % cd ${TOP_DESIGN_NAME}/rm_dc/tmp
    % fm_shell -topographical_mode \
             -f ../../scripts_block/rm_dc_scripts/fm_top.tcl | tee ../logs/dc/fm_top.log

12. (Multivoltage flow only) Perform static verification of the full chip
    multivoltage design with MVRC by using the MVRC Static Verification Reference
    Methodology script mvrc_top.tcl.

    For more information, see README.MVRC-RM.txt.

The final written netlist contains the design without the physical hierarchical
blocks. The next tool in the flow is expected to read the physical block-level
synthesis results in addition to the top-level synthesis results to obtain the
complete synthesized design.


Input Files for the Design Compiler Reference Methodology
=========================================================

Note:
   Not all of these files are required. You can see the complete list of input files
   and define the file names in the dc_setup_filenames.tcl file.

------------------------------------------------------------------------------------
File                                    Description
------------------------------------------------------------------------------------
${RTL_SOURCE_FILES}                     List of RTL source files defined in
                                        dc_setup.tcl

${DCRM_RTL_READ_SCRIPT} and
${FMRM_RTL_READ_SCRIPT}                 RTL read scripts

${DCRM_CONSTRAINTS_INPUT_FILE}          Logic design constraints for synthesis,
                                        top-level in hierarchical flow

${DCRM_SDC_INPUT_FILE}                  Budgeted SDC logic design constraints for
                                        blocks in hierarchical flow

${DESIGN_NAME}.saif                     Activity Interchange Format (SAIF) file
                                        for gate-level power optimization

${DCRM_MCMM_SCENARIOS_SETUP_FILE}       Setup file for scenarios in a
                                        multicorner-multimode flow

${DCRM_DCT_DEF_INPUT_FILE} or
${DCRM_DCT_FLOORPLAN_INPUT_FILE}        DEF floorplan to use for topographical
                                        mode synthesis

${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE}     DFT signal definitions

${DCRM_DFT_AUTOFIX_CONFIG_INPUT_FILE}   DFT AutoFix configuration

${DCRM_DFT_OCC_CONFIG_INPUT_FILE}       DFT on-chip clocking configuration

${DCRM_MV_UPF_INPUT_FILE}               UPF setup file for multivoltage flow

${DCRM_MV_SET_VOLTAGE_INPUT_FILE}       set_voltage commands for multivoltage flow

${DCRM_MV_DCT_VOLTAGE_AREA_INPUT_FILE}  create_voltage_area commands for
                                        multivoltage flow
------------------------------------------------------------------------------------


Output Files from the Design Compiler Reference Methodology
===========================================================

The ${REPORTS} directory defined in dc_setup.tcl contains reports from the
synthesis run.

The ${RESULTS} directory defined in dc_setup.tcl contains the synthesis
output files, including the mapped netlist and the files needed for timing
analysis, power analysis, and formal verification.

You can see the complete list of output files and define the file names in
the dc_setup_filenames.tcl file.

The output files generated by the Design Compiler Reference Methodology
scripts are designed to be used as inputs for the IC Compiler Reference
Methodology.  The IC Compiler Reference Methodology is the next step in the
reference flow and is available as a separate download from SolvNet.
