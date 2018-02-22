# StarRC Basic Flow Makefile

STARRC_EXEC        = $(STARXTRACT)
STARRC_LOGS_DIR    = $(CURDIR)/logs/starrc
STARRC_DUMP_DIR    = $(CURDIR)/dump/starrc
STARRC_REPORTS_DIR = $(CURDIR)/reports/starrc
STARRC_RESULTS_DIR = $(CURDIR)/results/starrc

# Export to bash shell to be obtained by Tcl scripts.
export STARRC_LOGS_DIR
export STARRC_REPORTS_DIR
export STARRC_RESULTS_DIR

# VPATH tells the gmake utility to create and look for the target touchfiles in
# a certain directory. You should not modify this variable.
VPATH = touchfiles

# --- #
# To be defined in a higher level Makefile
ITF_FILE          ?=
TLUPLUS_DIR       ?=
NXTGRD_DIR        ?=

STARXTRACT_TEMPLATE_RUNSET ?= $(CURDIR)/starrc_scripts/starxtract.template.runset
STARXTRACT_RUNSET          ?= $(STARRC_RESULTS_DIR)/starxtract.runset

ifneq ($(wildcard $(ITF_FILE)),)
  ITF_BASENAME = $(basename $(notdir $(ITF_FILE)))
endif

# --- #
# TLUPlus

MAX_TLUPLUS = max.tluplus
MIN_TLUPLUS = min.tluplus

max_tluplus: $(ITF_FILE)
	@rm -rf $(TLUPLUS_DIR)/*.TLUPlus
	@rm -rf $(TLUPLUS_DIR)/$(MAX_TLUPLUS)
	@echo "OPCOND MAX" > $(TLUPLUS_DIR)/$(MAX_TLUPLUS).format
	# This task may generate unknown errors in the end, which should not matter. Use '-' to supress this error.
	-cd $(TLUPLUS_DIR) && $(GRDGENXO) -itf2TLUPlus -i $(ITF_FILE) -f $(MAX_TLUPLUS).format -o $(MAX_TLUPLUS)
	touch $(VPATH)/$@

min_tluplus: $(ITF_FILE)
	@rm -rf $(TLUPLUS_DIR)/*.TLUPlus
	@rm -rf $(TLUPLUS_DIR)/$(MIN_TLUPLUS)
	@echo "OPCOND MIN" > $(TLUPLUS_DIR)/$(MIN_TLUPLUS).format
	# This task may generate unknown errors in the end, which should not matter. Use '-' to supress this error.
	-cd $(TLUPLUS_DIR) && $(GRDGENXO) -itf2TLUPlus -i $(ITF_FILE) -f $(MIN_TLUPLUS).format -o $(MIN_TLUPLUS)
	touch $(VPATH)/$@

tluplus:
ifneq ($(TLUPLUS_DIR),)
	mkdir -p $(TLUPLUS_DIR)
	make  max_tluplus
	make  min_tluplus
else
	$(error $(TLUPLUS_DIR) is not defined!)
endif
	touch $(VPATH)/$@

# --- #
# GRDGENXO

# Visualize ITF file as stacked layers.
itf_profiler: $(ITF_FILE)
	$(GRDGENXO) -profiler $(ITF_FILE) -jpg $(ITF_BASENAME).jpg

# Generage NXTGRD (New eXTraction Generic Regression Database) file for StarXtract.
nxtgrd: $(ITF_FILE)
	mkdir -p $(STARRC_REPORTS_DIR) $(STARRC_RESULTS_DIR) $(STARRC_LOGS_DIR)
ifneq ($(NXTGRD_DIR),)
	mkdir -p $(NXTGRD_DIR)
else
	$(error $(NXTGRD_DIR) is not defined!)
endif
	cd $(NXTGRD_DIR) && $(GRDGENXO) $(ITF_FILE)
	touch $(VPATH)/$@

# --- #
# StarXtract

# Build Runset Script
starxtract_runset:
	@mkdir -p $(STARRC_RESULTS_DIR)
	@cp $(STARXTRACT_TEMPLATE_RUNSET) $(STARXTRACT_RUNSET)
	@sed -i "s|^BLOCK.*|BLOCK: $(CEL)|"                                                         $(STARXTRACT_RUNSET)
	@sed -i "s|^MILKYWAY_DATABASE.*|MILKYWAY_DATABASE: $(CURDIR)/$(DESIGN_NAME)_mwlib|"         $(STARXTRACT_RUNSET)
	@sed -i "s|^TCAD_GRD_FILE.*|TCAD_GRD_FILE: $(NXTGRD_DIR)/$(ITF_BASENAME).nxtgrd|"           $(STARXTRACT_RUNSET)
	@sed -i "s|^MAPPING_FILE.*|MAPPING_FILE: $(TECH2ITF_MAP)|"                                  $(STARXTRACT_RUNSET)
	@sed -i "s|^COUPLE_TO_GROUND.*|COUPLE_TO_GROUND: $(RCXT_COUPLE_TO_GROUND)|"                 $(STARXTRACT_RUNSET)
	@sed -i "s|^NETLIST_FORMAT.*|NETLIST_FORMAT: $(RCXT_NETLIST_FORMAT)|"                       $(STARXTRACT_RUNSET)
ifeq ($(RCXT_NETLIST_FORMAT),SPEF)
	@sed -i "s|^NETLIST_FILE.*|NETLIST_FILE: $(STARRC_RESULTS_DIR)/$(DESIGN_NAME).$(CEL).spef|" $(STARXTRACT_RUNSET)
else ifeq ($(RCXT_NETLIST_FORMAT),SBPF)
	@sed -i "s|^NETLIST_FILE.*|NETLIST_FILE: $(STARRC_RESULTS_DIR)/$(DESIGN_NAME).$(CEL).sbpf|" $(STARXTRACT_RUNSET)
endif
	@sed -i "s|^STAR_DIRECTORY.*|STAR_DIRECTORY: $(STARRC_DUMP_DIR)|"                           $(STARXTRACT_RUNSET)

## Program Options
STARXTRACT_OPTIONS = -clean

# Perform parasitic RC extraction using StarXtract.
starxtract: nxtgrd starxtract_runset
	mkdir -p $(STARRC_LOGS_DIR) $(STARRC_DUMP_DIR) $(STARRC_REPORTS_DIR) $(STARRC_RESULTS_DIR)
	$(STARXTRACT) $(STARXTRACT_OPTIONS) $(STARXTRACT_RUNSET)
	touch $(VPATH)/$@

rcxt: starxtract

# --- #
# Graphical User Interface

starxtract_gui:
	$(STARXTRACT) -gui
