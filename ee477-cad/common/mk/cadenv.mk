# Keep this at the top!
MKDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# UW EE Educational Servers!
ifneq (,$(findstring ee.washington.edu,$(HOSTNAME)))
	include $(MKDIR)/cadenv/ee_washington_edu.cadenv.mk
endif

