################################################################################
# Physical Library Preparation Reference Methodology for GDS_IN flow
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
################################################################################


A reference methodology provides a set of reference scripts that serves as a
good starting point for running a tool. These scripts are not designed to run
in their current form. You should use them as a reference and adapt them for
use in your design environment.

Before you use IC Compiler, logical and physical libraries must be created
that accurately reflect the characteristics of the available technology and
cells that will be used to fabricate the chip. The physical libraries are
prepared from layout data provided by an external source. The processing of
this information is called library data preparation.

A physical library contains information about the geometry of the cells that
are placed in the design and connected with power, ground, clock, and signal
routes. This library information includes the cell dimensions, border, pin
locations, and mask layers, as well as technology information such as wire
tracks, antenna rules, and electromigration data.

The Physical Library Preparation Reference Methodology supports both GDS_IN
and LEF_IN flows with the following tasks:
	Create standard cell libraries
	Import cell data in GDSII, and LEF format
	Specify technology information
	Specify power and ground port types
	Flatten cell hierarchy
	Extract blockage, pin and via information to make FRAM views
	Set place and route boundaries for single and multiple height cells 
	Define/Check wire tracks 
	Import/Export antenna properties
	Define diode port
	Annotate logic information from .db file to FRAM views 
	Check libraries 

Contents
========

The "GDS_IN" flow of Physical Library Preparation Reference Methodology includes
the following files:
----------------------------------

README.LIBPREP-RM_gds.txt
README.check_std_cell_pin_access.pdf
Release_Notes.LIBPREP-RM.txt

rm_setup/
rm_setup/libprep_setup.tcl
rm_setup/Makefile_gds_in

rm_libprep_gds_in_scripts/
rm_libprep_gds_in_scripts/analyze_lib.tcl
rm_libprep_gds_in_scripts/bpv.tcl
rm_libprep_gds_in_scripts/check_lib.tcl
rm_libprep_gds_in_scripts/check_std_cell_pin_access_amd64.tcl
rm_libprep_gds_in_scripts/check_std_cell_pin_access_linux.tcl
rm_libprep_gds_in_scripts/check_std_cell_pin_access_suse32.tcl
rm_libprep_gds_in_scripts/check_std_cell_pin_access_suse64.tcl
rm_libprep_gds_in_scripts/create_ref_libs.tcl
rm_libprep_gds_in_scripts/diode_ports.tcl
rm_libprep_gds_in_scripts/lib_db.tcl
rm_libprep_gds_in_scripts/multi_height.tcl
rm_libprep_gds_in_scripts/pr_bdry.tcl
rm_libprep_gds_in_scripts/read_gds.tcl
rm_libprep_gds_in_scripts/check_wire_tracks.tcl
rm_libprep_gds_in_scripts/wire_tracks.tcl
rm_libprep_gds_in_scripts/smash.tcl
rm_libprep_gds_in_scripts/set_port_types.tcl
rm_libprep_gds_in_scripts/extract_antenna.tcl
rm_libprep_gds_in_scripts/read_final_gds.tcl

libprep_setup.tcl:
------------------
rm_setup/libprep_setup.tcl is the primary file that needs to be edited. This is 
where you set all the variables that will be used to run the flow. You may 
create several configuration files, and use them by changing the variable 
FLOW_CONFIG either in the Makefile or on the make command line.

Makefile_gds_in:
----------------
The Makefile is used to control the overall GDS-in flow. In most cases there 
should be no need to edit the Makefile (except for specifying the configuration 
file, see below). It only shows when you select the "GDS_IN" flow.

To run:
-------
Set up your environment to run Milkyway executables. 

Log files are written to the "log" directory. They have the same names as
the targets.

*  To run the GDS_IN flow of the reference methodology scripts, enter the 
   following command:
   
   % make -f rm_setup/Makefile_gds_in init clean complete

Should a makefile target fail, examine the log file, make the 
necessary changes to the configuration file, and re-run 
"make -f rm_setup/Makefile_gds_in complete". You can also
run each target by entering "make -f rm_setup/Makefile_gds_in <target>".

The makefile touch files are stored in the directory "touchfiles".

To use a specific configuration file, enter

% make -f rm_setup/Makefile_gds_in <target> FLOW_CONFIG=my_config_file

General Information:
--------------------
All the commands are written for execution in Tcl mode.

Milkyway is both a tool and a database. The Milkyway Environment tool is used 
to bring in different types of data (in this case GDS files) and then convert 
the data into the Milkyway database.

The flow creates some files in the "dump" directory. These files are often 
re-used in several parts of the flow. Do not delete or modify them. You may 
find the information in them useful for debugging.

The flow has not been tested or created for standard cells with vertical rails.
It does, however, support libraries with rails on metal1 or metal2.


=========================================
A brief description of each Makefile step
=========================================

init:
-----
Initializes the GDS_IN flow; deletes files created by previous operations 
and creates the directories needed for storing data if those directories do 
not already exist. 

clean:
------
Cleans up the run environment to get rid of all log files and files created 
when Milkyway Environment is run interactively in the working directory. 

complete:
---------
Runs the entire flow in one operation.

create_ref_libs:
----------------
Creates the Milkyway library and sets the bus naming style of the library. 
Creates an .avntrc file with the library name as default name for "Open Library".

read_gds:
---------
Reads in the GDS file and creates the CEL view. It also creates three files 
with lists of cells in the GDS file -- one for standard cells, one for I/O
cells, and one for other types of cells. These lists are used later in the 
flow.

smash:
------
Smashes (flattens) the CEL views. This is primarily required for macros and 
pads. It smashes to a depth of 20 by default. If you know that all pin shapes are on a "lower" level in the GDS file, you 
might want to change this setting in the script. Depending on the complexity of 
the cells, the runtime may be long, and you may have to run in 64 bit mode. 
Also optionally truncates 
pin names and replaces characters (for example, for bus naming).

set_port_types:
---------------
Sets the port types for power and ground pins.

bpv:
----
Creates the FRAM (abstract) view of each cell, which contains only the blockage,
pin, and via information of the CEL view. It is the FRAM representation that
IC Compiler uses in for place and route. The FRAM view is also called the cell 
master. The extraction process uses one of two different methods, depending on 
the cell type (standard cell or other). The process also optionally applies a 
rotation to all I/O cells.

This is a step that may need some modification. There is a large variation of
how the cell data is organized in libraries, and although you can influence
the FRAM view creation through the variables in the setup.tcl file, there may
be cases where you may have to do more changes.

pr_bdry:
--------
Creates the PR boundary for standard cells and the unitTile. The unitTile 
height establishes the floorplan row height. The width of the unitTile 
establishes the metal2 pitch (or metal1 pitch for libraries with the rails 
on metal2).

multi_height:
-------------
cmSetMultiHeightProperty must be run on all multi-height cells. Since running 
cmSetMultiHeightProperty has no effect on single-height cells, it is advisable
to run multi_height on any standard cell library that you run pr_bdry on. This
step is skipped if there are no standard cells in the library.

wire_tracks:
------------
Changes the wire track offset, which can improve access to standard cell pins.
By default, an offset of half the unit tile width is applied for vertical
layers. Some libraries are designed with the pins one full pitch from the 
boundary; in this case you need to modify the script. Sometimes it is also 
necessary to adjust individual layers. Use the next target (check_wire_tracks)
to create a report of the pin accessibility quality. This step is skipped if 
there are no standard cells in the library.

check_wire_tracks:
------------------
Checks the accessibility of standard cell pins in the FRAM view. This step is 
skipped if there are no standard cells in the library.

extract_antenna:
----------------
Calculates or reads in the antenna properties for each cell in the library.
Uses IC Validator for antenna property extraction. Be aware that this may take
long time for libraries with many cells.

diode_ports:
------------
Converts input pins of diode cells to "diode ports". This is required for
cells that are to be used as antenna protection diodes.

lib_db:
-------
Annotates the FRAM view with pin direction and pin type information taken 
from the .db representation of the cell. 

read_final_gds:
---------------
The default is OFF in GDS_IN flow.

Since the CEL views are smashed and possibly pin names are modified, it is 
necessary to do a clean stream-in at the end. Now the CEL view is a 1:1 
representation of the cell GDS, ready for stream-out.

check_lib:
----------
Runs the check_library command in Milkyway Environment. 

analyze_lib:
----------
Runs the pin access check utility for a standard cell library in IC Compiler.

start_mw:
---------
Starts Milkyway Environment in Tcl mode without executing any commands. Good 
for interactive work and viewing the results.


============================================
A detailed description of each Makefile step
============================================

The following "man pages" describe the Makefile steps in detail, including 
the "make" target name, syntax, arguments, variables used, behavior 
description, messages issued, and usage examples. They are organized in 
alphabetical order by target name. 

--------------------------------------------------------------------------------
analyze_lib.txt

NAME
        analyze_lib       "make" target for running pin access check for
                          standard cell library.

SYNTAX
        make -f rm_setup/Makefile_gds_in analyze_lib


ARGUMENTS
        You may specify the configuration file to be used with the argument:

        FLOW_CONFIG=<your configuration file path/name>


VARIABLES
        This target uses the following flow variables from the configuration
        file:
                $ref_lib                Path where the working library is
                                        stored

                $library_name           Name of the working library

                $mw_techfile            Milkyway technology file to be used in
                                        the new library

                $run_pin_access         Run or skip "Pin Access Checking 
                                        Utility"

                $run_routing            Run or skip routing for all pin access
                                        checking cells

                $check_cell_list        Check selected cell(s) against all
                                        cells in the input standard cell 
                                        library or libraries

                $icc_platform           Select IC Compiler platform for utility


DESCRIPTION
        This target does the following:

                1) Loads the specified configuration file (see the ARGUMENTS
                   section).

                2) Runs pin access check utility.

        This target is used to run a pin access check on the standard cell
        library. The "Pin Access Checking Utility" analyzes a physical library
        and finds potential pin accessibility issues in the analyzed_lib stage. 
        You should review the log file and investigate the reasons for any
        warnings.

        Please see the README.check_std_cell_pin_access.pdf file for more details.

EXAMPLE
        Run the "analyze_lib" step with the default configuration file:

        make -f rm_setup/Makefile_gds_in analyze_lib

        Use a specific configuration file:

        make -f rm_setup/Makefile_gds_in analyze_lib FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
bpv.txt

NAME
	bpv			"make" target for creating the FRAM views.


SYNTAX
	make -f rm_setup/Makefile_gds_in bpv


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$bpv_power_rail_metal	Metal layer of power rail

		$bpv_ground_rail_metal	Metal layer of ground rail

		$bpv_skip_lef_syntax	Force to skip LEF DESIGNRULEWIDTH and
					SPACING syntax during read_lef

		$bpv_flag_file		Set user specified BPV variables in a
					file

		$std_cell_pin_layer	If the cell pins exist on several
					layers, the FRAM view pin will be
					created only on this layer

		$poly_pin_text_layer	(optional) The GDS layer containing the
					text labels for poly pins

		$m1_pin_text_layer	(optional) The GDS layers containing
			through		the text labels for metal1 through
		$m12_pin_text_layer	metal12 pins, respectively

		$poly_must_connect_layer	(optional) The GDS layer
						containing must-join polygon
						data for poly pins

		$m1_must_connect_layer		(optional) The GDS layers
			through			containing must-join polygon
		$m12_must_connect_layer		data for metal1 through metal12
						pins, respectively

		$std_cell_contacts	(optional) List of contact code numbers
					that are to be used for the creation
					of via solutions for standard cell pins

		$std_cell_skip_rotated_vias	Defines if the contact codes
						can be rotated for the creation
						of via solutions for the
						standard cell pins

		$block_macro_layer_poly		Defines how the blockages for
						macro cells should be created
						for the poly layer

		$block_macro_layer_m(1)		Defines how the blockages for
			through			macro cells should be created
		$block_macro_layer_m(12)	for the metal1 through metal12
						layers, respectively

		$merge_threshold	(optional) Threshold for merging 
					polygons in macro FRAM views. Will be
					used for all layers.

		$edge_distance		(optional) Distance from the boundary
					to the complete blockage area for non-
					standard cells. Will be used for all
					layers.

		$pad_rotation		(optional) A global rotation to be
					applied for all I/O cells

		$flow_stdcell_file	Name of the file containing the names
					of all standard cells

		$flow_iocell_file	Name of the file containing the names
					of all I/O cells

		$flow_nonstdcell_file	Name of the file containing the names
					of all non-standard cells


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Performs sanity checks on the required variables.

		3) Reads in the list of all standard cells, stored in the file
		   defined by $flow_stdcell_file.

		4) Reads in the list of all non-standard cells, stored in the
		   file defined by $flow_nonstdcell_file.

		5) Creates the FRAM views for standard cells.

		6) Creates the FRAM views for non-standard cells.

		7) Rotates all I/O cells, if the variable $pad_rotation is set.

	The "bpv" target creates the FRAM views. This is the step that will
	require most modifications, since the method of creating FRAM views
	needs to be different for each library. Here are some examples of cell
	data to consider:

	Standard cells:
	---------------

	- Which contacts are allowed? For smaller technologies, you may have
	  specific contacts that fulfill end-of-line rules.

		Related variable: $std_cell_contacts

	- Can the contacts be freely rotated? The same reasons as above apply.

		Related variable: $std_cell_skip_rotated_vias

	- How should pins that have polygons on more than one layer be handled?
	  In some technologies, pins that are defined on an upper layer must be
	  connected on that layer only, so the lower layer polygons must be
	  blocked.

		Related variable: $std_cell_pin_layer

	- On which layers in the GDS file are the pin texts defined? The pins
	  are identified by the labels. Unless they are on the same layer and
	  datatype as the metal polygons, you need to specify the layers. For
	  standard cells, only poly up to metal4 are handled by the script.

		Related variables: $poly_pin_text_layer,
		$m1_pin_text_layer - $m4_pin_text_layer

	- Are there any "must-connect" polygons? Sometimes, an extra marking
	  layer is used to restrict where the pins can be connected. If so, you
	  need to define the layer (and datatype) they are defined on. For
	  standard cells, only poly up to metal4 are handled by the script.

		Related variables: $poly_must_connect_layer,
		$m1_must_connect_layer - $m4_must_connect_layer

	Macros and pads
	---------------

	- Where are the pins? If all pins are on the boundary, it's usually
	  best to let Milkyway compute a complete blockage. If the pins are
	  inside the cell, you may have to keep all the polygons in the FRAM
	  view so that IC Compiler can find the correct route channels.

		Related variables: $block_macro_layer_poly,
		$block_macro_layer_m(1) - $block_macro_layer_m(12)

	- On which layers in the GDS file are the pin texts defined? The pins
	  are identified by the labels. Unless they are on the same layer and
	  datatype as the metal polygons, you need to specify the layers.

		Related variables: $poly_pin_text_layer,
		$m1_pin_text_layer - $m12_pin_text_layer

	- How are the pins to be identified? Per default, the script will look
	  for text labels, and follow touching or overlapping polygons to find
	  the entire pin shape. If this does not produce good FRAM view pins,
	  you may have to experiment with other settings. All the options are
	  listed in the script.

	- Are there any "must-connect" polygons? Sometimes, an extra marking
	  layer is used to restrict where the pins can be connected. If so, you
	  need to define the layer (and datatype) they are defined on.

		Related variables: $poly_must_connect_layer,
		$m1_must_connect_layer - $m12_must_connect_layer

	- Are there feedthrus (free channels for top level routing) defined in
	  the cells? Then you need to define these directly in the script, as
	  there are no variables defined. In the script, the options are listed
	  with a default value of "" (empty string) similar to this:

		setFormField make_macro metal_1_feedthru_layer ""

	- Where are the pins located? If they are not on the macro boundary,
	  you may use the variable $edge_distance to specify where the tool 
	  should start creating a complete blockage. Usually it's best to 
	  simply measure the distance from the boundary to the outer edge of 
	  the pins.

	- Using the merge option: If you set the layer handling to "merge" in
	  the configuration file, and leave the $merge_threshold at 0, all the
	  objects on that layer will be kept in the FRAM view. Depending on the
	  complexity of the cell, you may instead want to let Milkyway merge
	  them. The $merge_threshold could for example be set to the largest
	  fat spacing of the layer.

	Generating FRAM views for macros, pads, and other non-standard cells may
	require several tries until you have found the best settings. You will
	find all the command options listed in the script together with their
	default values. The most common settings are handled with variables,
	but some may need direct modifications in the script.

	If you have cells in one library that require different handling, you
	may have to re-run the geNewMakeMacro command manually on those cells,
	as the script will apply the same settings to all cells.


MESSAGES
	GDS CELL PREP FLOW ERROR >> Invalid value for $std_cell_pin_layer = "<value>"
	                            Valid values are 1, 2 or 3.

	The variable $std_cell_pin_layer tells Milkyway which layer pins should
	be created on. It must be set to 1, 2 or 3.


	GDS CELL PREP FLOW WARNING >> No I/O cells found in the library.
	                              No rotation can be applied.

	You have defined a pad rotation in the $pad_rotation variable, but
	the list of I/O cells was empty. Maybe you have forgotten to specify
	the I/O cells in the mapping file for read_gds. 


EXAMPLE
	Run the "bpv" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in bpv

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in bpv FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
check_lib.txt

NAME
	check_lib	"make" target for running several check reports.

SYNTAX
	make -f rm_setup/Makefile_gds_in check_lib


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Runs check_library.

	This target is used to run a number of reports and checks on the
	library. You should review the log file and investigate the reasons for
	any warnings.

	Please see the man page for check_library for more details.


EXAMPLE
	Run the "check_lib" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in check_lib

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in check_lib FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
check_wire_tracks.txt

NAME
	check_wire_tracks	"make" target for reporting how well the wire
				tracks match the cell pins.

SYNTAX
	make -f rm_setup/Makefile_gds_in check_wire_tracks


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Checks if there are any standard cells in the library. Exits
		   if not.

		3) Runs axgCheckWireTrack.

	This target is used to check how well the wire tracks, created in the
	previous step wire_tracks, match the pin locations. After this target
	is run, examine the report in the log file. There should be only a
	small number of off-grid pins. If not, modify the wire_tracks.tcl
	script, delete the touch files for wire_tracks and check_wire_tracks
	(in the directory ./touchfiles), and re-run "make -f
	rm_setup/Makefile_gds_in check_wire_tracks".

	Please see the man page for wire_tracks for more details.


MESSAGES
	GDS CELL PREP FLOW INFO >> No standard cells in the library - 
	skipping step check_wire_tracks.

	This message simply tells you that since there are no standard cells in
	the library, the rest of this target is skipped.


EXAMPLE
	Run the "check_wire_tracks" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in check_wire_tracks

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in check_wire_tracks FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
clean.txt

NAME
	clean			"make" target for cleaning up temporary and log
				files in the flow environment.

SYNTAX
	make -f rm_setup/Makefile_gds_in clean


ARGUMENTS
	There are no arguments for this step.


VARIABLES
	No variables are used in this step.


DESCRIPTION
	The "clean" step does the following:

		- Deletes all log and command files from the working directory
		- Deletes and re-creates the "log" directory

	The "clean" step is typically used to clean up the run environment to
	get rid of all log files and files created when Milkyway Environment
	is run interactively in the working directory.

	There is no dependency from any other steps, so it can be run at any
	time.


EXAMPLE
	Run the "clean" step:

	make -f rm_setup/Makefile_gds_in clean


--------------------------------------------------------------------------------
create_ref_libs.txt

NAME
	create_ref_libs		"make" target for creating a new Milkyway
				library.


SYNTAX
	make -f rm_setup/Makefile_gds_in create_ref_libs


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib	Path where the new library should be created

		$library_name	Name of the library to be created

		$mw_techfile	Milkyway technology file to be used in the new
				library

		$busstyle	Bus naming style to be used in the new library

                $extended_layer	Extended layer mode to be used in the new library


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section)

		2) Performs sanity checks on the required variables

		3) If the library specified already exists, deletes it

		4) Creates the directory that will hold the library. Will
		   create an error and exit the flow if the directory could
		   not be created.

		5) Creates the library, using the bus naming style specified
		   with the $busstyle variable. Will create an error and exit
		   the flow if the library could not be created.

		6) Creates a .avntrc file with the library name as the default
		   argument for "Open Library". This can be useful if you want
		   to open the library manually for debugging.

	The library is created with the case-sensitive mode on.

	Be aware that running this target will delete any previous library with
	the same name and directory as defined in the configuration file!


MESSAGES
	GDS CELL PREP FLOW ERROR >> Tech file not found or variable $mw_techfile 
	not set.

	The technology file you specified could not be found, or the variable
	$mw_techfile in the configuration file is empty. Check that you have
	specified a valid technology file and re-run the target.


	GDS CELL PREP FLOW ERROR >> Library name variable $library_name not set.

	The variable $library_name is mandatory but was empty. Specify a
	library name in the configuration file and re-run the target.


	GDS CELL PREP FLOW ERROR >> Reference library directory <directory> 
	could not be created.

	Most likely cause is that you have entered an invalid directory name,
	or the permissions of that directory do not allow you to create it.


	GDS CELL PREP FLOW ERROR >> Reference library <directory/library> could	
	not be created.

	The Milkyway library could not be created. Look for messages from the
	tool in the log file. Possible causes could be missing file permissions
	or the technology file contains errors.


EXAMPLE
	Run the "create_ref_libs" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in create_ref_libs

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in create_ref_libs FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
diode_ports.txt

NAME
	diode_ports		"make" target for converting antenna diode cell
				ports to diode ports.

SYNTAX
	make -f rm_setup/Makefile_gds_in diode_ports


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$diode_cells		List of cells in the library that are
					diode cells

		$diode_pin		Name of the diode pin in each cell


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Performs sanity checks on the required variables.

		3) Converts the cell ports identified by $diode_cells and
		   $diode_pin to diode ports.

	Antenna protection diode cells have a special meaning in IC Compiler. 
	They are connected to signal or power nets, but are normally not 
	contained in the Verilog netlist. Therefore, the diode pins must be 
	marked using the command dbConvertPortToDiodePort.

	You have to provide a list of the cells in the library that are diode
	cells in the variable $diode_cells, and you also have to enter the
	name of the pin in $diode_pin (both are defined in the configuration
	file). The script assumes that the diode pins in all cells have the
	same name.


MESSAGES
	GDS CELL PREP FLOW INFO >> No diode cells to process.

	The variable $diode_cells is empty, so there are no cells to process
	and the target is ended without doing any changes to the library.


	GDS CELL PREP FLOW ERROR >> No diode pin name defined ($diode_pin)

	You have specified the diode cells, but not provided any pin name.
	Make sure that $diode_pin contains a valid pin name.


EXAMPLE
	Run the "diode_ports" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in diode_ports

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in diode_ports FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
extract_antenna.txt

NAME
	extract_antenna		"make" target for calculating antenna
				properties for all cells in the library.

SYNTAX
	make -f rm_setup/Makefile_gds_in extract_antenna


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$antenna_clf_file	(optional) CLF file containing the
					antenna properties

		$diffusion_layer	Layer number of the diffusion layer.

                $poly_layer		Layer number of the poly layer.

                $cont_layer		Layer number of the contact layer.

                $v0_layer		Layer number of the v0 layer.

                $m0_poly_layer		Layer number of the m0 layer for poly.

                $m0_diff_layer		Layer number of the m0 layer for
					diffusion.

                $cont_m0_diff_layer	Layer number of the contact layer
					between m0 and diffusion.

                $gate_class		Additional gate class mode to be used.

                $thick_mask1_layer	Layer number of the thick oxide layer
					for gate class 1.

                $thick_mask2_layer      Layer number of the thick oxide layer 
                                        for gate class 2.

                $thick_mask3_layer      Layer number of the thick oxide layer 
                                        for gate class 3.

		$flow_dump_clf_file	Name of the file to dump the resulting
					CLF data to

		$flow_stdcell_file	Name of the file containing the names
					of all standard cells

		$flow_nonstdcell_file	Name of the file containing the names
					of all non-standard cells


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Performs sanity checks on the required variables.

		3) Reads in the list of all cells, stored in the files
		   defined by $flow_stdcell_file and $flow_nonstdcell_file. If
		   $antenna_clf_file is set to a valid file, this step is
		   skipped.

		4) Extracts the antenna properties, using IC Validator via the
		   command signoffHierAntenna. If $antenna_clf_file is set to a
		   valid file, this step is skipped.

		5) Closes all open libraries. If $antenna_clf_file is set to a
		   valid file, this step is skipped.

		6) If $antenna_clf_file is set to a valid file, reads in this
		   file, which should contain all the antenna properties.

		7) Dumps the resulting antenna properties to a CLF file that
		   can be used for verifying the results.

	For successful antenna fixing, all cells should have the proper antenna
	properties. In short, these describe the gate and metal area ratios of
	input pins, and	the diode protection properties of output pins.

	This script supports two methods: direct extraction using IC Validator, or
	loading an existing file in CLF format.

	To use IC Validator, you need access to a IC Validator installation and
	license.

	The signoffHierAntenna command creates a runset from the technology file
	and the values entered in the script, launches IC Validator with this
	runset. IC Validator finds all gates and diodes in the cell, calculates the
	areas of gates, diodes, and metal, and finally writes the antenna
	properties to the FRAM view of the cell.

	The antenna property extraction with IC Validator may take some time. On a
	Linux 32-bit machine, it takes around 10-20 seconds per standard cell;
	macros may take longer.

	Most of the layer information can be derived directly from Milkyway,
	but you have to provide the layer number for the diffusion data, since
	this is not normally "known" to Milkyway.
	If your Milkyway technology file does not contain layer information
	for poly (maskName = poly) and poly contacts (maskName = polyCont),
	you need to add their layer numbers to the script.

	If you specify an input CLF file containing the antenna properties,
	maybe from a previous run to save time, most of the script is skipped
	and the CLF file is read in instead.


MESSAGES
	GDS CELL PREP FLOW ERROR >> Diffusion layer variable $diffusion_layer 
	not set.

	$diffusion_layer is a mandatory variable. Please set it in the
	configuration file.


	GDS CELL PREP FLOW ERROR >> Antenna CLF file <file> does not exist.

	You have specified a file to be read in, but the file could not be
	found. Check that you have entered a valid file name in the
	configuration file and try again.


	GDS CELL PREP FLOW INFO >> Loading antenna CLF file <file>.

	The specified CLF file is being loaded. This also indicates that no
	antenna extraction using IC Validator will be done.


	GDS CELL PREP FLOW INFO >> Antenna properties dumped to file <file>.

	The resulting antenna properties are dumped to this file so that you
	can verify the results.


EXAMPLE
	Run the "extract_antenna" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in extract_antenna

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in extract_antenna FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
init.txt

NAME
	init			"make" target for initializing the flow
				environment.


SYNTAX
	make -f rm_setup/Makefile_gds_in init


ARGUMENTS
	There are no arguments for this step.


VARIABLES
	No variables are used in this step.


DESCRIPTION
	The "init" step does the following:

		- Deletes the directory "touchfiles"
		- Deletes the file ".avntrc"
		- Creates the directory "log" if it does not already exist
		- Creates the directory "dump" if it does not already exist
		- Creates the directory "touchfiles" if it does not already
		  exist

	You typically use this step to initialize a fresh flow environment.
	There is no dependency from any other steps, so it can be run at any
	time. This step removes all the touchfiles, so you can use it to
	"reset" the flow for a complete run.

	This step does not delete any library data. All old logfiles are kept.


EXAMPLE
	Run the "init" step:

	make -f rm_setup/Makefile_gds_in init


--------------------------------------------------------------------------------
lib_db.txt

NAME
	lib_db			"make" target for annotating the FRAM view with
				pin direction and pin type information taken 
				from the .db library


SYNTAX
	make -f rm_setup/Makefile_gds_in lib_db


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$min_db_models		Lists of .db files to be read in for
		$nom_db_models		min, nom, max and other usage. Can be
		$max_db_models		either file names or a directory name
		$other_db_models


DESCRIPTION
	This target loads the specified configuration file, performs sanity 
	checks on the required variables, and annotates the FRAM view with pin 
	direction and pin type information taken from the .db library 
	representation of the cell. If you have the information in a .lib 
	library file, you first need to convert the library to .db format using 
	Library Compiler. 

	Each of the four variables used to name the .db files can name either a 
	single file name, multiple file names separated by spaces, or a 
	directory name. If you specify a directory name, all .db files in that 
	directory are read in.


MESSAGES
	GDS CELL PREP FLOW WARNING >> No .db file usage specified.
	                              No pin information is being annotated on 
	                              the FRAM view. If this is intentional, 
	                              enter "touch touchfiles/lib_db" at the 
	                              UNIX shell prompt to allow the flow to 
	                              continue with the next step.

	As indicated by the message, you have set $db_models to 0, which means 
	that you will not use any pin information from library files. The rest 
	of the script is skipped, but the touchfile is not created, so the flow 
	stops.

	GDS CELL PREP FLOW ERROR >> You have specified .lib files as the source.
	                            However, the script accepts only .db files.

	The script does not accept .lib files.

	GDS CELL PREP FLOW INFO >> Using all .db files in <directory> as min models.

	This message, and similar ones for nom, max, and other models, confirms
	that you have entered a directory name rather than individual file names.


EXAMPLE
	Run the "lib_db" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in lib_db

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in lib_db FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
multi_height.txt

NAME
	multi_height		"make" target for setting the multi-height
				properties on standard cells.

SYNTAX
	make -f rm_setup/Makefile_gds_in multi_height


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$flow_stdcell_file	Name of the file containing the names
					of all standard cells


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Checks if there are any standard cells in the library. Exits
		   if not.

		3) Runs cmSetMultiHeightProperty on all FRAM views of standard
		   cells in the library.

	Most standard cells are of "single" height, that is, they occupy exactly
	one row's height. The row height is always the same as the unit tile
	height. In some libraries, cells with a larger height may be used. One
	typical example for these cells are level shifters.

	When the PR boundary is created (in step pr_bdry), a table is created
	for each cell, which contains the allowed unit tile occupation for the
	cell. In this table, the unit tile name, rotation, and mirroring are
	stored. This table is referred to as the "tile pattern".

	For single-height cells, the tile pattern consists of one row and a
	number of columns corresponding to the cell width divided by the unit
	tile width.

	Cells with a larger height than one row need to have a table with more
	rows. The cmSetMultiHeightProperty takes the height information created
	in the pr_bdry step and updates the tile pattern. It also uses the
	information about the rail sharing defined in pr_bdry.

	Running cmSetMultiHeightProperty on single-height cells has no effect,
	so it is run on all standard cells in the library.


MESSAGES
	GDS CELL PREP FLOW INFO >> No standard cells in the library - skipping 
	step multi_height.

	There are no standard cells in the library, so the rest of the target
	is skipped.


EXAMPLE
	Run the "multi_height" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in multi_height

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in multi_height FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
pr_bdry.txt

NAME
	pr_bdry			"make" target for creating the PR boundary
				information and the unit tile cell.


SYNTAX
	make -f rm_setup/Makefile_gds_in pr_bdry


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$unit_tile_height	The height which should be used for the
					unit tile.

		$metal1_pg_rail		Boolean - defines if the power rails
					are parallel to metal1

		$metal2_pg_rail		Boolean - defines if the power rails
					are parallel to metal2

		$flow_stdcell_file	Name of the file containing the names
					of all standard cells


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Checks if there are any standard cells in the library. Exits
		   if not.

		3) Performs sanity checks on the required variables.

		4) Create the unitTile cell and PR Boundaries in FRAM views.


	The pr_bdry step is only done on standard cells. A PR boundary is
	created for each standard cell. This boundary is used for the placement
	overlap checks. Normally it has the same coordinates as the cell
	boundary. The unit tile cell, required for the floorplanning and
	placement steps, is also created in this step. P/G rails are identified
	and marked.

	Standard cells can be of two different types: either the P/G rails
	are shared between abutting rows "shared P/G (double-back)", or they
	are not "separate P/G". The script only handles double-back cells, but
	you can always modify it to handle libraries with separate rails.

	The script only handles libraries with horizontal rails.

	The P/G rails exist on different layers for different technologies. In
	this script, there are four combinations, controlled by the variables
	$metal1_pg_rail and $metal2_pg_rail. Depending on the settings, the
	three routing directions of the three first layers are defined and on
	which of the layers the rails will be marked:


		                       M1   M2   M3
		                    ------------------
		$metal1_pg_rail = 0 | Hor  Ver  Hor  |
		$metal2_pg_rail = 0 |  -    -   Rail |
		                    |----------------|
		$metal1_pg_rail = 0 | Ver  Hor  Ver  |
		$metal2_pg_rail = 1 |  -   Rail  -   |
		                    |----------------|
		$metal1_pg_rail = 1 | Hor  Ver  Hor  |
		$metal2_pg_rail = 0 | Rail  -    -   |
		                    |----------------|
		$metal1_pg_rail = 1 | Hor  Hor  Ver  |
		$metal2_pg_rail = 1 | Rail Rail  -   |
		                    ------------------

	You must define the unit tile height to be used. The auSetPRBdry
	command can calculate it, but if your library contains multi-height
	cells, this sometimes produces the incorrect results.

	The lower left corner of the PR boundary will be created based on the
	cell boundary. If you need to apply an offset, you have to modify the
	script.

	The height of the cells is set to be based on the cell height. For most
	libraries, this will be "1" or an integer value. This value is used in
	the "multi_height" target.


MESSAGES
	GDS CELL PREP FLOW INFO >> No standard cells in the library - skipping 
	step pr_bdry.

	This is just a message that you are working on a non-standard cell
	library, and that the PR boundary processing will be skipped. If this
	is wrong, you need to go back to the step read_gds and adjust the cell
	type information.


	GDS CELL PREP FLOW ERROR >> The unit tile height is incorrect or not defined.

	You must specify a unit tile height. Either you have not done so, or
	the value is 0 or negative in the configuration file. Variable:
	$unit_tile_height


EXAMPLE
	Run the "pr_bdry" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in pr_bdry

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in pr_bdry FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
read_final_GDS.txt

NAME
	read_final_GDS		"make" target for streaming in GDS again at the
				end of the flow.


SYNTAX
	make -f rm_setup/Makefile_gds_in read_final_GDS


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$GDS_file		Path and name of the GDS file to be
					read in

		$GDS_all_cell_type	(optional) file containing one single
					cell type definition to be used for all
					cells in the library

		$GDS_cell_type_file	(optional) file containing cell-by-cell
					mapping of cell types

		$flow_stdcell_file	Name of the file containing the names
					of all standard cells

		$flow_nonstdcell_file	Name of the file containing the names
					of all non-standard cells


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Performs sanity checks on the required variables.

		3) If no detailed cell type mapping file is defined in the
		   variable $GDS_cell_type_file, create a global cell type
		   mapping file. If the variable $GDS_all_cell_type is also
		   empty, all cells will be marked as standard cells.

		4) Reads in the cell list files.

		5) Deletes unneeded cells:
		   - all CEL views except "unitTile.CEL"
		   - any FRAM views not contained in the cell list files
		   - all SMASH views

		6) Removes old versions of "unitTile.CEL".

		7) Reads in the GDS file, without using any layer mappings.

	The data preparation flow makes several changes to the original CEL
	views, like layer mappings, text truncation, and smashing. As the last
	step, the GDS is therefore read in again so that the CEL views in the
	library are an exact representation of the GDS.

	In addition, this target also removes cells and cell versions that are
	created during the flow, so that the library is ready for use.


MESSAGES
	GDS CELL PREP FLOW ERROR >> GDS file <file> not found or variable 
	$GDS_file not set.

	The GDS file you specified could not be found, or the variable
	$GDS_file in the configuration file is empty. Check that you have
	specified a valid GDS file and re-run the target.


	GDS CELL PREP FLOW ERROR >> GDS cell type file <file> not found.

	You have specified a cell type mapping file, but the file could not be
	found.


EXAMPLE
	Run the "read_final_GDS" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in read_final_GDS

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in read_final_GDS FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
read_gds.txt

NAME
	read_gds		"make" target for streaming in GDS.


SYNTAX
	make -f rm_setup/Makefile_gds_in read_gds


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

                $top_macro_name		Name of the top hard macro   

		$gds_file		Path and name of the GDS file to be
					read in

		$gds_all_cell_type	(optional) file containing one single
					cell type definition to be used for all
					cells in the library

		$gds_cell_type_file	(optional) file containing cell-by-cell
					mapping of cell types

		$gds_boundary_layer	(optional) layer number to be mapped to
					the cell boundary

		$gds_layer_file		(optional) layer mapping file between
					GDS and Milkyway layers

		$flow_stdcell_file	Name of the file containing the names
					of all standard cells

		$flow_iocell_file	Name of the file containing the names
					of all I/O cells

		$flow_nonstdcell_file	Name of the file containing the names
					of all non-standard cells


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Performs sanity checks on the required variables.

		3) If no detailed cell type mapping file is defined in the
		   variable $gds_cell_type_file, creates a global cell type
		   mapping file. If the variable $gds_all_cell_type is also
		   empty, all cells will be marked as standard cells.

		4) Reads in the GDS file. Supports rectilinear outlines by
		   setting the scheme variable auStreamInRectilinearBoundary.
		   If a boundary layer has been specified with the variable
		   $gds_boundary_layer, this is used.

		5) Create 3 files with lists of the cells streamed in - one
		   with all standard cells, one with the I/O cells. and one with
		   all non-standard cells. The last one also contains the
		   names of the I/O cells. These files are used later in the
		   flow where different cell types require different handling.
		   Do not modify or delete these files.

	Boundaries: Usually, the cell boundaries (or cell frames) are stored on
	a specific layer. If you do not tell Milkyway which layer this is via
	the $gds_boundary_layer, it will look for objects on layer 255. If this
	layer is empty, the maximum bounding box, including texts, will be used.
	Therefore it is usually mandatory to supply the layer number.

	Cell types: Standard cells, I/O cells (pads, bumps), and macros have
	different requirements. For example, only standard cells receive PR
	boundaries and unit tiles. Therefore, you should specify which kind of
	cells are contained in the GDS file. If you only have one type, declare
	it in the $gds_all_cell_type variable. Otherwise, you can use a mapping
	file. This file can use wildcards. You can find more details in the
	configuration file.
	
	Note: For some library cells (like memories), you may get all the sub-
	cells listed in the file defined by $flow_nonstdcell_file. You should
	edit the file so that it contains only the desired top-level cell name;
	otherwise you will get FRAM views for each of them later in the flow.
	The number of cells read in is listed in the log file -- if the number
	is higher than what you expect, then you need to edit the file.


MESSAGES
	GDS CELL PREP FLOW ERROR >> GDS file <file> not found or variable
	$gds_file not set.

	The GDS file you specified could not be found, or the variable
	$gds_file in the configuration file is empty. Check that you have
	specified a valid GDS file and re-run the target.


	GDS CELL PREP FLOW ERROR >> GDS layer file <file> not found.

	You have specified a layer mapping file in the configuration file, but
	the file could not be found.


	GDS CELL PREP FLOW ERROR >> GDS cell type file <file> not found.

	You have specified a cell type mapping file, but the file could not be
	found.


	GDS CELL PREP FLOW INFO >> All cells will be marked as type <type>.

	This message just confirms that all cells will have one cell type, as
	defined in the variable $gds_all_cell_type.


        GDS CELL PREP FLOW ERROR >> Cells are not found in <file>.

        There is no any cell list in $flow_stdcell_file and
	$flow_nonstdcell_file.


EXAMPLE
	Run the "read_gds" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in read_gds

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in read_gds FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
smash.txt

NAME
	smash			"make" target for smashing the CEL views.


SYNTAX
	make -f rm_setup/Makefile_gds_in smash


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$smash_level		Level to smash to

		$pin_name_truncate_string	All strings in the library's
						cells will be truncated,
						starting with the first
						occurrence of this character

		$replace_char_from_1	These two are used for single-character
		$replace_char_to_1	replacements in all cells. All 
		$replace_char_from_2	occurrences of the "from" character 
		$replace_char_to_2	will be replaced with the "to" character.


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Performs sanity checks on the required variables.

		3) Smashes all cells in the library to the depth defined by
		   $smash_level.

		4) Truncates text. Typically, this is used to remove pin type
		   labels.

		5) Replaces 2 different characters. Typically used to change
		   the bus naming style of pins.

	Most cells in a library are hierarchical. They contain sub-cells, which
	may contain important information like pin polygons and labels. This is
	especially true for memories, analog macros, and pads. Therefore, the
	cells must be flattened or smashed, so that the subsequent steps can
	"see" the data that is needed.

	This script will by default smash to the 20th level. While this is
	enough for most libraries, the runtime and memory consumption when
	smashing large macros or memories may be very high. You can often
	reduce them by only smashing as far as needed. You can use the Window
	Options of Milkyway Environment to find out how far to smash: open the 
	"top" cell, open the Window Options dialog box, and increase the 
	"View Level" step by step until all important data is displayed. Then 
	use this level for smashing by changing the $smash_level variable in 
	the configuration file.

	If the target fails, look in the log file and the command shell for
	"out of memory" messages. You may be able to run the target successfully 
	on a 64 bit machine and executable.

	Standard cells usually don't require any smashing. Since they typically
	are flat, running the smash command is fast so you can let it run also
	for standard cells.


MESSAGES
	GDS CELL PREP FLOW ERROR >> Library <path/library> is empty.

	The Milkyway library does not contain any cells. Probably something
	went wrong during read_gds. Check the log file.


EXAMPLE
	Run the "smash" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in smash

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in smash FLOW_CONFIG=./config/lib_2_setup.tcl


--------------------------------------------------------------------------------
wire_tracks.txt

NAME
	wire_tracks		"make" target for creating and/or modifying the
				wire tracks in the unit tile.

SYNTAX
	make -f rm_setup/Makefile_gds_in wire_tracks


ARGUMENTS
	You may specify the configuration file to be used with the argument:

	FLOW_CONFIG=<your configuration file path/name>


VARIABLES
	This target uses the following flow variables from the configuration
	file:
		$ref_lib		Path where the working library is
					stored

		$library_name		Name of the working library

		$metal1_pg_rail		Boolean - defines if the power rails
					are parallel to metal1

		$metal2_pg_rail		Boolean - defines if the power rails
					are parallel to metal2


DESCRIPTION
	This target does the following:

		1) Loads the specified configuration file (see the ARGUMENTS
		   section).

		2) Checks if there are any standard cells in the library. Exits
		   if not.

		3) Performs sanity checks on the required variables.

		4) Gets the routing pitches from the technology file.

		5) Defines wiretrack offsets and wiring directions using an
		   automated method.

		6) Provides an alternative manual method for defining offsets 
		   and directions (commented out by default).

	The wire tracks that are stored in the unit tile are used during
	floorplan creation to define the wire tracks of the design.

	It is important to define wire tracks that correspond with the pin
	locations, both horizontally and vertically. The metal offsets should
	be either zero (0.0) or 1/2 the metal pitch defined in the Milkyway
	technology file.

	It is an iterative process of changing the metal offsets and then
	checking the pins on track (running axgCheckWireTrack). This is done
	in the next target "check_wire_tracks". The setting that gives the
	fewest "Pins with no good access point on Grid (V&H)" and the fewest
	"Pins with no good access point on Ver-Grid" based on running
	axgCheckWireTrack is the best setting.

	You should also open the unitTile cell, display the wire tracks, and
	check that they line up as much as possible. This will speed up
	routing.

	The preferred routing direction of each layer is also defined in this
	step.

	The script offers two methods for defining the wire track offsets and
	directions:

		- Automated method: The technology file is queried for the
		  pitch of each of the routing layers, and an offset of 1/2
		  pitch is applied. The wiring direction is derived from the
		  two variables $metal1_pg_rail and $metal2_pg_rail; when
		  $metal1_pg_rail is "1", metal1 is horizontal, metal2 is
		  vertical, and so on.

		  The script evaluates the value $metal1_pg_rail to try to
		  determine if the standard cell uses a traditional rail
		  concept with the rails on the lowest metal layer (metal1), or
		  if the rails are on the second lowest layer (metal2). The
		  latter is sometimes referred to as the "NXT" technology.

		- Manual method: Here you have to enter the offset and
		  direction in the script. To activate it, you have to comment
		  out the automated section and remove the comments for the
		  manual section and modify the values.

	The script does not explicitly handle libraries with vertical rails.
	You will have to use the manual method in that case.


MESSAGES
	GDS CELL PREP FLOW INFO >> No standard cells in the library - skipping 
	step wire_tracks.

	This message simply tells you that since there are no standard cells in
	the library, the rest of this target is skipped.


	GDS CELL PREP FLOW WARNING >> Both metal1 and metal2 set as rail layers.
	                              Please verify the track directions in the 
	                              unit tile cell.

	You have set both the variables $metal1_pg_rail and $metal2_pg_rail to
	1. In this case, the script will assume metal1 to be horizontal and
	metal2 vertical. You should check the wiretracks in the unit tile cell,
	and you may have to use the manual method to set both metal1 and metal2
	to horizontal if that's what the library uses.


EXAMPLE
	Run the "wire_tracks" step with the default configuration file:

	make -f rm_setup/Makefile_gds_in wire_tracks

	Use a specific configuration file:

	make -f rm_setup/Makefile_gds_in wire_tracks FLOW_CONFIG=./config/lib_2_setup.tcl


