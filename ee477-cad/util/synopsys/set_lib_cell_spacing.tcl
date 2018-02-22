# This script is to control the spacing between all instances of a given
# reference and other cells in the design by using the
# set_lib_cell_spacing_label and set_spacing_label_rule command.

# For example, to specify that a space of 2 placement sites should be
# maintained on either side of all instances of NDN101 library reference and a
# space of 3 placement sites should be maintained on either side of all
# instances of NDN102 library reference, use the following commands:

# You cannot define a keepout margin of a specific size for all instances of a
# library reference.

set all_cells [get_lib_cells */*]

set_lib_cell_spacing_label \
  -names {label_0} \
  -left_lib_cells [get_object_name $all_cells] \
  -right_lib_cells [get_object_name $all_cells]

set_lib_cell_spacing_label \
  -names {label_1} \
  -left_lib_cells {NDN101} \
  -right_lib_cells {NDN101}
set_spacing_label_rule -labels {label_1 label_0} {0 2}

set_lib_cell_spacing_label -names {label_2} \
  -left_lib_cells {NDN102} \
  -right_lib_cells {NDN102}
set_spacing_label_rule -labels {label_2 label_0} {0 3}
