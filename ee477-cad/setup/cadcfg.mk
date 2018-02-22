# Create and install configuration scripts for CAD tools

include ../common/mk/cadenv.mk
include ../common/mk/install.mk

INSTALL_PATH_PREFIX = ${HOME}

INSTALL_DOTFILES = synopsys_icc_gui.tcl

all: $(INSTALL_DOTFILES)

synopsys_icc_gui.tcl:
	@echo "set MENTOR_DIR      \"$(MENTOR_DIR)\""                          > $@
	@echo "set CALIBRE_RELEASE \"$(CALIBRE_RELEASE)\""                    >> $@
	@echo "set CALIBRE_HOME    \"$(MENTOR_DIR)/$(CALIBRE_RELEASE)\""      >> $@
	@echo "set CALIBRE_DIR     \"$(CALIBRE_HOME)\""                       >> $@
	@echo "set CALIBRE_BIN_DIR \"$(CALIBRE_HOME)/bin\""                   >> $@
	@echo "set CALIBRE         \"$(CALIBRE_BIN_DIR)/calibre\""            >> $@
	@echo "set CALIBREDRV      \"$(CALIBRE_BIN_DIR)/calibredrv\""         >> $@
	@echo "set MGC_HOME        \"$(CALIBRE_HOME)\""                       >> $@
	@echo "set LM_LICENSE_FILE \"$(LM_LICENSE_FILE)\""                    >> $@
	@echo                                                                 >> $@
	@echo "source [file join \$$::env(CALIBRE_HOME) lib icc_calibre.tcl]" >> $@
	@echo                                                                 >> $@
	@cat  synopsys/synopsys_icc_gui.custom.tcl                            >> $@

clean_cadcfg:
	rm -rf $(INSTALL_DOTFILES)
