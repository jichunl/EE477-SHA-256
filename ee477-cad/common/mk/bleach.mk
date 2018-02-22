# The "bleach_something" rules are created to perform deeper and finer-grained
# cleaning tasks than Synopsys' reference scripts do in the current working
# area. For example the design CEL views at different physical design stages
# could be removed before re-generate them. It also supports removing of one
# specific stage only, for instance "make bleach_route" only removes the route
# CEL and relevant generated files.
#
# Having the "bleach" naming is also to work around many pre-defined "clean"
# rules in Synopsys' reference scripts, that are not changed a lot so as to
# have a close tracking of the reference methodologies. It may cause conflicts
# and confusion if clean rules are re-defined here.

# This Makefile depends on the following variables to work properly.
#   Cellname Variables defined in icc_setup.tcl
#     Not obtainable here, the same Cellnames are used in bleach rules.
#   VPATH, ICC_RESULTS_DIR, ICC_REPORTS_DIR, ICC_LOGS_DIR, DESIGN_LIB, defined in icc.mk/icc_zrt.mk/icc_hier.mk files.
#     Obtainable by including icc.mk/icc_zrt.mk/icc_hier.mk before this bleach.mk file.

# MBT 9/8/2016 per Tutu's email add guards for undefined variables and rm -rf
# Technically I believe all that is necessary is to replace rm -rf <VAR>/*
# with rm -rf <VAR> and mkdir -p <VAR>. However, I have added guards to
# variables are used for RM to raise awareness of this issue when people
# edit the makefile.

ifeq ($(VPATH),)
$(error VPATH must be defined)
endif

ifeq ($(ICC_LOGS_DIR),)
$(error ICC_LOGS_DIR must be defined)
endif

ifeq ($(ICC_REPORTS_DIR),)
$(error ICC_REPORTS_DIR must be defined)
endif

ifeq ($(ICC_RESULTS_DIR),)
$(error ICC_RESULTS_DIR must be defined)
endif

ifeq ($(LIBPREP_LOGS_DIR),)
$(error LIBPREP_LOGS_DIR not defined)
endif

bleach:
	@echo
	@echo "To avoid regret in the next few minutes, you must explicitly specify the bleach_target."
	@echo
	@echo "Run \"make help\" or \"make help_bleach\" to see available options."
	@echo

bleach_ip:
	@echo
	@echo "Running make $@:"
	rm -f $(VPATH)/ip
	rm -f $(VPATH)/*.extract_ram
	@echo

bleach_db:
	@echo
	@echo "Running make $@:"
	rm -rf $(DESIGN_NAME)_dblib
	rm -f $(VPATH)/db
	@echo

bleach_%.libprep:
	@echo
	@echo "Running make bleach_$*.mwlib:"
	rm -rf $(VPATH)/$*.create_ref_libs
	rm -rf $(VPATH)/$*.read_lef
	rm -rf $(VPATH)/$*.smash
	rm -rf $(VPATH)/$*.set_port_types
	rm -rf $(VPATH)/$*.bpv
	rm -rf $(VPATH)/$*.pr_bdry
	rm -rf $(VPATH)/$*.multi_height
	rm -rf $(VPATH)/$*.wire_tracks
	rm -rf $(VPATH)/$*.check_wire_tracks
	rm -rf $(VPATH)/$*.diode_ports
	rm -rf $(VPATH)/$*.lib_db
	rm -rf $(VPATH)/$*.read_final_gds
	rm -rf $(VPATH)/$*.extract_antenna
	rm -rf $(VPATH)/$*.check_lib
	rm -rf $(VPATH)/$*.complete
	rm -rf $(VPATH)/$*.libprep
	rm -rf $(LIBPREP_LOGS_DIR)/$*.*
	rm -rf $(CURDIR)/$**.defineVarRoute.tcl
	rm -rf $(CURDIR)/$**.site_def
	rm -rf $(CURDIR)/ref_data/mwlib/$*.*
	@echo

bleach_memgen:
	@echo
	@echo "Running make $@:"
	rm -rf $(MEMORY_BUILD_DIR)
	rm -rf $(VPATH)/memgen
	@echo
	

bleach_synth:
	@echo
	@echo "Running make $@:"
	rm -rf command.log
	rm -rf synopsys_cache
	rm -rf sverilog_filelist_dc.txt
	rm -rf $(DESIGN_NAME)_dclib
	rm -rf $(DC_LOGS_DIR)
	rm -rf $(DC_RESULTS_DIR)
	rm -rf $(DC_REPORTS_DIR)
	rm -rf $(VPATH)/synth
	@echo

bleach_netlist: bleach_db bleach_synth
	@echo
	@echo "Running make $@:"
	rm -rf $(VPATH)/netlist
	@echo

bleach_mwlib:
	@echo
	@echo "Running make $@:"
	rm -rf $(VPATH)/*.create_ref_libs
	rm -rf $(VPATH)/*.read_lef
	rm -rf $(VPATH)/*.smash
	rm -rf $(VPATH)/*.set_port_types
	rm -rf $(VPATH)/*.bpv
	rm -rf $(VPATH)/*.pr_bdry
	rm -rf $(VPATH)/*.multi_height
	rm -rf $(VPATH)/*.wire_tracks
	rm -rf $(VPATH)/*.check_wire_tracks
	rm -rf $(VPATH)/*.diode_ports
	rm -rf $(VPATH)/*.lib_db
	rm -rf $(VPATH)/*.read_final_gds
	rm -rf $(VPATH)/*.extract_antenna
	rm -rf $(VPATH)/*.check_lib
	rm -rf $(VPATH)/*.complete
	rm -rf $(VPATH)/*.libprep
	rm -rf $(LIBPREP_LOGS_DIR)
	rm -rf $(CURDIR)/*.defineVarRoute.tcl
	rm -rf $(CURDIR)/*.site_def
	rm -rf $(CURDIR)/ref_data/mwlib
	rm -f touchfiles/mwlib
	@echo

bleach_tluplus:
	@echo
	@echo "Running make $@:"
ifeq ($(TLUPLUS_DIR),)
	echo TLUPLUS_DIR not defined
else
	rm -rf $(TLUPLUS_DIR)
endif
	rm -rf $(VPATH)/max_tluplus
	rm -rf $(VPATH)/min_tluplus
	rm -rf $(VPATH)/tluplus
	@echo

bleach_nxtgrd:
	@echo
	@echo "Running make $@:"
ifeq ($(NXTGRD_DIR),)
	echo NXTGRD_DIR not defined
else
	rm -rf $(NXTGRD_DIR)
endif
	rm -rf $(VPATH)/nxtgrd
	@echo

bleach_starxtract:
	@echo
	@echo "Running make $@:"
ifeq ($(STARRC_LOGS_DIR),)
	echo STARRC_LOGS_DIR not defined
else
	rm -rf $(STARRC_LOGS_DIR)
endif
ifeq ($(STARRC_DUMP_DIR),)
	echo STARRC_DUMP_DIR not defined
else
	rm -rf $(STARRC_DUMP_DIR)
endif

ifeq ($(STARRC_RESULTS_DIR),)
	echo STARRC_RESULTS_DIR not defined
else
	rm -rf $(STARRC_RESULTS_DIR)
endif
ifeq ($(STARRC_REPORTS_DIR),)
	echo STARRC_REPORTS_DIR not defined
else
	rm -rf $(STARRC_REPORTS_DIR)
endif
	rm -rf $(VPATH)/star_cmd_gate_runset
	rm -rf $(VPATH)/starxtract
	@echo
bleach_rcxt: bleach_starxtract

# General bleach rule to remove physical design touchfiles, logs, and CEL views.
# Some special targets for example "bleach_floorplan" is defined separately.
#
# FIXME: Each physical design target may generate reports/reports of various names in $(ICC_RESULTS_DIR).
#        They will have to be added to different clean/bleach rules.
bleach_%_icc:
	@echo
	@echo "Running make bleach_$*:"
	make icc_remove_cel CEL=$*
	rm -rf $(VPATH)/$*
	rm -rf $(VPATH)/$*_icc
	rm -rf $(ICC_RESULTS_DIR)/dump.$*
	rm -rf $(ICC_RESULTS_DIR)/$(DESIGN_NAME).$*.*
	rm -rf $(ICC_REPORTS_DIR)/$*.*
	rm -rf $(ICC_LOGS_DIR)/$*_icc.log
	rm -rf $(DESIGN_NAME)_mwlib/CEL/$*:*
	@echo

bleach_init_design:
	@echo
	@echo "Running make $@:"
	@make --no-print-directory bleach_init_design_icc
	@echo
#
# Bleach rule to remove floorplanning touchfiles, logs, and CEL views.
bleach_floorplan:
	@echo
	@echo "Running make $@:"
	make icc_remove_cel CEL="floorplan* flatdp*"
	rm -f $(VPATH)/flat_dp
	rm -f $(VPATH)/floorplan
	rm -rf $(ICC_RESULTS_DIR)/dump.floorplan
	rm -rf $(ICC_RESULTS_DIR)/$(DESIGN_NAME).floorplan.*
	rm -rf $(ICC_LOGS_DIR)/flat_dp.log
	rm -rf $(DESIGN_NAME)_mwlib/CEL/floorplan:*
	rm -rf $(DESIGN_NAME)_mwlib/CEL/flat_dp*
	rm -rf scripts/icc/copied
	@echo
#
bleach_place_opt:
	@make --no-print-directory bleach_place_opt_icc
#
bleach_clock_opt_cts:
	@make --no-print-directory bleach_clock_opt_cts_icc
bleach_clock_opt_psyn:
	@make --no-print-directory bleach_clock_opt_psyn_icc
bleach_clock_opt_route:
	@make --no-print-directory bleach_clock_opt_route_icc
bleach_clock_opt: bleach_clock_opt_cts bleach_clock_opt_psyn bleach_clock_opt_route
	rm -rf $(VPATH)/clock_opt
#
bleach_route:
	@make --no-print-directory bleach_route_icc
bleach_route_opt:
	@make --no-print-directory bleach_route_opt_icc
#
bleach_chip_finish:
	@make --no-print-directory bleach_chip_finish_icc
#
bleach_metal_fill:
	@make --no-print-directory bleach_metal_fill_icc
#
bleach_finish_design:
	@echo
	@echo "Running make $@:"
	make icc_remove_cel CEL="finish_design"
	rm -rf $(VPATH)/outputs
	rm -rf $(VPATH)/outputs_icc
	rm -rf $(VPATH)/finish_design
	rm -rf $(ICC_LOGS_DIR)/outputs_icc.log
	rm -rf $(DESIGN_NAME)_mwlib/CEL/finish_design*
	@echo

bleach_layout:
	@echo
	@echo "Running make $@:"
	rm -rf $(VPATH)/{init_design*,floorplan*,flat_dp*,place_opt*,clock_opt*,route*}
	rm -rf design_lib_swapped
	rm -rf $(ICC_RESULTS_DIR)
	rm -rf $(ICC_REPORTS_DIR)
	mkdir -p $(ICC_REPORTS_DIR)
	rm -rf $(ICC_LOGS_DIR)
	mkdir -p $(ICC_LOGS_DIR)
	rm -rf legalizer_debug_plots snapshot pna_output
	rm -rf icc_open_cel.tcl
	rm -rf pr_open_cel.tcl
	rm -rf $(DESIGN_NAME)_mwlib
	@echo

bleach_pt:
	@echo
	@echo "Running make $@:"
ifeq ($(PT_LOGS_DIR),)
	echo PT_LOGS_DIR not defined
else
	rm -rf $(PT_LOGS_DIR)
endif
ifeq ($(PT_RESULTS_DIR),)
	echo PT_RESULTS_DIR not defined
else
	rm -rf $(PT_RESULTS_DIR)
endif
ifeq ($(PT_REPORTS_DIR),)
	echo PT_REPORTS_DIR not defined
else
	rm -rf $(PT_REPORTS_DIR)
endif
	rm -rf $(VPATH)/pt*
	@echo

bleach_fm_r2g:
	@echo
	@echo "Running make $@:"
	rm -rf fm_shell_command.log
	rm -rf formality.log
	rm -rf sverilog_filelist_fm.txt
	rm -rf $(FM_RESULTS_DIR)/fm_r2g
	rm -rf $(FM_REPORTS_DIR)/fm_r2g
	rm -rf $(VPATH)/fm_r2g
	@echo

bleach_fm_all: bleach_fm_r2g
	@echo
	@echo "Running make $@:"
	rm -rf formality_svf
ifeq ($(FM_RESULTS_DIR),)
	echo FM_RESULTS_DIR not defined
else
	rm -rf $(FM_RESULTS_DIR)
endif
ifeq ($(FM_REPORTS_DIR),)
	echo FM_REPORTS_DIR not defined
else
	rm -rf $(FM_REPORTS_DIR)
endif
	rm -rf $(VPATH)/fm_*
	@echo

bleach_calibre_gds_merge:
ifeq ($(CALIBRE_MERGE_RUN_DIR),)
	echo CALIBRE_MERGE_RUN_DIR must be defined
else
	rm -rf $(CALIBRE_MERGE_RUN_DIR)
	mkdir -p $(CALIBRE_MERGE_RUN_DIR)
endif
	rm -rf $(VPATH)/calibre_gds_merge*

bleach_calibre_drc:
ifeq ($(CALIBRE_DRC_RUN_DIR),)
	echo CALIBRE_DRC_RUN_DIR not defined
else
	rm -rf $(CALIBRE_DRC_RUN_DIR)
	mkdir -p $(CALIBRE_DRC_RUN_DIR)
endif
	rm -rf $(VPATH)/calibre_drc*

bleach_calibre_dmi:
ifeq ($(CALIBRE_DMI_RUN_DIR),)
	echo CALIBRE_DMI_RUN_DIR not defined
else
	rm -rf $(CALIBRE_DMI_RUN_DIR)
	mkdir -p $(CALIBRE_DMI_RUN_DIR)
endif
	rm -rf $(VPATH)/calibre_dmi*

bleach_calibre_lvs:
ifeq ($(CALIBRE_LVS_RUN_DIR),)
	echo CALIBRE_LVS_RUN_DIR not defined
else
	rm -rf $(CALIBRE_LVS_RUN_DIR)
	mkdir -p $(CALIBRE_LVS_RUN_DIR)
endif
	rm -rf $(VPATH)/calibre_lvs*

# Remove all symbolic links and generated files
bleach_all: bleach_calibre_dmi bleach_calibre_drc bleach_layout bleach_mwlib bleach_netlist bleach_fm_all bleach_memgen
	@echo
	@echo "Running make $@:"
	rm -rf util
	rm -rf ref_data
	rm -rf rm_setup
	rm -rf rm_dc_scripts
	rm -rf rm_pt_scripts
	rm -rf rm_starrc_scripts
	rm -rf rm_icc_scripts
	rm -rf rm_icc_dp_scripts
	rm -rf rm_icc_zrt_scripts
	rm -rf rm_libprep_lef_in_scripts
	rm -rf rm_libprep_gds_in_scripts
	rm -rf dump
	rm -rf logs
	rm -rf results
	rm -rf reports
	rm -rf $(VPATH)
	rm -rf $(DESIGN_NAME)_dclib
	rm -rf $(DESIGN_NAME)_mwlib
	rm -rf $(DESIGN_NAME)_mwlib.tf_checker
	-rm -f filenames.log  rm_bpv_variable.txt tech_sage-x_tsmc_cl018g_6lm.lef.tech.clf
	rm -f .back
	rm -f default.vpad
	rm -f filenames_*
	rm -f icc_gui.output
	rm -f icc_output.txt
	rm -f icc_remove_cel.tcl
	rm -f .__tmp*
	rm -f bsg_chip_port_map.*
	@echo
