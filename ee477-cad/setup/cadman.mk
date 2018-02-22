# Install CAD manual tools to user's $HOME/bin folder.

include ../common/mk/cadenv.mk
include ../common/mk/install.mk

CADMAM = dcman fmman mwman iccman prman ptman

INSTALL_PATH_PREFIX = $(HOME)/bin

INSTALL_RWXFILES = $(CADMAM)

all: $(CADMAM)

dcman:
	@mkdir -p $(INSTALL_PATH_PREFIX)
	@echo "#!/bin/bash" > $@
	@echo >> $@
	@echo "man -M ${DC_RELEASE}/doc/syn/man \$${1}" >> $@

fmman:
	@mkdir -p $(INSTALL_PATH_PREFIX)
	@echo "#!/bin/bash" > $@
	@echo >> $@
	@echo "man -M ${FM_RELEASE}/doc/fm/man \$${1}" >> $@

mwman:
	@mkdir -p $(INSTALL_PATH_PREFIX)
	@echo "#!/bin/bash" > $@
	@echo >> $@
	@echo "man -M ${MW_RELEASE}/doc/common/man \$${1}" >> $@

iccman:
	@mkdir -p $(INSTALL_PATH_PREFIX)
	@echo "#!/bin/bash" > $@
	@echo >> $@
	@echo "man -M ${ICC_RELEASE}/doc/icc/man \$${1}" >> $@

prman:
	@mkdir -p $(INSTALL_PATH_PREFIX)
	@echo "#!/bin/bash" > $@
	@echo >> $@
	@echo "man -M ${PRIMERAIL_RELEASE}/doc/pr/man \$${1}" >> $@

ptman:
	@mkdir -p $(INSTALL_PATH_PREFIX)
	@echo "#!/bin/bash" > $@
	@echo >> $@
	@echo "man -M ${PRIMETIME_RELEASE}/doc/pt/man \$${1}" >> $@

clean_cadman:
	rm -rf $(CADMAM)
