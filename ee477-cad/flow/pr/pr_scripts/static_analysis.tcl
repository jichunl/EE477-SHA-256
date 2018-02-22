puts "PrimeRail-Info: Running script [info script]\n"

update_currents -static

calculate_rail_voltage [list $RAIL_SUPPLY_NETS $RAIL_GROUND_NETS] -static

# Electromigration
update_em

puts "PrimeRail-Info: Completed script [info script]\n"
