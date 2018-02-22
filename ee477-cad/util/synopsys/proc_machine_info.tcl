# © 2014 Synopsys, Inc. All rights reserved.
# # This script is proprietary and confidential information of
# Synopsys, Inc. and may be used and disclosed only as authorized
# per your agreement with Synopsys, Inc. controlling such use and disclosure.

###################################################
# Author Narendra Akilla
# Applications Consultant
# Company Synopsys Inc.
# Not for Distribution without Consent of Synopsys
###################################################

# Procedure to print useful machine information
# Version 1.1 runtime improvements

proc proc_machine_info {} {

  # Version 1.1
  set naren_tmpdir /tmp
  redirect -var naren_dsk { exec df -kh $naren_tmpdir }
  set naren_ttmp [lindex [lindex [split $naren_dsk "\n"] 1] 1]
  set naren_avail [lindex [lindex [split $naren_dsk "\n"] 1] 3]
  set naren_pctav [lindex [lindex [split $naren_dsk "\n"] 1] 4]
  set naren_pctav [string trim ${naren_pctav} "%"]

  set FIL [open /proc/cpuinfo "r"] ; set cpu_info [read $FIL] ; close $FIL
  regexp -line {model name\s+:\s+(.*)} $cpu_info match naren_model
  regexp -line {cache size\s+:\s+(.*)} $cpu_info match naren_cache
  regexp -line {cpu MHz\s+:\s+(.*)} $cpu_info match naren_mhz
  set naren_cores [regexp -all "processor" $cpu_info]
  set naren_sockets [lindex [lindex [lsort -index 3 -decreasing -real [regexp -inline -all -line {physical id\s+:\s+.*} $cpu_info]] 0] 3]

  if {[string is double -strict $naren_mhz]} {
    set naren_mhz "[format %.2f [expr {$naren_mhz/1000.0}]]Ghz"
  } else {
    set naren_mhz "${naren_mhz}Mhz"
  }

  # get uname -sr info
  set FIL [open /proc/sys/kernel/ostype "r"] ; set os_info [read $FIL] ; close $FIL
  set FIL [open /proc/sys/kernel/osrelease "r"] ; append os_info [read $FIL] ; close $FIL
  set os_info [regsub -all {\n} $os_info { }]

  # get free mem/swp of machine
  set FIL [open /proc/meminfo "r"] ; set mem_info [read $FIL] ; close $FIL
  regexp -line {MemTotal\s*:\s*(\d+)} $mem_info match memt
  regexp -line {MemFree\s*:\s*(\d+)} $mem_info match memf
  regexp -line {SwapTotal\s*:\s*(\d+)} $mem_info match swpt
  regexp -line {SwapFree\s*:\s*(\d+)} $mem_info match swpf

  set naren_mem  [expr {$memt/1048576}]
  set naren_memf [expr {$memf/1048576}]

  set naren_swp  [expr {$swpt/1048576}]
  set naren_swpf [expr {$swpf/1048576}]

  if {![info exists ::env(USER)]} { setenv USER [exec whoami] }

  echo "\n########################## MACHINE INFORMATION ##############################"
  echo "User:       $::env(USER)"
  echo "Host:       [info hostname]"
  echo "Date:       [date]"
  echo "OS:         $os_info"
  echo "CPU:        Cores = $naren_cores : Sockets = $naren_sockets : Cache Size = $naren_cache : Freq = $naren_mhz : Model Name = $naren_model"
  echo "Memory:     Ram:  [format %5s "${naren_mem}GB"]\t(Free [format %5s "${naren_memf}GB"])"
  echo "\t    Swap: [format %5s "${naren_swp}GB"]\t(Free [format %5s "${naren_swpf}GB"])"
  echo "\t    ${naren_tmpdir}: [format %5s "${naren_ttmp}B"]\t(Free [format %5s "${naren_avail}B"])"
  echo "Dir:        [pwd]"
  echo "Version:    $::sh_product_version"
  if {${naren_pctav}>=90} { echo "WARNING: temp disk space (${naren_tmpdir}) is near FULL ${naren_pctav}% ..." }
  echo "##################### END MACHINE INFORMATION ###############################\n"
}

echo "\tproc_machine_info"
