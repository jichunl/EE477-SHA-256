#####################################################################
# This script will dump out a .tf file which includes the           #
# System Layers when run on a design with mw library opened.        #
# The file name will be techfile_with_SystemLayers.tf               #
# Author: Charly Poul                                               #
# Date: 11 October 2013                                             #
#####################################################################

write_mw_lib_files -technology -output dumped_tech.tf [current_mw_lib]

set d [open dumped_tech.tf "r"]
set tech_string [read $d]
set e [open dumped_tech1.tf "w"]

set a [string first "}" $tech_string]

set tech_string [string replace $tech_string $a  $a "useSystemLayers  = 1  }"]
puts -nonewline $e $tech_string

close $d
close $e

set_mw_technology_file [current_mw_lib] -technology dumped_tech1.tf
write_mw_lib_files -technology -output techfile_with_SystemLayers.tf [current_mw_lib]

file delete -force dumped_tech.tf
file delete -force dumped_tech1.tf

unset d
unset e
unset a
unset tech_string
