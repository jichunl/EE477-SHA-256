proc delete_vias {args} {
    parse_proc_arguments -args $args results
    set lower_layer $results(-lower_layer)
    set higher_layer $results(-higher_layer)
    if {[info exist results(-within)]} {
        set all_vias [get_vias -within $results(-within)]
    }
    if {[info exist results(-at)]} { set all_vias [get_vias -at $results(-at)] }
    if {[info exist results(-intersect)]} { set all_vias [get_vias -intersect $results(-intersect)] }
    if {[info exist results(-touching)]} { set all_vias [get_vias -touching $results(-touching)] }
    change_selection [filter_collection $all_vias "via_layer <= $higher_layer and via_layer >= $lower_layer"]
    remove_objects -skip_fixed [get_selection]
}

define_proc_attributes delete_vias \
    -info "Deletes vias in a particular region between lower and higher layer limits. Enter one of '-within', '-at', '-intersect' or '-touching'" \
    -define_args {
        {-lower_layer "Lower layer to be deleted" "" string required}
        {-higher_layer "Higher layer to be deleted" "" string required}
        {-within "within specified region (bbox)" "" list optional}
        {-at "overlap the specified point (bbox)" "" list optional}
        {-intersect "intersect specified region (bbox)" "" list optional}
        {-touching "touching specified region (bbox)" "" list optional}
    }
