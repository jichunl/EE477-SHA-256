# 2013 Synopsys, Inc. All rights reserved.
#
# The floating_net.tcl script removes all floating nets from your design.
#
# Usage
#
# Run the following command to remove the floating nets from your design:
# icc_shell> source -e -v floating_net.tcl
#
# If you want to create a collection that contains the floating nets present in
# the design, but not delete these nets, remove the following command from the
# end of the script:
#
# remove_net [get_nets $floating_nets];

set all_nets [get_nets -hier *] ;
set flag1 0;
set flag2 0;
set flag3 0;
set flag4 0;
set flag5 0;
set flag6 0;
set floating_nets {};

foreach_in_collection check_net [get_nets $all_nets] {
  set flag1 0;
  set flag2 0;
  set flag3 0;
  set flag4 0;
  set flag5 0;
  set flag6 0;
  set name [get_object_name $check_net];

  if { [sizeof_collection [get_pins -of [get_nets $check_net] -quiet -filter "pin_direction==in" ] ] >= 1 } {
    #echo "net $name is connected to input pin";
    set flag1 1;
  }

  if { [sizeof_collection [get_pins -of [get_nets $check_net] -quiet -filter "pin_direction==out" ] ] >= 1 } {
    #echo "net $name is connected to output pin";
    set flag2 1;
  }

  if { [sizeof_collection [get_pins -of [get_nets $check_net] -quiet -filter "pin_direction==inout" ] ] >= 1 } {
    #echo "net $name is connected to inout pin";
    set flag3 1;
  }

  if { [sizeof_collection [get_ports -of [get_nets $check_net] -quiet -filter "direction==in" ] ] >= 1 } {
    #echo "net $name is connected to input port";
    set flag4 1;
  }

  if { [sizeof_collection [get_ports -of [get_nets $check_net] -quiet -filter "direction==out" ] ] >= 1 } {
    #echo "net $name is connected to output port";
    set flag5 1;
  }

  if { [sizeof_collection [get_ports -of [get_nets $check_net] -quiet -filter "direction==inout" ] ] >= 1 } {
    #echo "net $name is connected to inout port";
    set flag6 1;
  }

  ## Cases of floating nets ##
  if { $flag1 == 1 && $flag2 == 0 && $flag3 ==0 && $flag4 == 0 && $flag5 == 0 && $flag6 == 0 } {
    echo "net $name has only input pin connections"
    append_to_collection floating_nets [get_nets $name];
  } elseif { $flag1 == 0 && $flag2 == 1 && $flag3 ==0 && $flag4 == 0 && $flag5 == 0 && $flag6 == 0 } {
    echo "net $name has only output pin connections"
    append_to_collection floating_nets [get_nets $name];
  } elseif { $flag1 == 0 && $flag2 == 0 && $flag3 == 1 && $flag4 == 0 && $flag5 == 0 && $flag6 == 0 } {
    echo "net $name is connected only to inout pin"
    append_to_collection floating_nets [get_nets $name];
  } elseif { $flag1 == 0 && $flag2 == 0 && $flag3 == 0 && $flag4 ==1 && $flag5 == 0 && $flag6 == 0 } {
    echo "net $name is connected only to input port"
    append_to_collection floating_nets [get_nets $name];
  } elseif { $flag1 == 0 && $flag2 == 0 && $flag3 == 0 && $flag4 ==0 && $flag5 == 1 && $flag6 == 0 } {
    echo "net $name is connected only to output port"
    append_to_collection floating_nets [get_nets $name];
  } elseif { $flag1 == 0 && $flag2 == 0 && $flag3 == 0 && $flag4 ==0 && $flag5 == 0 && $flag6 == 1 } {
    echo "net $name is connected only to inout port"
    append_to_collection floating_nets [get_nets $name];
  } else {
    #echo "net $name has connections";
  }
}

remove_net [get_nets $floating_nets];
