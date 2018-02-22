#!/usr/bin/python

import sys
import os
import optparse

# Unbuffer prints
unbuffered = os.fdopen(sys.stdout.fileno(), 'w', 0)
sys.stdout = unbuffered

# --- #

# arguments parsing
optparser = optparse.OptionParser()

optparser.add_option("-a",
                     "--all",
                     action="store_true",
                     dest="show_all",
                     help="show all license status")
optparser.add_option("--keys",
                     action="store_true",
                     dest="keys",
                     help="print Synopsys key file on screen")
optparser.add_option("-f",
                     "--feature",
                     action="store",
                     dest="feature",
                     help="show feature-specific license status")
optparser.add_option("-r",
                     "--remove",
                     action="store_true",
                     dest="remove",
                     help="remove user from using license")
optparser.add_option("--user",
                     action="store",
                     dest="user",
                     help="user name")
optparser.add_option("--pid",
                     action="store",
                     dest="pid",
                     help="process id using a license")

# Short names for feature license names
# >>> Add the option name (without --) to l_feature_license list for each added
# >>> feature license option.
l_feature_license = ["dw", "dc", "icc"]
optparser.add_option("--dw",
                     action="store_true",
                     dest="dw",
                     help="show DesignWare related license status")
optparser.add_option("--dc",
                     action="store_true",
                     dest="dc",
                     help="show Design Compiler related license status")
optparser.add_option("--icc",
                     action="store_true",
                     dest="icc",
                     help="show DesignWare related license status")

(opts, args) = optparser.parse_args()

scl_dir     = "/gro/cad/synopsys/scl"
scl_release = scl_dir + "/11.7/amd64"
if (not os.path.exists(scl_release)) :
  scl_release = scl_dir + "/11.12/linux64"
scl_port = "27020"
scl_server = "132.239.15.56"
scl_key     = "/gro/cad/license/synopsys-key.txt"

lmstat      = scl_release + "/bin/lmstat"
lmremove    = scl_release + "/bin/lmremove"

# --- #

if (opts.show_all):
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -a")

if (opts.keys):
  os.system("cat " + scl_key)

if (opts.remove):
  if (opts.user == None) or (opts.feature == None) or (opts.pid == None):
    print "Error: User name, feature name, and PID number must be all provided for remove action."
  else:
    # Example: lmremove -c 27000@bbfs-00.calit2.net -h DC-Expert bbfs-00.calit2.net 27000 37237
    os.system(lmremove + " -c " + scl_port + "@" + scl_server + " -h " + opts.feature + " " + scl_server + " " + scl_port + " " + opts.pid)
elif (opts.feature != None):
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f " + opts.feature)

# dw
if (opts.dw):
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f DesignWare")
# dc
if (opts.dc):
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f Design-Vision")
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f HDL-Compiler")
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f Design-Compiler")
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f DC-Expert")
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f DC-Ultra-Opt")
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f DC-Ultra-Features")
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f DC-SDF-Interface")
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f Power-Optimization")
# dw
if (opts.icc):
  os.system(lmstat + " -c " + scl_port + "@" + scl_server + " -f Galaxy-ICC")
