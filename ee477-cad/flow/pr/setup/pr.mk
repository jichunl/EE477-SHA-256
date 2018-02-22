# PrimeRail Basic Flow Makefile

PR_EXEC        = $(PRIMERAIL) -64bit
PR_LOGS_DIR    = $(CURDIR)/logs/pr
PR_REPORTS_DIR = $(CURDIR)/reports/pr
PR_RESULTS_DIR = $(CURDIR)/results/pr

# Export to bash shell to be obtained by Tcl scripts.
export PR_LOGS_DIR
export PR_REPORTS_DIR
export PR_RESULTS_DIR

# VPATH tells the gmake utility to create and look for the target touchfiles in
# a certain directory. You should not modify this variable.
VPATH = touchfiles

## Source Options
PR_OPTIONS =
