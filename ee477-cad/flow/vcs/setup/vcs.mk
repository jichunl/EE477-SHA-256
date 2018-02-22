# VCS Makefile

# VCS OPTIONS - Compile-time options
# +vcs+lic+wait                          - Wait for a license rather than exit immediately
# -sverilog                              - Allow SystemVerilog code
# +v2k                                   - Allow features from IEEE 1364-2001 standard
# +lint=all                              - Print warning messages
# -v filename                            - Specify a library file
# -y dirname                             - Specify a library directory
# +libext+<ext>+                         - Specify file extensions (separated by + characters) for libary directory search
# -timescale=<unit>/<precision>          - Time values specified are in terms of <unit>, and delays are rounded to <precision>
# -override_timescale=<unit>/<precision> - Overrides the timescale specified in any source file (be careful)
# +evalorder                             - Change the way in which VCS evaluates the combinational and behavioral event queues
# -race                                  - Might be used to find race conditions (undocumented); also see "raced"
# -timopt+<clock_period>                 - Unclear; supposed to help speed up simulation time
# -full64                                - Run in 64-bit mode
# -gui                                   - When used at compile time, starts DVE GUI (Discovery Visual Environment) at runtime.
# -parallel                              - Enable multicore compilation
# -debug_pp, -debug, -debug_all          - Various debugging modes
# +nospecify                             - Tells VCS to ignore specify blocks. Can increase simulation speed but design may simulate differently.
# +notimingcheck (can be SIM OPTS too)   - Ignores timing check system tasks. Can increase simulation speed but design may simulate differently.
# +no_notifier                           - Suppresses the toggling of notifier registers that are optional arguments of system timing checks.
# +delay_mode_zero                       - Disables all delays. Can increase simulation speed but design may simulate differently.
# +vcs+stop+time                         - Stop simulation at the time value specified.
# +vcs+finish+time                       - Ends simulation at the time value specified.

# SIM OPTIONS - Run-time options
# -vpd filename.vpd                      - Specifies the VPD file, compressed binary format, Synopsys improved.
# +notimingcheck (can be SIM OPTS too)   - Ignores timing check system tasks. Can increase simulation speed but design may simulate differently.

# -o <name> specifies the generated simulator executable name.
VCS_OPTIONS += -o $(SIMV_NAME)
VCS_OPTIONS += -full64
VCS_OPTIONS += +v2k
VCS_OPTIONS += +vc
VCS_OPTIONS += -sverilog
VCS_OPTIONS += -debug_pp
VCS_OPTIONS += +vcs+lic+wait
VCS_OPTIONS += +multisource_int_delays
VCS_OPTIONS += +neg_tchk
VCS_OPTIONS += +libext+.v+.vlib+.vh

# The following variables need to be specified in the project-specific Makefile
HDL_SOURCE  ?= testbench.v
SIMV_NAME   ?= simv
VPD_FILE    ?= $(SIMV_NAME).vpd

# Enable GUI (DVE) mode
# This is to run interative simulation/debugging in GUI mode.
ifeq ($(VCS_GUI),1)
  VCS_OPTIONS += -gui
endif

# Dump all value changes to $(VPD_FILE).
ifeq ($(VPD),1)
  SIM_OPTIONS += +vpdfile+$(VPD_FILE)
endif

# Create executable VCS simulator
simv: $(HDL_SOURCE)
	$(VCS) $(VCS_OPTIONS) $(HDL_SOURCE)

# Run simulation
sim: $(SIMV_NAME)
	./$(SIMV_NAME) $(SIM_OPTIONS)

# View dumped value change waveform (vpd format) in DVE
view_vpd: $(VPD_FILE)
	$(VCS_BIN)/dve -full64 -vpd $(VPD_FILE) &

# Clean
clean_vcs:
	rm -rf csrc
	rm -rf ucli.key
	rm -rf inter.vpd
	rm -rf DVEfiles
	rm -rf $(VPD_FILE)
	rm -rf $(SIMV_NAME)
	rm -rf $(SIMV_NAME).daidir
