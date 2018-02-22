## ICC Hierarchical RM Makefile
## See README.* file for RM details

ICC_EXEC        = $(ICC) -64bit
ICC_LOGS_DIR    = $(CURDIR)/logs/icc_hier
ICC_REPORTS_DIR = $(CURDIR)/reports/icc_hier
ICC_RESULTS_DIR = $(CURDIR)/results/icc_hier
PNA_OUTPUT_DIR  = $(CURDIR)/pna_output

# Export to bash shell to be obtained by Tcl scripts.
export ICC_LOGS_DIR
export ICC_REPORTS_DIR
export ICC_RESULTS_DIR

# VPATH tells the gmake utility to create and look for the target touchfiles in
# a certain directory. You should not modify this variable.
VPATH = touchfiles

## Source Options
ICC_OPTIONS =

## Optional: Specify design library if you want backup step and clean step to use it.
# If this is set, it is supposed to be the same as MW_DESIGN_LIBRARY in icc_setup.tcl.
DESIGN_LIB = $(DESIGN_NAME)_mwlib

#################################################################################################################
# Script Execution Section
# Execute "make -f Makefile_hier hier_dp" to run ICC Hierarchical RM based on your common_setup.tcl, icc_setup.tcl
#################################################################################################################

init_design_odl:
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(OPTIONS) -f rm_icc_dp_scripts/init_design_odl.tcl | tee -i $(ICC_LOGS_DIR)/init_design_odl.log
	touch $(VPATH)/$@

create_plangroups_dp: init_design_odl
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_dp_scripts/create_plangroups_dp.tcl | tee -i $(ICC_LOGS_DIR)/create_plangroups_dp.log
	touch $(VPATH)/$@

create_odl_dp: create_plangroups_dp
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(OPTIONS) -f rm_icc_dp_scripts/create_odl_dp.tcl | tee -i $(ICC_LOGS_DIR)/create_odl_dp.log
	touch $(VPATH)/$@

routeability_on_plangroups_dp: create_odl_dp
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_dp_scripts/routeability_on_plangroups_dp.tcl | tee -i $(ICC_LOGS_DIR)/routeability_on_plangroups_dp.log
	touch $(VPATH)/$@

pin_assignment_budgeting_dp: routeability_on_plangroups_dp
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_dp_scripts/pin_assignment_budgeting_dp.tcl | tee -i $(ICC_LOGS_DIR)/pin_assignment_budgeting_dp.log
	touch $(VPATH)/$@

commit_dp: pin_assignment_budgeting_dp
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_dp_scripts/commit_dp.tcl | tee -i $(ICC_LOGS_DIR)/commit_dp.log
	touch $(VPATH)/$@

prepare_block_dp: commit_dp
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_dp_scripts/prepare_block_dp.tcl | tee -i $(ICC_LOGS_DIR)/prepare_block_dp.log
	touch $(VPATH)/$@

hier_dp: prepare_block_dp
	touch $(VPATH)/$@

#############################################################################################################################
# Utilities Section
#############################################################################################################################

## Backup
BACKUP = BACKUP.$(shell date "+%Y-%m-%d-%H-%M")
backup:
	@echo ""
	@echo "Making $(BACKUP)"
	rm -rf $(BACKUP)
	mkdir -p $(BACKUP)
	cp -rfL rm_*_scripts $(BACKUP)
	cp -rfL results $(BACKUP)
	cp -rfL reports $(BACKUP)
	cp -rfL rm_setup $(BACKUP)
	cp -rfL $(DESIGN_LIB) $(BACKUP)
	cp -rfL $(PNA_OUTPUT_DIR) $(BACKUP)

## Clean
#
## ICC Hierarchical RM-Info: "make clean_dp" does not remove the design library unless you have specified it with the DESIGN_LIB variable in Makefile"
clean_dp:
	@echo ""
	@echo "Running make $@"
	rm -rf *_map\.*
	rm -rf net.acts
	rm -rf *.attr
	rm -rf .zr*
	rm -rf Milkyway.cmd.*_*_*_*
	rm -rf Milkyway.log.*_*_*_*
	rm -rf .vers*
	rm -rf port_mapping.*

clean:
	@echo
	@echo "Please explicitly specify the clean_target."
	@echo "Available Options:"
	@echo "  clean_dp"
	@echo
