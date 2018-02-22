## Formality Makefile

FM_EXEC        = $(FM) -64bit
FM_LOGS_DIR    = $(CURDIR)/logs/fm
FM_REPORTS_DIR = $(CURDIR)/reports/fm
FM_RESULTS_DIR = $(CURDIR)/results/fm

# Export to bash shell to be obtained by Tcl scripts.
export FM_LOGS_DIR
export FM_REPORTS_DIR
export FM_RESULTS_DIR

# VPATH tells the gmake utility to create and look for the target touchfiles in
# a certain directory. You should not modify this variable.
VPATH = touchfiles

## Source Options
FM_OPTIONS =

################################################################################
# Formality Tasks
################################################################################

# Verify equivalence between RTL source design and Design Compiler mapped design.
#
# RTL to gate-level netlist (mapped)
fm_r2g:
	mkdir -p $(FM_REPORTS_DIR) $(FM_RESULTS_DIR) $(FM_LOGS_DIR)
	@# FM_LIB_NAME is read in fm.tcl as an environment variable.
	FM_LIB_NAME=$@ $(FM_EXEC) $(FM_OPTIONS) -file rm_dc_scripts/fm.tcl | tee -i $(FM_LOGS_DIR)/$@.log
	touch $(VPATH)/$@

# Verify equivalence between Design Compiler mapped design and layout netlist.
#
# Gate-level netlist (mapped) to layout netlist
fm_g2l:
	mkdir -p $(FM_REPORTS_DIR) $(FM_RESULTS_DIR) $(FM_LOGS_DIR)
	@# FM_LIB_NAME is read in fm.tcl as an environment variable.
	FM_LIB_NAME=$@ $(FM_EXEC) $(FM_OPTIONS) -file rm_icc_scripts/fm.tcl | tee -i $(FM_LOGS_DIR)/$@.log
	touch $(VPATH)/$@
