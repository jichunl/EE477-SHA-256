puts "PrimeRail-Info: Running script [info script]\n"

read_supply_parasitics [get_supply_nets]

if {$in_gui_session} {
  gui_show_map -window [gui_get_current_window -types Layout -mru] -map {rail_parasitics} -show {true}
}

puts "PrimeRail-Info: Completed script [info script]\n"
