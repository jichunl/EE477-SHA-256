# StarRC Basic Flow Makefile
STARRC_EXEC = $(STARXTRACT)

# Export to bash shell to be obtained by Tcl scripts.
export STARRC_REPORTS_DIR = $(CURDIR)/reports/starrc
export STARRC_RESULTS_DIR = $(CURDIR)/results/starrc

# VPATH tells the gmake utility to create and look for the target touchfiles in
# a certain directory. You should not modify this variable.
VPATH = touchfiles

# --- #
NXTGRD_DIR = $(STARRC_RESULTS_DIR)/nxtgrd

STAR_CMD_GATE_TEMPLATE = $(CURDIR)/rm_starrc_scripts/star_cmd_gate.template
STAR_CMD_GATE          = star_cmd_gate

#ifneq ($(wildcard $(ITF_FILE)),)
#  ITF_BASENAME = $(basename $(notdir $(ITF_FILE)))
#endif

## --- #
## TLUPlus
#
#MAX_TLUPLUS = max.tluplus
#MIN_TLUPLUS = min.tluplus
#
#max_tluplus: $(ITF_FILE)
#	@rm -rf $(TLUPLUS_DIR)/*.TLUPlus
#	@rm -rf $(TLUPLUS_DIR)/$(MAX_TLUPLUS)
#	@echo "OPCOND MAX" > $(TLUPLUS_DIR)/$(MAX_TLUPLUS).format
#	# This task may generate unknown errors in the end, which should not matter. Use '-' to supress this error.
#	-cd $(TLUPLUS_DIR) && $(GRDGENXO) -itf2TLUPlus -i $(ITF_FILE) -f $(MAX_TLUPLUS).format -o $(MAX_TLUPLUS)
#	touch $(VPATH)/$@
#
#min_tluplus: $(ITF_FILE)
#	@rm -rf $(TLUPLUS_DIR)/*.TLUPlus
#	@rm -rf $(TLUPLUS_DIR)/$(MIN_TLUPLUS)
#	@echo "OPCOND MIN" > $(TLUPLUS_DIR)/$(MIN_TLUPLUS).format
#	# This task may generate unknown errors in the end, which should not matter. Use '-' to supress this error.
#	-cd $(TLUPLUS_DIR) && $(GRDGENXO) -itf2TLUPlus -i $(ITF_FILE) -f $(MIN_TLUPLUS).format -o $(MIN_TLUPLUS)
#	touch $(VPATH)/$@
#
#tluplus:
#ifneq ($(TLUPLUS_DIR),)
#	mkdir -p $(TLUPLUS_DIR)
#	make  max_tluplus
#	make  min_tluplus
#else
#	$(error $(TLUPLUS_DIR) is not defined!)
#endif
#	touch $(VPATH)/$@

# --- #
# GRDGENXO

# Visualize ITF file as stacked layers.
#itf_profiler: $(ITF_FILE)
#	@mkdir -p $(NXTGRD_DIR)
#	cd $(NXTGRD_DIR) && $(GRDGENXO) -profiler $(ITF_FILE) -jpg $(ITF_BASENAME).jpg
#	touch $(VPATH)/$@

# Generage NXTGRD (New eXTraction Generic Regression Database) file for StarXtract.
nxtgrd: $(ITF_FILE)
	@mkdir -p $(NXTGRD_DIR)
	cd $(NXTGRD_DIR) && $(GRDGENXO) -i $(ITF_FILE) -o tech.nxtgrd
	touch $(VPATH)/$@

# --- #
# StarXtract

# Build Runset Script
star_cmd_gate_runset:
	@mkdir -p $(STARRC_REPORTS_DIR)
	@mkdir -p $(STARRC_REPORTS_DIR)/max
	@mkdir -p $(STARRC_REPORTS_DIR)/min
	@mkdir -p $(STARRC_REPORTS_DIR)/typ
	@cp $(STAR_CMD_GATE_TEMPLATE) $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@sed -i "s|^BLOCK.*|BLOCK: $(CEL)|"                                                             $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@sed -i "s|^MILKYWAY_DATABASE.*|MILKYWAY_DATABASE: $(CURDIR)/$(DESIGN_NAME)_mwlib|"             $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@sed -i "s|^TCAD_GRD_FILE.*|TCAD_GRD_FILE: $(NXTGRD_FILE)|"                                     $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@sed -i "s|^MAPPING_FILE.*|MAPPING_FILE: $(TECH2ITF_MAP)|"                                      $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@sed -i "s|^OPERATING_TEMPERATURE.*|OPERATING_TEMPERATURE: 125|"                                $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@sed -i "s|^NETLIST_FILE.*|NETLIST_FILE: $(STARRC_RESULTS_DIR)/$(DESIGN_NAME).$(CEL).max.spef|" $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@sed -i "s|^STAR_DIRECTORY.*|STAR_DIRECTORY: $(STARRC_REPORTS_DIR)/max|"                        $(STARRC_REPORTS_DIR)/max/$(STAR_CMD_GATE)
	@cp $(STAR_CMD_GATE_TEMPLATE) $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@sed -i "s|^BLOCK.*|BLOCK: $(CEL)|"                                                             $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@sed -i "s|^MILKYWAY_DATABASE.*|MILKYWAY_DATABASE: $(CURDIR)/$(DESIGN_NAME)_mwlib|"             $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@sed -i "s|^TCAD_GRD_FILE.*|TCAD_GRD_FILE: $(NXTGRD_FILE)|"                                     $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@sed -i "s|^MAPPING_FILE.*|MAPPING_FILE: $(TECH2ITF_MAP)|"                                      $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@sed -i "s|^OPERATING_TEMPERATURE.*|OPERATING_TEMPERATURE: 0|"                                  $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@sed -i "s|^NETLIST_FILE.*|NETLIST_FILE: $(STARRC_RESULTS_DIR)/$(DESIGN_NAME).$(CEL).min.spef|" $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@sed -i "s|^STAR_DIRECTORY.*|STAR_DIRECTORY: $(STARRC_REPORTS_DIR)/min|"                        $(STARRC_REPORTS_DIR)/min/$(STAR_CMD_GATE)
	@cp $(STAR_CMD_GATE_TEMPLATE) $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	@sed -i "s|^BLOCK.*|BLOCK: $(CEL)|"                                                             $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	@sed -i "s|^MILKYWAY_DATABASE.*|MILKYWAY_DATABASE: $(CURDIR)/$(DESIGN_NAME)_mwlib|"             $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	@sed -i "s|^TCAD_GRD_FILE.*|TCAD_GRD_FILE: $(NXTGRD_FILE)|"                                     $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	@sed -i "s|^MAPPING_FILE.*|MAPPING_FILE: $(TECH2ITF_MAP)|"                                      $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	@sed -i "s|^OPERATING_TEMPERATURE.*|OPERATING_TEMPERATURE: 25|"                                 $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	@sed -i "s|^NETLIST_FILE.*|NETLIST_FILE: $(STARRC_RESULTS_DIR)/$(DESIGN_NAME).$(CEL).typ.spef|" $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	@sed -i "s|^STAR_DIRECTORY.*|STAR_DIRECTORY: $(STARRC_REPORTS_DIR)/typ|"                        $(STARRC_REPORTS_DIR)/typ/$(STAR_CMD_GATE)
	touch $(VPATH)/$@

## Program Options
STARXTRACT_OPTIONS = -clean

# Perform parasitic RC extraction using StarXtract.
starxtract: star_cmd_gate_runset
	@mkdir -p $(STARRC_RESULTS_DIR)
	cd $(STARRC_REPORTS_DIR)/max && $(STARRC_EXEC) $(STARXTRACT_OPTIONS) $(STAR_CMD_GATE)
	cd $(STARRC_REPORTS_DIR)/min && $(STARRC_EXEC) $(STARXTRACT_OPTIONS) $(STAR_CMD_GATE)
	cd $(STARRC_REPORTS_DIR)/typ && $(STARRC_EXEC) $(STARXTRACT_OPTIONS) $(STAR_CMD_GATE)
	touch $(VPATH)/$@

rcxt: starxtract

# --- #
# Graphical User Interface
starrc_gui:
	$(STARRC_EXEC) -gui
