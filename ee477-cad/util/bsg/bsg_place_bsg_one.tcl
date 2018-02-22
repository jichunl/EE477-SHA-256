
proc bsg_highlight_bsg_one {} {
    gui_change_highlight -color light_blue -collection [get_flat_cells -quiet {*st_netw*}]
    gui_change_highlight -color green -collection [get_flat_cells -quiet {*int_multiplier*}]
    gui_change_highlight -color yellow -collection [get_flat_cells -quiet {*hp_dynamic_network*}]
    gui_change_highlight -color orange -collection [get_flat_cells -quiet {*status_regfile*}]
    gui_change_highlight -color light_orange -collection [get_flat_cells -quiet {*mainfpu*}]
    gui_change_highlight -color light_red -collection [get_flat_cells -quiet {*user_dynamic_network*}]
    gui_change_highlight -color purple -collection [get_flat_cells -quiet {*comm_link*}]
    gui_change_highlight -color red -collection [get_flat_cells -quiet {*bdiom*}]
    gui_change_highlight -color blue -collection [get_flat_cells -quiet {*dmem_cache*}]


    gui_change_highlight -color light_green -collection [get_flat_cells -quiet {*proc/rf*}]
    gui_change_highlight -color red -collection [get_flat_cells -quiet {*proc/fu*}]

    gui_change_highlight -color light_red -collection [get_flat_cells -quiet {*int_divider*}]
    gui_change_highlight -color yellow -collection [get_flat_cells -quiet {*hp_dynamic_network*}]
}

proc bsg_one_block_rams {} {
    create_placement_blockage -coordinate {{525.080 3923.700} {1590 3976.690}} -name placement_blockage_0 -type hard
    create_placement_blockage -coordinate { {1080.160 3398.900}{ 1606.750 3462.900}}  -name placement_blockage_1 -type hard
    create_placement_blockage -coordinate {{519.350 4435.700} {1592.350 4480.360}} -name placement_blockage_2 -type hard
    create_placement_blockage -coordinate {{503.660 3437.300} {575.350 4497.480}} -name placement_blockage_3 -type hard
#    create_placement_blockage -coordinate {{1940.150 3853.300} {2991.850 3910.900}} -name placement_blockage_4 -type hard
    create_placement_blockage -coordinate {{2200.460 3853.300}{3055 3910.900}} -name placement_blockage_4 -type hard

#   create_placement_blockage -coordinate {{2954.850 3475.700} {3033.150 4429.300}} -name placement_blockage_5 -type hard
    create_placement_blockage -coordinate {{3205.920 3482.570} {3285.200 4398.880}}  -name placement_blockage_5 -type hard

    create_placement_blockage -coordinate {4224.400 4399.970 4479.350 4484.370} -name placement_blockage_6 -type hard
    create_placement_blockage -coordinate {{3838.680 4410.100} {4069.150 4500.440}} -name placement_blockage_7 -type hard
    create_placement_blockage -coordinate {{4367.050 501.760} {4495.430 2342.900}} -name placement_blockage_8 -type hard
    create_placement_blockage -coordinate {{3209.78 517.840} {4511.500 672.500}} -name placement_blockage_9 -type hard


#    create_placement_blockage -coordinate {{1276.13 1171.700} {1859.23 1212.05}} -name placement_block_10 -type hard
    create_placement_blockage -coordinate {{1565.980 1331.360} {2149.080 1371.710}} -name placement_block_10 -type hard
    #create_placement_blockage -coordinate {{1469.050 501.760} {1809.460 659.700}} -name placement_blockage_10 -type hard
}

proc bsg_one_create_bounds {} {

    suppress_message MWUI-710

# bad results if you do this -- maybe because of accidental matching?
#    bsg_bound_creator_abs fu 1554.330 2737.080 2079.250 4380.690
#    bsg_bound_creator_abs /fu/ 1609.520 3085.350 2036.620 4165.580
#    bsg_bound_creator_abs /fu/ 1609.520 3574.210 2036.620 4251.380
# push up even further. 6/2015
#    bsg_bound_creator_abs /fu/ 1609.520 3820.830 2036.620 4287.180
# push back down 6/2015
#    bsg_bound_creator_abs /fu/ 1609.520 3251.880 2036.620 4287.180

# bsg_bound_creator_abs /fu/ 1609.520 3615.000 2036.620 4287.180
    bsg_bound_creator_abs /fu/ 1609.520 3404.230 2187.710 4128.590

    bsg_bound_creator_abs dmem_cache 1791.850 631.200 2476.940 1485.380
#    set_object_boundary -boundary {{1587.320 631.200} {2476.940 631.200} {2476.940 2149.130} {2103.720 2149.130} {2103.720 1351.810} {1587.320 1351.810} } dmem_cache
    set_object_boundary -boundary {{1852.810 631.200} {2476.940 631.200} {2476.940 1540.710} {2103.720 1540.710} {2103.720 1540.710} {1852.810 1540.710} } dmem_cache

    bsg_bound_creator_abs /cgni_blk/ 2387 2307.370 2692 2799.460
    update_bounds -name /cgni_blk/ -add [get_flat_cells */cmni_blk/*]
    update_bounds -name /cgni_blk/ -add [get_flat_cells */csti_blk/*]
    update_bounds -name /cgni_blk/ -add [get_flat_cells */csti2_blk/*]

#    bsg_bound_creator_abs int_multiplier  1283.510 1353.470 1690.640 2225.390  MBT revert to this one if no good 6-26
#    bsg_bound_creator_abs int_multiplier  564.420 1791.810 971.550 2663.730

    bsg_bound_creator_abs int_multiplier 564.420 1571.300 971.550 2663.730
#
    update_bounds -name int_multiplier -add [get_flat_cells *proc/REG_mul*]
    update_bounds -name int_multiplier -add [get_flat_cells *controlpipe/dEdgeFF_is_FPUmul_exe*]

#    bsg_bound_creator_abs mainfpu  1687.770 1352.780 2107.650 2157.560 
  bsg_bound_creator_abs mainfpu 974.590 1847.280 1394.470 2761.540
    update_bounds -name mainfpu -add [get_flat_cells *proc/REG_fpu*]

  bsg_bound_creator_abs int_divider  974.690 1569.740 1394.830 1847.160

    #update_bounds -name int_multiplier -add [get_flat_cells *POPCOUNTer*]
    #update_bounds -name int_multiplier -add [get_flat_cells *ROTATEer*]

#     resize_objects -bbox {1283.510 1353.470 2106.410 2225.390}  int_multiplier


#    bsg_bound_creator_abs event_counters 547.23 1665 1138.760 2245.080

    bsg_bound_creator_abs /hp_dynamic_network/   2983.240 2207.260 3916.200 2547.480
    bsg_bound_creator_abs /user_dynamic_network/ 2983.240 2448.110 3916.600 2772.920
    resize_objects -bbox {2700 2307.260 3550 2567.400} /hp_dynamic_network/
    resize_objects -bbox {2700 2570.030 3550 2820.730} /user_dynamic_network/

    bsg_bound_creator_abs fsb_node_0__hopin/fifo 3541.220 3670.530 3605.550 4222.200

    bsg_bound_creator_irregular bdiom/ {   2968.100 2804.370   3908.480 3068.850  2968.100 3068.850   3842.710 3359.920  3095.440 3359.920   3842.710 3476.070  3324.940 3476.070   3842.710 4454.240  }

    set_object_boundary -boundary {{4207.470 4431.180} {4207.470 3561.900} {3658.170 3561.900} {3658.170 2831.280} {2620.300 2831.280} {2620.300 3365.210} {3103.540 3365.210} {3103.540 3481.920} {3332.860 3481.920} {3332.860 4431.180} } bdiom/

    update_bounds -name bdiom/ -add [get_flat_cells -quiet */z_bmc/*]
    update_bounds -name bdiom/ -add [get_flat_cells -quiet */fsb/*hopout*]

#    bsg_bound_creator_abs proc/rf 1083.510 2651.220 2058.050 2866.550
   # move rf down.
     bsg_bound_creator_abs proc/rf 1397.760 1568.970 2372.300 1785.280

    set proc_bounds {   573.830 524.100   1537.870 623.570  573.830 623.570   2482.790 2211.170  1289.210 2211.170   2482.790 2880.640  1541.700 2880.640   2482.790 3358.840  1541.700 3358.84   1966.340 4400.61 }

    bsg_bound_creator_irregular  /proc/ $proc_bounds

#    set_object_boundary -boundary {{1079.670 2152.310} {2482.790 2152.310} {2482.790 2317.690} {2482.790 2317.690} {2482.790 2802.550} {2248.350 2802.550} {2248.350 3358.840} {2032.090 3358.840} {2032.090 3402.540} {1397.120 3402.540} {1397.120 2859.740} {1079.670 2859.740} } /proc/  mbt 6-26 revert to this one if no go

#set_object_boundary -boundary {{1397.120 1794.740} {2482.790 1794.740} {2482.790 2802.550} {2248.350 2802.550} {2248.350 3358.840} {2193.590 3358.840} {2193.590 3402.540} {1397.120 3402.540} } /proc/

 set_object_boundary -boundary {{1397.120 1794.740} {2482.790 1794.740} {2482.790 2802.550} {2193.590 2802.550} {2193.590 3358.840} {2193.590 3358.840} {2193.590 3402.540} {1397.120 3402.540} } /proc/

    bsg_bound_creator_irregular /st_netw/ {   3909.880 3078.650   4451.440 3557.240  4089.000 3557.240   4451.440 3572.630  4089.000 3572.630   4226.140 4464.040  } 

    # try to fix it up with a bigger
    # set_object_boundary -boundary {{4470.720 4474.470} {4470.720 3083.710} {3852.730 3083.710} {3852.730 3547.300} {4067.190 3547.300} {4067.190 4474.470} } /st_netw/
# set_object_boundary -boundary {{4226.140 4464.040} {4226.140 3572.630} {4451.440 3572.630} {4451.440 3078.650} {3841.680 3078.650} {3841.680 3557.240} {4089.000 3557.240} {4089.000 4464.040} } /st_netw/

#set_object_boundary -boundary {{3920.720 3078.650} {4451.440 3078.650} {4451.440 3557.240} {3661.270 3557.240} {3661.270 2304.140} {3920.720 2304.140} } /st_netw/

#set_object_boundary -boundary {{3920.720 3078.650} {4451.440 3078.650} {4451.440 3557.240} {3554.040 3557.240} {3554.040 3177.010} {3920.720 3177.010} } /st_netw/

# set_object_boundary -boundary {{3888.740 2987.180} {3989.900 2987.180} {3989.900 3078.650} {4451.440 3078.650} {4451.440 3557.240} {4206.230 3557.240} {4206.230 3621.120} {3909.010 3621.120} {3909.010 3557.240} {3554.040 3557.240} {3554.040 3177.010} {3888.740 3177.010} }  /st_netw/
# set_object_boundary -boundary {{3888.740 2987.180} {3989.900 2987.180} {3989.900 3078.650} {4451.440 3078.650} {4451.440 3557.240} {4206.230 3557.240} {4206.230 3621.120} {3909.010 3621.120} {3909.010 3557.240} {3655.780 3557.240} {3655.780 3177.010} {3888.740 3177.010} } /st_netw/

#set_object_boundary -boundary {{3815.910 2987.180} {3989.900 2987.180} {3989.900 3078.650} {4451.440 3078.650} {4451.440 3557.240} {4206.230 3557.240} {4206.230 3621.120} {3909.010 3621.120} {3909.010 3557.240} {3478.590 3557.240} {3478.590 3267.700} {3552.290 3267.700} {3552.290 3177.010} {3815.910 3177.010} } /st_netw/

 set_object_boundary -boundary {{3815.910 2925.690} {4016.800 2925.690} {4016.800 3078.650} {4451.440 3078.650} {4451.440 3557.240} {4206.230 3557.240} {4206.230 3621.120} {3909.010 3621.120} {3909.010 3557.240} {3478.590 3557.240} {3478.590 3267.700} {3478.590 3267.700} {3478.590 3177.010} {3815.910 3177.010} } /st_netw/

    unsuppress_message MWUI-710
}

# FIXME: don't use automatic RP group names; get the rp group from the cell name

proc bsg_place_bdiom_in {} {
    # adding the -allow_non_rp_cells flag results in this error during floorplanning:
    #
    # Error: fphShapeDesign already initialized! (FPL-099)
    # Error: Internal error: failed to initialize shaping (VFP-025)
    # Error: Failed during increment congestion/timing driven placement. (VFP-038)
    # Error: Failed in placement. (VFP-036)
    # Global placement did not complete


    create_rp_group bdiom_in -design bsg_chip -columns 14 -rows 1


    # for test network
    # guts/z_gd/p_0__bdiom/agg/z_3__b32to64ch/fi_out_fifo/esac_fi_mem_1r1w/macro_w4_b61
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b61_1r1w::rf               -column 0 -row 0

    # fix

    #add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_dff_en_nreset_b32_0::dff         -column 10 -row 0
    add_to_rp_group  bsg_chip::bdiom_in -hier [get_attribute [get_cell guts/z_gd/p_0__bdiom/agg/z_3__b32to64ch/data_out_lo_reg/macro_dff/reg_b18] rp_group_name] -column 1 -row 0

    # guts/z_gd/p_0__bdiom/agg/z_3__b32to64ch/bdiom_gdmurn_fifo/esac_fi_mem_1r1w/macro_w4_b66
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b66_1r1w_0::rf             -column 2 -row 0



    # guts/z_gd/p_0__bdiom/agg/z_1__b32to64ch/fi_out_fifo/esac_fi_mem_1r1w/macro_w4_b32
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b32_1r1w_1::rf             -column 3 -row 0

    # fix

    add_to_rp_group  bsg_chip::bdiom_in -hier [get_attribute [get_cell guts/z_gd/p_0__bdiom/agg/z_1__b32to64ch/data_out_lo_reg/macro_dff/reg_b18] rp_group_name] -column 4 -row 0
    # add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_dff_en_nreset_b32_2::dff         -column 4 -row 0

    # guts/z_gd/p_0__bdiom/agg/z_1__b32to64ch/bdiom_gdmurn_fifo/esac_fi_mem_1r1w/macro_w4_b66/reg_w0_b
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b66_1r1w_2::rf             -column 5 -row 0


    set_rp_group_options  bsg_rp_tsmc_250_rf_w2_b80_1r1w_0::rf  -group_orient FN
    # guts/comm_link/fsb/fsb_node_0__hopout/fifo/mem_1r1w/macro_w2_b80/reg_w1_b53
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w2_b80_1r1w_0::rf             -column 6 -row 0

    set_rp_group_options  bsg_rp_tsmc_250_rf_w2_b80_1r1w::rf  -group_orient FN
    #guts/z_bmc/n_0__twofer/mem_1r1w/macro_w2_b80
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w2_b80_1r1w::rf               -column 7 -row 0


    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b66_1r1w_1::rf             -column 8 -row 0

    #guts/z_gd/p_0__bdiom/agg/z_2__b32to64ch/data_out_lo_reg/macro_dff/reg_b18
    # bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_dff_en_nreset_b32_1::dff

    add_to_rp_group  bsg_chip::bdiom_in -hier [get_attribute [get_cell guts/z_gd/p_0__bdiom/agg/z_2__b32to64ch/data_out_lo_reg/macro_dff/reg_b18] rp_group_name] -column 9 -row 0


    # guts/z_gd/p_0__bdiom/agg/z_2__b32to64ch/fi_out_fifo/esac_fi_mem_1r1w/macro_w4_b32
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b32_1r1w_0::rf             -column 10 -row 0



    # guts/z_gd/p_0__bdiom/agg/z_0__b32to64ch/bdiom_gdmurn_fifo/esac_fi_mem_1r1w/macro_w4_b66/reg_w0_b25
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b66_1r1w::rf               -column 11 -row 0
    # fix

    add_to_rp_group  bsg_chip::bdiom_in -hier [get_attribute [get_cell guts/z_gd/p_0__bdiom/agg/z_0__b32to64ch/data_out_lo_reg/macro_dff/reg_b18] rp_group_name] -column 12 -row 0

    set_rp_group_options  bsg_rp_tsmc_250_rf_w4_b32_1r1w_2::rf    -group_orient FN
    # guts/z_gd/p_0__bdiom/agg/z_0__b32to64ch/fi_out_fifo/esac_fi_mem_1r1w/macro_w4_b32
    add_to_rp_group bsg_chip::bdiom_in -hier bsg_rp_tsmc_250_rf_w4_b32_1r1w_2::rf               -column 13 -row 0
}

proc bsg_rp_group_stack_hier { rp_group_name hier_list } {
    create_rp_group $rp_group_name -design bsg_chip -columns [llength $hier_list] -rows 1
    set i 0

    foreach name $hier_list {
        add_to_rp_group bsg_chip::$rp_group_name -hier $name -column $i -row 0

        set i [expr $i+1]
    }
}



proc bsg_rp_group_stack_hier_vert { rp_group_name hier_list } {
    create_rp_group $rp_group_name -design bsg_chip -rows [llength $hier_list] -columns 1
    set i 0

    foreach name $hier_list {
        add_to_rp_group bsg_chip::$rp_group_name -hier $name -column 0 -row $i

        set i [expr $i+1]
    }
}


# takes a list of cell names and automatically extracts the relevant RP groups
proc bsg_rp_group_stack { rp_group_name name_list } {
    create_rp_group $rp_group_name -design bsg_chip -columns [llength $name_list] -rows 1
    set i 0

    foreach name $name_list {
        add_to_rp_group bsg_chip::$rp_group_name -hier [get_attribute [get_cell $name] rp_group_name] -column $i -row 0

        set i [expr $i+1]
    }
}

# takes a list of cell names and automatically extracts the relevant RP groups
proc bsg_rp_group_stack_vert { rp_group_name name_list } {
    create_rp_group $rp_group_name -design bsg_chip -columns 1 -rows [llength $name_list]
    set i 0

    foreach name $name_list {
        add_to_rp_group bsg_chip::$rp_group_name -hier [get_attribute [get_cell $name] rp_group_name] -column 0 -row $i

        set i [expr $i+1]
    }
}


proc bsg_one_place_fetch {} {


    # imem taken tag mux
    # imem taken index mux  (vertical)

    bsg_rp_group_stack fetch1t [list guts/z_gd/tiles/x_0__y_0__t/proc/fu/ta16_MUX_target_addr_macro_w3_b14/join_w2_b5\
				     guts/z_gd/tiles/x_0__y_0__t/proc/fu/ta26_MUX_target_addr_macro_w3_b4/nand2_w1_b1\
				     guts/z_gd/tiles/x_0__y_0__t/proc/fu/mux_j_br_target_macro_w2_b14/join_w1_b7 \
                                     guts/z_gd/tiles/x_0__y_0__t/proc/fu/MUX_taken_tag_macro_w2_b18/join_w1_b2 \
       ]

    bsg_rp_group_stack fetch1b [list guts/z_gd/tiles/x_0__y_0__t/proc/fu/MUX_taken_imem_index_macro_w2_b12/join_w1_b6]


    bsg_rp_group_stack_hier_vert fetch1 [list bsg_chip::fetch1b bsg_chip::fetch1t]

    # imem bank mux
    # imem save REG
    # imem save mux

    bsg_rp_group_stack fetch2 [list guts/z_gd/tiles/x_0__y_0__t/proc/fu/imem_fi_mux/join_w3_b24 \
                                    guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_save_macro_dff/reg_b23 \
                                    guts/z_gd/tiles/x_0__y_0__t/proc/fu/mux_save_macro_w2_b33/join_w1_b16 \
                                    guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PC_ilw_if_macro_dff/reg_b9  \
                                    guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PC_ilw_id_macro_dff/reg_b9 \
                                    guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_imem_rd_id_macro_dff/reg_b5 \
                                    guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_imemread_macro_dff/reg_b28 \
                               ]
   # j_br_target_id
   # REG_PC_if

   bsg_rp_group_stack fetch0 [list \
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PCrecover_exe_macro_dff/reg_b13 \
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PCrecover_rf_macro_dff/reg_b20\
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/MUX_pc_recover_two_macro_w2_b30/join_w1_b8 \
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PC_rf_macro_dff/reg_b9 \
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/MUX_pc_recover_macro_w2_b30/join_w1_b8\
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_j_br_target_id_macro_dff/reg_b5 \
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/mux_save_out_j_br_target_if_macro_w2_b30/nand2_w1_b7\
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_save_out_j_br_target_if_macro_dff/reg_b9 \
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PC_id_macro_dff/reg_b9 \
                                  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PC_if_macro_dff/reg_b9 \
                                  ]

    #bsg_rp_group_stack fetch1 [list   guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PCrecover_id_macro_dff/reg_b12  guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_ra_id_macro_dff/reg_b14  ]

   # we explicitly do not stack REG_PC_rf, since it should be located far away from the fetch core.
   #
    #bsg_rp_group_stack fetch3 [list guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PC_id_macro_dff/reg_b12 guts/z_gd/tiles/x_0__y_0__t/proc/fu/REG_PC_rf_macro_dff/reg_b11]

    # too packed -- no good.
    #bsg_rp_group_stack_hier fetchA [list bsg_chip::fetch0 bsg_chip::fetch1 bsg_chip::fetch2]

    
}

proc bsg_one_place_nibs {} {
    bsg_rp_group_stack swmemread [list guts/z_gd/tiles/x_0__y_0__t/proc/swmemread_blk/g/fi_datareg/macro_dff/reg_b24 guts/z_gd/tiles/x_0__y_0__t/proc/swmemread_blk/g/fi_elmts/macro_w4_b32/dff_w0_b16 guts/z_gd/tiles/x_0__y_0__t/proc/swmemread_blk/g/fi_bypassmux/macro_w2_b32/nand2_w1_b26  ]

     bsg_rp_group_stack cgni     [list guts/z_gd/tiles/x_0__y_0__t/proc/cgni_blk/g/fi_datareg/macro_dff/reg_b19      guts/z_gd/tiles/x_0__y_0__t/proc/cgni_blk/g/fi_elmts/macro_w4_b32/dff_w1_b19      guts/z_gd/tiles/x_0__y_0__t/proc/cgni_blk/g/fi_bypassmux/macro_w2_b32/join_w1_b30  ]

    bsg_rp_group_stack csti2     [list guts/z_gd/tiles/x_0__y_0__t/proc/csti2_blk/g/fi_datareg/macro_dff/reg_b24     guts/z_gd/tiles/x_0__y_0__t/proc/csti2_blk/g/fi_elmts/macro_w4_b32/dff_w3_b7      guts/z_gd/tiles/x_0__y_0__t/proc/csti2_blk/g/fi_bypassmux/macro_w2_b32/join_w1_b31]


    bsg_rp_group_stack cmni      [list guts/z_gd/tiles/x_0__y_0__t/proc/cmni_blk/g/fi_datareg/macro_dff/reg_b12      guts/z_gd/tiles/x_0__y_0__t/proc/cmni_blk/g/fi_elmts/macro_w4_b32/dff_w2_b16      guts/z_gd/tiles/x_0__y_0__t/proc/cmni_blk/g/fi_bypassmux/macro_w2_b32/join_w1_b11]

    bsg_rp_group_stack csti      [list  guts/z_gd/tiles/x_0__y_0__t/proc/csti_blk/g/fi_datareg/macro_dff/reg_b19 guts/z_gd/tiles/x_0__y_0__t/proc/csti_blk/g/fi_elmts/macro_w4_b32/dff_w2_b7   guts/z_gd/tiles/x_0__y_0__t/proc/csti_blk/g/fi_bypassmux/macro_w2_b32/join_w1_b18]

    bsg_rp_group_stack nib1 [list  guts/z_gd/tiles/x_0__y_0__t/st_netw/sw_proc_st_route_unit_nib1_g_fi_datareg_macro_dff/reg_b25 guts/z_gd/tiles/x_0__y_0__t/st_netw/sw_proc_st_route_unit_nib1_g_fi_elmts_macro_w4_b32/dff_w1_b15 guts/z_gd/tiles/x_0__y_0__t/st_netw/sw_proc_st_route_unit_nib1_g_fi_bypassmux_macro_w2_b32/join_w1_b31]


    bsg_rp_group_stack nib0 [list  guts/z_gd/tiles/x_0__y_0__t/st_netw/sw_proc_st_route_unit_nib0_g_fi_datareg_macro_dff/reg_b25 guts/z_gd/tiles/x_0__y_0__t/st_netw/sw_proc_st_route_unit_nib0_g_fi_elmts_macro_w4_b32/dff_w1_b15 guts/z_gd/tiles/x_0__y_0__t/st_netw/sw_proc_st_route_unit_nib0_g_fi_bypassmux_macro_w2_b32/join_w1_b31]

    bsg_rp_group_stack csto [list guts/z_gd/tiles/x_0__y_0__t/st_netw/nib_csto_g_fi_datareg_macro_dff/reg_b30 guts/z_gd/tiles/x_0__y_0__t/st_netw/nib_csto_g_fi_elmts_macro_w8_b32/dff_w5_b24 guts/z_gd/tiles/x_0__y_0__t/st_netw/nib_csto_g_fi_bypassmux_macro_w2_b32/join_w1_b7]

    bsg_rp_group_stack cmno [list  guts/z_gd/tiles/x_0__y_0__t/hp_dynamic_network/proc_input_NIB_g_fi_datareg_macro_dff/reg_b25 guts/z_gd/tiles/x_0__y_0__t/hp_dynamic_network/proc_input_NIB_g_fi_elmts_macro_w16_b32/dff_w8_b11 guts/z_gd/tiles/x_0__y_0__t/hp_dynamic_network/proc_input_NIB_g_fi_bypassmux_macro_w2_b32/join_w1_b27 ]

    bsg_rp_group_stack cgno [list  guts/z_gd/tiles/x_0__y_0__t/user_dynamic_network/proc_input_NIB_g_fi_datareg_macro_dff/reg_b28 guts/z_gd/tiles/x_0__y_0__t/user_dynamic_network/proc_input_NIB_g_fi_elmts_macro_w16_b32/dff_w13_b26 guts/z_gd/tiles/x_0__y_0__t/user_dynamic_network/proc_input_NIB_g_fi_bypassmux_macro_w2_b32/join_w1_b3]

    bsg_rp_group_stack cSi [list  guts/z_gd/tiles/x_0__y_0__t/st_netw/st1_cSi_g_fi_datareg_macro_dff/reg_b17   guts/z_gd/tiles/x_0__y_0__t/st_netw/st1_cSi_g_fi_elmts_macro_w4_b32/dff_w3_b19 guts/z_gd/tiles/x_0__y_0__t/st_netw/st1_cSi_g_fi_bypassmux_macro_w2_b32/join_w1_b12]

    # fixme missing general Si, memory Si.

    bsg_rp_group_stack gdn_Si [list  guts/z_gd/tiles/x_0__y_0__t/user_dynamic_network/south_input_fi_NIB_g_fi_datareg_macro_dff/reg_b21 guts/z_gd/tiles/x_0__y_0__t/user_dynamic_network/south_input_fi_NIB_g_fi_elmts_macro_w4_b32/dff_w2_b21 guts/z_gd/tiles/x_0__y_0__t/user_dynamic_network/south_input_fi_NIB_g_fi_bypassmux_macro_w2_b32/nand2_w0_b29 ]

    bsg_rp_group_stack mdn_Si [list guts/z_gd/tiles/x_0__y_0__t/hp_dynamic_network/south_input_fi_NIB_g_fi_datareg_macro_dff/reg_b21 guts/z_gd/tiles/x_0__y_0__t/hp_dynamic_network/south_input_fi_NIB_g_fi_elmts_macro_w4_b32/dff_w2_b21 guts/z_gd/tiles/x_0__y_0__t/hp_dynamic_network/south_input_fi_NIB_g_fi_bypassmux_macro_w2_b32/nand2_w0_b29 ]

}

# must be done later, after floorplanning, otherwise ICC throws an error message like this:
# 
# Assertion Failure:
# Expr (logic->x == (1000000000)) was false
#

proc bsg_one_set_rp_coords {} {
 
   set_rp_group_options bsg_chip::csti2 -x_offset 1873  -y_offset 1800 -group_orient FN
    set_rp_group_options bsg_chip::csti -x_offset 1873  -y_offset 2050 -group_orient FN

   # this should align cmni and cgni next to their respective networks
    set_rp_group_options bsg_chip::cmni -x_offset 2043  -y_offset 1800 -group_orient FN
    set_rp_group_options bsg_chip::cgni -x_offset 2043  -y_offset 2050 -group_orient FN

    # lock down lower left hand corner
    set_rp_group_options bsg_chip::bdiom_in -x_offset 2090 -y_offset 2310 -allow_non_rp_cells

   set_rp_group_options bsg_chip::my_mul -x_offset 90 -y_offset 1230 -allow_non_rp_cells

   set_rp_group_options bsg_chip::swmemread -x_offset 1500 -y_offset 1800

   set_rp_group_options bsg_chip::fetch0 -x_offset 1100 -y_offset 3340
   set_rp_group_options bsg_chip::fetch1 -x_offset 1350 -y_offset 3340
   set_rp_group_options bsg_chip::fetch2 -x_offset 1471 -y_offset 3340

   # place fetch unit complex
   #set_rp_group_options bsg_chip::fetchA -x_offset 1100 -y_offset 3500

   #set_rp_group_options bsg_chip::my_mul -x_offset 812 -y_offset 860
   #set_rp_group_options bsg_rp_tsmc_250_rf_w32_b32_2r1w::rf -x_offset 800 -y_offset 2050
}
