# PrimeTime Makefile

PT_EXEC        = $(PRIMETIME)
PT_LOGS_DIR    = $(CURDIR)/logs/pt
PT_REPORTS_DIR = $(CURDIR)/reports/pt
PT_RESULTS_DIR = $(CURDIR)/results/pt

# Export to bash shell to be obtained by Tcl scripts.
export PT_LOGS_DIR
export PT_REPORTS_DIR
export PT_RESULTS_DIR

# VPATH tells the gmake utility to create and look for the target touchfiles in
# a certain directory. You should not modify this variable.
VPATH = touchfiles

## Source Options
PT_OPTIONS =

################################################################################
# PrimeTime Tasks
################################################################################

# MBT added sed scripts to filter .sdf file because VCS did not like \[number\] in SDF

pt_static_timing:
	mkdir -p $(PT_REPORTS_DIR) $(PT_RESULTS_DIR) $(PT_LOGS_DIR)
	PT_MODE=STA CORNER_CASE=MAX $(PT_EXEC) $(PT_OPTIONS) -f rm_pt_scripts/pt.tcl | tee -i $(PT_LOGS_DIR)/$@.max.log
	PT_MODE=STA CORNER_CASE=MIN $(PT_EXEC) $(PT_OPTIONS) -f rm_pt_scripts/pt.tcl | tee -i $(PT_LOGS_DIR)/$@.min.log
	PT_MODE=STA CORNER_CASE=TYP $(PT_EXEC) $(PT_OPTIONS) -f rm_pt_scripts/pt.tcl | tee -i $(PT_LOGS_DIR)/$@.typ.log
	@echo "MBT fixing these lines with sed (removing backslashes):"
	sed -n -r '/\\\[([0-9]+)\\\]/p' $(PT_RESULTS_DIR)/*.sdf
	sed -i -r 's/\\\[([0-9]+)\\\]/\[\1\]/g' $(PT_RESULTS_DIR)/*.sdf
	touch $(VPATH)/$@
ptst: pt_static_timing

pt_signal_integrity:
	mkdir -p $(PT_REPORTS_DIR) $(PT_RESULTS_DIR) $(PT_LOGS_DIR)
	PT_MODE=SI CORNER_CASE=MAX $(PT_EXEC) $(PT_OPTIONS) -f rm_pt_scripts/pt.tcl | tee -i $(PT_LOGS_DIR)/$@.max.log
	PT_MODE=SI CORNER_CASE=MIN $(PT_EXEC) $(PT_OPTIONS) -f rm_pt_scripts/pt.tcl | tee -i $(PT_LOGS_DIR)/$@.min.log
	PT_MODE=SI CORNER_CASE=TYP $(PT_EXEC) $(PT_OPTIONS) -f rm_pt_scripts/pt.tcl | tee -i $(PT_LOGS_DIR)/$@.typ.log
	@echo "MBT fixing these lines with sed (removing backslashes):"
	sed -n -r '/\\\[([0-9]+)\\\]/p' $(PT_RESULTS_DIR)/*.sdf
	sed -i -r 's/\\\[([0-9]+)\\\]/\[\1\]/g'  $(PT_RESULTS_DIR)/*.sdf
	touch $(VPATH)/$@
ptsi: pt_signal_integrity
