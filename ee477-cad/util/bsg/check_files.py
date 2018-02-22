#!/usr/bin/python

# Check if files exist

import sys
import os

if (len(sys.argv) == 1):
  print "Command expects exactly 1 file-type argument that contains a list of files."
  sys.exit(1)
else:
  # Read a list of files to be checked from a file.
  file = open(sys.argv[1])
  l_files = [line.strip() for line in file]
  file.close()

  for f in l_files:
    ls_val = os.system('ls ' + f + ' > /dev/null')
