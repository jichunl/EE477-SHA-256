puts "PrimeRail-Info: Running script [info script]\n"

set_extract_supply_parasitics_options -max_tluplus $TLUPLUS_MAX_FILE \
                                      -tech2itf_map $MAP_FILE \
                                      -temperature $PARA_EXTRACTION_TEMPERATURE

extract_supply_parasitics -include_capacitances 1 [get_supply_nets]

read_supply_parasitics [get_supply_nets]

if {$in_gui_session} {
  gui_show_map -window [gui_get_current_window -types Layout -mru] -map {rail_parasitics} -show {true}
}

puts "PrimeRail-Info: Completed script [info script]\n"
