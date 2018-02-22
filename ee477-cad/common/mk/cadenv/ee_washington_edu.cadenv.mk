# TODO: Pre-amble
#

# Useful Directories
LAB_APP_DIR:=/home/lab.apps/vlsiapps
EE477_COMMON_DIR:=/home/projects/ee477/common

# Disable warning about CentOS
export VCS_ARCH_OVERRIDE:=linux

# Synopsys License setup
export LM_LICENSE_FILE:=5280@persephone.engr.washington.edu:50836@persephone.engr.washington.edu:5280@payne.ee.washington.edu
#export SNPSLMD_LICENSE_FILE:=
#export SYNPLCTYD_LICENSE_FILE:=

# Let Synopsys tools queue on licenses.
export SNPSLMD_QUEUE:=1
export SCL_QUEUE_ON_MAX:=1
export SNPS_MAX_WAITTIME:=1800
export SNPS_MAX_WAITTIME:=1800

# Tool Setup!!!
export LC_RELEASE:=$(LAB_APP_DIR)/library_compiler/H-2013.03-SP5-2
export MW_RELEASE:=$(LAB_APP_DIR)/milkyway/I-2013.12-SP2
export CDESIGNER_RELEASE:=$(EE477_COMMON_DIR)/synopsys/customdesigner/J-2014.12-SP2-2
export CEXPLORER_RELEASE:=$(LAB_APP_DIR)/custom_explorer/H-2013.03-SP2
export DC_RELEASE:=$(EE477_COMMON_DIR)/synopsys/dc/L-2016.03-SP5-4
export HSPICE_RELEASE:=$(LAB_APP_DIR)/hspice/H-2013.03-SP2
export ICC_RELEASE:=$(LAB_APP_DIR)/icc/J-2014.09-SP1
export PTS_RELEASE:=$(LAB_APP_DIR)/primetime/H-2012.12-SP3
export VCS_RELEASE:=$(EE477_COMMON_DIR)/synopsys/vcs/M-2017.03-SP2-4

export LC_BIN:=$(LC_RELEASE)/bin
export MW_BIN:=$(MW_RELEASE)/bin/AMD.64
export CDESIGNER_BIN:=$(CDESIGNER_RELEASE)/bin
export CEXPLORER_BIN:=$(CEXPLORER_RELEASE)/bin
export DC_BIN:=$(DC_RELEASE)/bin
export HSPICE_BIN:=$(HSPICE_RELEASE)/hspice/amd64
export ICC_BIN:=$(ICC_RELEASE)/bin
export IVERILOG_BIN:=$(EE477_COMMON_DIR)/iverilog/bin
export PTS_BIN:=$(PTS_RELEASE)/bin
export VCS_BIN:=$(VCS_RELEASE)/bin
export VERILATOR_BIN:=$(EE477_COMMON_DIR)/verilator/bin

export LC:=$(LC_BIN)/lc_shell
export MW:=$(CDESIGNER_BIN)/Milkeyway
export CDESIGNER:=$(CDESIGNER_BIN)/cdesigner
export CEXPLORER:=$(CEXPLORER_BIN)/wv
export DC:=$(DC_BIN)/dc_shell-xg-t
export HSPICE:=$(HSPICE_BIN)/hspice
export ICC:=$(ICC_BIN)/icc_shell
export IVERILOG:=$(EE477_COMMON_DIR)/iverilog
export PTS:=$(PTS_BIN)/pt_shell
export VCS:=$(VCS_BIN)/vcs
export VERILATOR:=$(VERILATOR_BIN)/verilator

export MGC_HOME:=/home/lab.apps/vlsiapps/calibre/ixl_cal_2011.4_35.27
export CALIBRE_BIN:=$(MGC_HOME)/bin

# Add to path
export PATH:=$(LC_BIN):$(MW_BIN):$(CDESIGNER_BIN):$(CEXPLORER_BIN):$(DC_BIN):$(HSPICE_BIN):$(ICC_BIN):$(IVERILOG_BIN):$(PTS_BIN):$(VCS_BIN):$(VERILATOR_BIN):$(CALIBRE_BIN):$(PATH)

# CACTI-MC
export CACTI_MC_BIN:=$(EE477_COMMON_DIR)/cacti-mc/cacti-mc
export PATH:=$(CACTI_MC_BIN):$(PATH)

# Additional Variables
export VCS_HOME:=$(VCS_RELEASE)
export OA_UNSUPPORTED_PLAT:=linux_rhel40
export ECE5745_STDCELLS:=$(EE477_COMMON_DIR)/kits/saed-90nm/stdview
