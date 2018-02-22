## ICC RM Makefile
## See README.* file for RM details

ICC_EXEC        = $(ICC) -64bit
ICC_LOGS_DIR    = $(CURDIR)/logs/icc
ICC_REPORTS_DIR = $(CURDIR)/reports/icc
ICC_RESULTS_DIR = $(CURDIR)/results/icc
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

##########################################################################################################################
# Flat floorplanning script execution section
# Execute "make dp" to run ICC Design Planning RM based on your common_setup.tcl, icc_setup.tcl
##########################################################################################################################

init_design_icc:
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_scripts/init_design_icc.tcl | tee -i $(ICC_LOGS_DIR)/init_design_icc.log
	touch $(VPATH)/$@

flat_dp: init_design_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_dp_scripts/flat_dp.tcl | tee -i $(ICC_LOGS_DIR)/flat_dp.log
	touch $(VPATH)/$@

dp: flat_dp
	touch $(VPATH)/$@

################################################################################################################
# ICC RM : netlist2gds script exection section
# Execute "make ic" to run IC Compiler based on your common_setup.tcl & icc_setup.tcl files
# If make dp has been run before, please pick one of the 8 created floorplans and fill that one in the
# variable ICC_FLOORPLAN_CEL in the icc_setup.tcl file
################################################################################################################


place_opt_icc: init_design_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_scripts/place_opt_icc.tcl |tee -i $(ICC_LOGS_DIR)/place_opt_icc.log
	touch $(VPATH)/$@

clock_opt_cts_icc: place_opt_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_scripts/clock_opt_cts_icc.tcl |tee -i $(ICC_LOGS_DIR)/clock_opt_cts_icc.log
	touch $(VPATH)/$@

clock_opt_psyn_icc: clock_opt_cts_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/clock_opt_psyn_icc.tcl |tee -i $(ICC_LOGS_DIR)/clock_opt_psyn_icc.log
	touch $(VPATH)/$@

clock_opt_route_icc: clock_opt_psyn_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/clock_opt_route_icc.tcl |tee -i $(ICC_LOGS_DIR)/clock_opt_route_icc.log
	touch $(VPATH)/$@

route_icc: clock_opt_route_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/route_icc.tcl |tee -i $(ICC_LOGS_DIR)/route_icc.log
	touch $(VPATH)/$@

route_opt_icc: route_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/route_opt_icc.tcl |tee -i $(ICC_LOGS_DIR)/route_opt_icc.log
	touch $(VPATH)/$@

chip_finish_icc: route_opt_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/chip_finish_icc.tcl |tee -i $(ICC_LOGS_DIR)/chip_finish_icc.log
	touch $(VPATH)/$@

metal_fill_icc: chip_finish_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/metal_fill_icc.tcl |tee -i $(ICC_LOGS_DIR)/metal_fill_icc.log
	touch $(VPATH)/$@

signoff_drc_icc: metal_fill_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/signoff_drc_icc.tcl |tee -i $(ICC_LOGS_DIR)/signoff_drc_icc.log
	touch $(VPATH)/$@

outputs_icc: signoff_drc_icc
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/outputs_icc.tcl |tee -i $(ICC_LOGS_DIR)/outputs_icc.log
	touch $(VPATH)/$@

ic: outputs_icc
	touch $(VPATH)/$@

################################################################################################################
# ICC RM : Eco flow
################################################################################################################
eco_icc:
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/eco_icc.tcl |tee -i $(ICC_LOGS_DIR)/eco_icc.log
	touch $(VPATH)/$@

eco: eco_icc
	touch $(VPATH)/$@

################################################################################################################
# ICC RM : Focal_opt flow
################################################################################################################
focal_opt_icc:
	mkdir -p $(ICC_REPORTS_DIR) $(ICC_RESULTS_DIR) $(ICC_LOGS_DIR)
	$(ICC_EXEC) $(ICC_OPTIONS) -f rm_icc_zrt_scripts/focal_opt_icc.tcl |tee -i $(ICC_LOGS_DIR)/focal_opt_icc.log
	touch $(VPATH)/$@

focal_opt: focal_opt_icc
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
clean_all:
	@echo ""
	@echo "Running make $@"
	rm -rf snapshot
	rm -rf *_map\.*
	rm -rf net.acts
	rm -rf *.attr
	rm -rf .zr*
	rm -rf Milkyway.cmd.*_*_*_*
	rm -rf Milkyway.log.*_*_*_*
	rm -rf \.vers*
	rm -rf port_mapping.*
	rm -rf *_port_map*
	rm -rf .tmp_*
	rm -rf .__tmp_*
	rm -rf icc_output.txt
	rm -rf icc_gui.output
	rm -rf command.log

clean:
	@echo
	@echo "Please explicitly specify the clean_target."
	@echo "Available Options:"
	@echo "  clean_all"
	@echo
