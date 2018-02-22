################################################################################
# Run Commands for CAD Tools                                                   #
################################################################################

# Generic run command
%.run:
	$*

# Synopsys tools
dc:
	$(DC)

dc64:
	$(DC) -64bit

fm:
	$(FM)

fm64:
	$(FM) -64bit

dc_topo:
	$(DC) -topographical_mode

dve64:
	$(VCS_BIN)/dve -full64

# not sure about this "-galaxy: galaxy mode"; seen in some reference scripts;
mw:
	$(MW) -galaxy -nogui -nullDisplay -tcl

mw_gui:
	$(MW) -galaxy

mw_help:
	-$(MW) -galaxy -nogui -nullDisplay -help

icc:
	$(ICC) -no_gui

icc64:
	$(ICC) -64bit -no_gui

icv:
	$(ICV)

icv64:
	$(ICV64)

primerail:
	$(PRIMERAIL)


# If you install only the binaries for the RHEL-64 platform and want to run
# PrimeTime on a 64-bit system, you must invoke PrimeTime with the -64 option,
# as shown in the following example:
#
# % pt_shell -64
# % primetime -64
# % vcs2saif -64
#
# https://solvnet.synopsys.com/retrieve/032370.html
primetime:
	$(PRIMETIME) -64
pt: primetime

calibredrv:
	$(CALIBREDRV)

icc_help:
	-$(ICC) -no_gui -no_log -help
	@echo
	@echo "Info: The Error about [$@] can be ignored."

# Xilinx tools
ise64:
	. /gro/Xilinx/14.2/ISE_DS/settings64.sh
	$(ISE64)

xps64:
	. /gro/Xilinx/14.2/ISE_DS/settings64.sh
	XILINX=/gro/Xilinx/14.2/ISE_DS/ISE $(XPS64)

################################################################################
# Frequently Used CAD Tasks                                                    #
################################################################################

ifeq ($(wildcard $(DESIGN_NAME)_mwlib/CEL),)
  LATEST_CEL =
else
  LATEST_CEL = $(shell ls $(DESIGN_NAME)_mwlib/CEL/ -t | head -1 | awk -F ':' '{print $$1}')
endif
CEL ?= $(LATEST_CEL)

SWAPWITH ?= $(shell ls -t | grep BACKUP | head -1)

# Open DDC in Design Compiler
dc_open_ddc:
	@echo "source ./rm_setup/dc_setup.tcl"                        > dc_open_ddc.tcl
	@echo "read_ddc \$$DC_RESULTS_DIR/\$$DESIGN_NAME.mapped.ddc" >> dc_open_ddc.tcl
	@echo "set_host_options -max_cores \$$USE_NUM_CORES"         >> dc_open_ddc.tcl
	@echo "link"                                                 >> dc_open_ddc.tcl
	$(DC) -64bit -f dc_open_ddc.tcl

# Open a specified CEL of current design library in IC Compiler
icc_open_cel:
	@echo "source ./rm_setup/icc_setup.tcl"               > icc_open_cel.tcl
	@echo "set mw_cel_to_open \"$(CEL)\""                >> icc_open_cel.tcl
ifeq ($(LIB),)
	@echo "open_mw_lib \$$MW_DESIGN_LIBRARY"             >> icc_open_cel.tcl
else
	@echo "open_mw_lib $(LIB)"                           >> icc_open_cel.tcl
endif
	@echo "open_mw_cel \$$mw_cel_to_open"                >> icc_open_cel.tcl
	@echo "set_host_options -max_cores \$$USE_NUM_CORES" >> icc_open_cel.tcl
	@echo "link"                                         >> icc_open_cel.tcl
	$(ICC) -64bit -no_gui -f icc_open_cel.tcl

# Remove a specified CEL from current design library
icc_remove_cel:
	@echo "source ./rm_setup/icc_setup.tcl"                            > icc_remove_cel.tcl
	@echo "set mw_cel_to_remove \"$(CEL)\""                           >> icc_remove_cel.tcl
	@echo "open_mw_lib \$$MW_DESIGN_LIBRARY"                          >> icc_remove_cel.tcl
	@echo "remove_mw_cel -all_versions -all_view \$$mw_cel_to_remove" >> icc_remove_cel.tcl
	@echo "exit"                                                      >> icc_remove_cel.tcl
	$(ICC) -64bit -no_gui -f icc_remove_cel.tcl

# Open a specified CEL of current design library in PrimeRail
pr_open_cel:
	@echo "source ./rm_setup/pr_setup.tcl"                                    > pr_open_cel.tcl
	@echo "set mw_cel_to_open \"$(CEL)\""                                    >> pr_open_cel.tcl
ifeq ($(LIB),)
	@echo "open_mw_lib \$$MW_DESIGN_LIBRARY"                                 >> pr_open_cel.tcl
	@echo "convert_mw_lib \$$MW_DESIGN_LIBRARY -cell_name \$$mw_cel_to_open" >> pr_open_cel.tcl
else
	@echo "open_mw_lib $(LIB)"                                               >> pr_open_cel.tcl
	@echo "convert_mw_lib $(LIB) -cell_name \$$mw_cel_to_open"               >> pr_open_cel.tcl
endif
	@echo "open_mw_cel \$$mw_cel_to_open"                                    >> pr_open_cel.tcl
	@echo "set_host_options -max_cores \$$USE_NUM_CORES"                     >> pr_open_cel.tcl
	$(PRIMERAIL) -file pr_open_cel.tcl

ifeq ($(wildcard $(DESIGN_NAME)_mwlib/CEL),)
  LATEST_PT_SESSION =
else
  LATEST_PT_SESSION = $(shell ls $(PT_RESULTS_DIR) -t | head -1 | awk -F ':' '{print $$1}')
endif
SESS ?= $(LATEST_PT_SESSION)

# Open a saved session in PrimeTime
pt_open_sess:
	@echo "restore_session $(PT_RESULTS_DIR)/$(SESS)"                         > pt_open_sess.tcl
	$(PRIMETIME) -f pt_open_sess.tcl

# List all CELs in current design library in modified-time order.
lscel:
	@ls $(DESIGN_NAME)_mwlib/CEL/ -tr

# Swap current design library with the one specified by SWAPWITH.
# By default SWAPWITH is set to the latest BACKUP.
swaplib:
ifeq ($(wildcard design_lib_swapped),)
  ifeq ($(SWAPWITH),)
		$(error SWAPWITH value is missing!)
  else
		$(info Swapping $(DESIGN_NAME)_mwlib and $(SWAPWITH)/$(DESIGN_NAME)_mwlib.)
		@mv $(DESIGN_NAME)_mwlib $(DESIGN_NAME)_mwlib_swap
		@ln -sf $(SWAPWITH)/$(DESIGN_NAME)_mwlib ./
		@touch design_lib_swapped
  endif
else
	$(info Swapping $(SWAPWITH)/$(DESIGN_NAME)_mwlib and $(DESIGN_NAME)_mwlib.)
	@rm -f $(DESIGN_NAME)_mwlib
	@rm -f design_lib_swapped
	@mv $(DESIGN_NAME)_mwlib_swap $(DESIGN_NAME)_mwlib
endif

%.echo:
	@echo '$*=$($*)'
