#!/bin/bash

# Determine the # cores on your machine

# Determin whether it is Linux or Solaris
uname -a

# Do this for most Linux platforms.
grep processor /proc/cpuinfo

# Do this for SunOS/Solaris.
# exec /usr/sbin/psrinfo
