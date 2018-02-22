## DC Makefile

DC_EXEC        = $(DC) -64bit -topographical_mode
DC_LOGS_DIR    = $(CURDIR)/logs/dc
DC_REPORTS_DIR = $(CURDIR)/reports/dc
DC_RESULTS_DIR = $(CURDIR)/results/dc

# Export to bash shell to be obtained by Tcl scripts.
export DC_LOGS_DIR
export DC_REPORTS_DIR
export DC_RESULTS_DIR

# VPATH tells the gmake utility to create and look for the target touchfiles in
# a certain directory. You should not modify this variable.
VPATH = touchfiles

## Source Options
DC_OPTIONS =

################################################################################
# Design Compiler Tasks
################################################################################

synth:
	mkdir -p $(DC_REPORTS_DIR) $(DC_RESULTS_DIR) $(DC_LOGS_DIR)
	time $(DC_EXEC) $(DC_OPTIONS) -f rm_dc_scripts/dc.tcl | tee -i $(DC_LOGS_DIR)/$@.log
	touch $(VPATH)/$@
	@grep --color "^Error" $(DC_LOGS_DIR)/$@.log || true
	@grep --color "Complex logic will not be considered"  $(DC_LOGS_DIR)/$@.log || true
	@grep -B 3 --color "*** Presto compilation terminated" $(DC_LOGS_DIR)/$@.log || true
	@grep --color "unresolved references." $(DC_LOGS_DIR)/$@.log || true
	@grep --color "Cannot find the design" $(DC_LOGS_DIR)/$@.log || true
	@grep --color "undeclared symbol" $(DC_LOGS_DIR)/$@.log || true

# Alias
synthesis: synth
