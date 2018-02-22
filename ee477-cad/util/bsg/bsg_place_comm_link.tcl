
set sep /

suppress_message SEL-004
if {[get_flat_cells g/comm_link/kernel/*] != ""} {
    set new_comm_link 1
    set guts_comm_link g${sep}comm_link${sep}kernel${sep}
    set fuser_comm_link g${sep}comm_link${sep}fuser${sep}
    set bao_fifos 10
    puts "new comm link detected"
} else {
    set guts_comm_link g${sep}comm_link${sep}
    set new_comm_link 0
    set fuser_comm_link g${sep}comm_link${sep}
    set bao_fifos 5
    puts "old comm link detected"
}
unsuppress_message SEL-004

set ssi ssi${sep}
set sso sso${sep}

# helper
proc dir_to_sign { dir } {
    if {$dir == "WtoE"} {
        return 1;
    } else {
        return -1;
    }
}

# helper
proc rev_to_sign { rev } {
    return [expr -2*$rev + 1]
}

#########################################################################################################
#
# STD: For TSMC180 the pad ring was rotated and therefore all of the source syncronous move bounds
#      need to rotate around. The version of place_comm_link, place_ssi and place_sso above
#      make a lot of assumptions about where various components are going. The version bellow
#      called place_comm_link_rotate, place_ssi_rotate, and place_sso_rotate are not really
#      rotated version of the same code above but rather are versions of the placement scripts that
#      have less assumptions and therefore can be used when rotated.
#

# This procedure is designed to take an in-order list of cells
# and an IO reference cell and returns a 1-to-1 in-order list
# of move coordinates for the given cell list to place near
# the reference io cell
#
proc origins_near_ref { cell_list io_ref_cell } {

  global bsg_min_x
  global bsg_max_x
  global bsg_min_y
  global bsg_max_y

  set origins     [list]
  set orientation [get_attribute [get_cells -all $io_ref_cell] orientation]
  set x           [bsg_gate_get_x $io_ref_cell]
  set y           [bsg_gate_get_y $io_ref_cell]
  set widths      [get_attribute [get_cells $cell_list] width]
  set heights     [get_attribute [get_cells $cell_list] height]

  for {set i 0} {$i < [llength $cell_list]} {incr i} {

    set w [lindex $widths  $i]
    set h [lindex $heights $i]

    if { $orientation == "E" } {
      # Left Side
      lappend origins [list $bsg_min_x $y]
      set y [expr $y + $h]
    } elseif { $orientation == "S" } {
      # Top Side
      lappend origins [list $x [expr $bsg_max_y - $h]]
      set x [expr $x + $w]
    } elseif { $orientation == "W" } {
      # Right Side
      lappend origins [list [expr $bsg_max_x - $w] $y]
      set y [expr $y + $h]
    } elseif { $orientation == "N" } {
      # Bottom Side
      lappend origins [list $x $bsg_min_y]
      set x [expr $x + $w]
    }

  }

  return $origins

}

# helper
proc fix_cell_list { cell_list } {
  set_attribute -quiet [get_cells $cell_list] is_fixed 1
}


proc bsg_place_ssi_rotate {
  guts_comm_link
  ssi_width       ssi_height
  ch_0_ll_x       ch_0_ll_y
  ch_1_ll_x       ch_1_ll_y
  ch_2_ll_x       ch_2_ll_y
  ch_3_ll_x       ch_3_ll_y
  ssi_ctrl_width  ssi_ctrl_height
  ch_0_ctrl_ll_x  ch_0_ctrl_ll_y
  ch_1_ctrl_ll_x  ch_1_ctrl_ll_y
  ch_2_ctrl_ll_x  ch_2_ctrl_ll_y
  ch_3_ctrl_ll_x  ch_3_ctrl_ll_y
} {

  global ssi

  # place source synchronous input I/O registers
  # as close to the I/O pin as possible.
  #
  foreach letter { A C B D } channel { 0 1 2 3 } {
    # Place valid registers near ncmd pin
    #
    set io_ref_name sdi_${letter}_ncmd_i
    set cell_list [join "${guts_comm_link}ch_${channel}__${ssi}io_valid_0_r_reg
                         ${guts_comm_link}ch_${channel}__${ssi}io_valid_negedge_r_reg
                         ${guts_comm_link}ch_${channel}__${ssi}io_valid_1_r_reg"]
    bsg_gate_strafe $cell_list [origins_near_ref $cell_list $io_ref_name]
    fix_cell_list $cell_list

    # Place io_credit_sent registers near the token pin
    #
    set io_ref_name sdi_${letter}_token_o
    set cell_list [lsort -dictionary [get_attribute [get_cells ${guts_comm_link}ch_${channel}__${ssi}io_credits_sent_r_reg_*_] full_name]]
    bsg_gate_strafe $cell_list [origins_near_ref $cell_list $io_ref_name]
    fix_cell_list $cell_list

    # Go through all 8 data bits of the channel
    #
    for {set i 0} {$i < 8} {incr i} {
      # Place data registers near data pin
      #
      set io_ref_name sdi_${letter}_data_${i}_i
      set cell_list [join "${guts_comm_link}ch_${channel}__${ssi}io_data_0_r_reg_${i}_
                           ${guts_comm_link}ch_${channel}__${ssi}io_data_negedge_r_reg_${i}_
                           ${guts_comm_link}ch_${channel}__${ssi}io_data_1_r_reg_${i}_"]
      bsg_gate_strafe $cell_list [origins_near_ref $cell_list $io_ref_name]
      fix_cell_list $cell_list
    }
  }

  # Create the move-bounds for the 4 SSI channels
  #
  bsg_bound_creator ch_0__ssi [bsg_track_align_x $ch_0_ll_x] \
                              [bsg_track_align_y $ch_0_ll_y] \
                              [bsg_space_round_down_to_align_x $ssi_width] \
                              [bsg_space_round_down_to_align_y $ssi_height]

  bsg_bound_creator ch_1__ssi [bsg_track_align_x $ch_1_ll_x] \
                              [bsg_track_align_y $ch_1_ll_y] \
                              [bsg_space_round_down_to_align_x $ssi_width] \
                              [bsg_space_round_down_to_align_y $ssi_height]

  bsg_bound_creator ch_2__ssi [bsg_track_align_x $ch_2_ll_x] \
                              [bsg_track_align_y $ch_2_ll_y] \
                              [bsg_space_round_down_to_align_x $ssi_width] \
                              [bsg_space_round_down_to_align_y $ssi_height]

  bsg_bound_creator ch_3__ssi [bsg_track_align_x $ch_3_ll_x] \
                              [bsg_track_align_y $ch_3_ll_y] \
                              [bsg_space_round_down_to_align_x $ssi_width] \
                              [bsg_space_round_down_to_align_y $ssi_height]

  global new_comm_link;

  foreach chan { 0 1 2 3 } ctrl_ll_x [list $ch_0_ctrl_ll_x $ch_1_ctrl_ll_x $ch_2_ctrl_ll_x $ch_3_ctrl_ll_x ] ctrl_ll_y [list $ch_0_ctrl_ll_y $ch_1_ctrl_ll_y $ch_2_ctrl_ll_y $ch_3_ctrl_ll_y ] {
      if {$new_comm_link} {
          set control_slave_prefix slv_ch_${chan}_
      } else {
          set control_slave_prefix ch_${chan}__s
      }

      bsg_bound_creator ${control_slave_prefix}_control_slave [bsg_track_align_x $ctrl_ll_x] \
          [bsg_track_align_y $ctrl_ll_y] \
          [bsg_space_round_down_to_align_x $ssi_ctrl_width] \
          [bsg_space_round_down_to_align_y $ssi_ctrl_height]

      update_bounds -name ${control_slave_prefix}_control_slave -add [get_flat_cells */${control_slave_prefix}_io_reset_ss/*]
  }
}


proc bsg_place_sso_rotate {
  guts_comm_link
  sso_width   sso_height
  ch_0_ll_x   ch_0_ll_y
  ch_1_ll_x   ch_1_ll_y
  ch_2_ll_x   ch_2_ll_y
  ch_3_ll_x   ch_3_ll_y
} {

  global sso

  # place source synchronous input I/O registers
  # as close to the I/O pin as possible.
  #
  foreach letter { A B C D } channel { 0 1 2 3 } {
    # Place valid registers near ncmd pin
    #
    set io_ref_name sdo_${letter}_ncmd_o
    set cell_list [join "${guts_comm_link}ch_${channel}__${sso}io_valid_r_o_reg"]
    bsg_gate_strafe $cell_list [origins_near_ref $cell_list $io_ref_name]
    fix_cell_list $cell_list

    # Place clock registers near the sclk pin
    #
    set io_ref_name sdo_${letter}_sclk_o
    set cell_list [join "${guts_comm_link}ch_${channel}__${sso}io_clk_r_o_reg"]
    bsg_gate_strafe $cell_list [origins_near_ref $cell_list $io_ref_name]
    fix_cell_list $cell_list

    # Go through all 8 data bits of the channel
    #
    for {set i 0} {$i < 8} {incr i} {
      # Place data registers near data pin
      #
      set io_ref_name sdo_${letter}_data_${i}_o
      set cell_list [join "${guts_comm_link}ch_${channel}__${sso}io_data_r_o_reg_${i}_"]
      bsg_gate_strafe $cell_list [origins_near_ref $cell_list $io_ref_name]
      fix_cell_list $cell_list
    }
  }

  # Create the move-bounds for the 4 SSO channels
  #
  bsg_bound_creator ch_0__sso [bsg_track_align_x $ch_0_ll_x] \
                              [bsg_track_align_y $ch_0_ll_y] \
                              [bsg_space_round_down_to_align_x $sso_width] \
                              [bsg_space_round_down_to_align_y $sso_height]

  bsg_bound_creator ch_1__sso [bsg_track_align_x $ch_1_ll_x] \
                              [bsg_track_align_y $ch_1_ll_y] \
                              [bsg_space_round_down_to_align_x $sso_width] \
                              [bsg_space_round_down_to_align_y $sso_height]

  bsg_bound_creator ch_2__sso [bsg_track_align_x $ch_2_ll_x] \
                              [bsg_track_align_y $ch_2_ll_y] \
                              [bsg_space_round_down_to_align_x $sso_width] \
                              [bsg_space_round_down_to_align_y $sso_height]

  bsg_bound_creator ch_3__sso [bsg_track_align_x $ch_3_ll_x] \
                              [bsg_track_align_y $ch_3_ll_y] \
                              [bsg_space_round_down_to_align_x $sso_width] \
                              [bsg_space_round_down_to_align_y $sso_height]
}

proc bsg_place_comm_link_rotate {
    ssi_ch0_ll_x       ssi_ch0_ll_y       ssi_ch1_ll_x       ssi_ch1_ll_y       ssi_ch2_ll_x       ssi_ch2_ll_y       ssi_ch3_ll_x       ssi_ch3_ll_y
    ssi_ch0_ctrl_ll_x  ssi_ch0_ctrl_ll_y  ssi_ch1_ctrl_ll_x  ssi_ch1_ctrl_ll_y  ssi_ch2_ctrl_ll_x  ssi_ch2_ctrl_ll_y  ssi_ch3_ctrl_ll_x  ssi_ch3_ctrl_ll_y
    sso_ch0_ll_x       sso_ch0_ll_y       sso_ch1_ll_x       sso_ch1_ll_y       sso_ch2_ll_x       sso_ch2_ll_y       sso_ch3_ll_x       sso_ch3_ll_y
    bao_LL_X           bao_LL_Y           bao_UR_X           bao_UR_Y
} {
    global guts_comm_link
    global fuser_comm_link
    suppress_message MWUI-710

    bsg_unplace_all

    set ssi_width       450
    set ssi_height      250

    set ssi_ctrl_width  451
    set ssi_ctrl_height 95

    set sso_width       350
    set sso_height      64

    bsg_place_ssi_rotate $guts_comm_link                       \
                         $ssi_width         $ssi_height        \
                         $ssi_ch0_ll_x      $ssi_ch0_ll_y      \
                         $ssi_ch1_ll_x      $ssi_ch1_ll_y      \
                         $ssi_ch2_ll_x      $ssi_ch2_ll_y      \
                         $ssi_ch3_ll_x      $ssi_ch3_ll_y      \
                         $ssi_ctrl_width    $ssi_ctrl_height   \
                         $ssi_ch0_ctrl_ll_x $ssi_ch0_ctrl_ll_y \
                         $ssi_ch1_ctrl_ll_x $ssi_ch1_ctrl_ll_y \
                         $ssi_ch2_ctrl_ll_x $ssi_ch2_ctrl_ll_y \
                         $ssi_ch3_ctrl_ll_x $ssi_ch3_ctrl_ll_y

    bsg_place_sso_rotate $guts_comm_link             \
                         $sso_width    $sso_height   \
                         $sso_ch0_ll_x $sso_ch0_ll_y \
                         $sso_ch1_ll_x $sso_ch1_ll_y \
                         $sso_ch2_ll_x $sso_ch2_ll_y \
                         $sso_ch3_ll_x $sso_ch3_ll_y


    # in path
    # --> sbox_in --> bai.rr_fifo_to_fifo --> bai.ring_packet_fifo* --> fsb_hopin --> bsg_murn_converter (bmc no fifo) -->bdiom.deagg -> b64to32ch

    # out path
    # bdiom.agg --> bmc fifo --> fsb_hopout -->bao.ring_packet_fifo* -> bao.rr_fifo_to_fifo -> sbox_out

    # this is part of the BAI (e.g., guts/comm_link/bai/fifos_9__ring_packet_fifo/mem_1r1w/macro_w2_b8/reg_w0_b3)
    puts "\#\# assembling BAI (bai_fifo_in)"
    create_rp_group bai_fifo_in -design bsg_chip -columns 1 -rows 10
    foreach i [list 0 1 2 3 4 5 6 7 8 9] {
        add_to_rp_group bsg_chip::bai_fifo_in -hier [get_attribute ${fuser_comm_link}bai/fifos_${i}__ring_packet_fifo/mem_1r1w/macro_w2_b8/reg_w1_b2 rp_group_name] -column 0 -row ${i}
    }

    # this is part of the BAO (e.g. guts/comm_link/bao/fifos_3__ring_packet_fifo/mem_1r1w/macro_w2_b8/reg_w1_b3)

    global bao_fifos
    create_rp_group bao_fifo_out -design bsg_chip -columns 1 -rows $bao_fifos
    for { set i 0 } {$i < $bao_fifos} {incr i} {
        add_to_rp_group bsg_chip::bao_fifo_out -hier [get_attribute ${fuser_comm_link}bao/fifos_${i}__ring_packet_fifo/mem_1r1w/macro_w2_b8/reg_w1_b1 rp_group_name]  -column 0 -row ${i}
    }


    # bdiom
    set_rp_group_options bsg_chip::bao_fifo_out  -group_orient FN

    puts "\#\# assembling sbox_out and sbox_in"
    create_rp_group sbox_out -design bsg_chip -columns 1 -rows 4
    create_rp_group sbox_in  -design bsg_chip -columns 1 -rows 4
    foreach i [list 0 1 2 3] {
        add_to_rp_group bsg_chip::sbox_out -hier [get_attribute   ${fuser_comm_link}sbox/sbox_${i}__pipe_out_outfifo/mem_1r1w/macro_w2_b8/reg_w1_b5 rp_group_name] -column 0 -row ${i}
        add_to_rp_group bsg_chip::sbox_in  -hier [get_attribute   ${fuser_comm_link}sbox/sbox_${i}__pipe_in_infifo/mem_1r1w/macro_w2_b8/reg_w0_b5  rp_group_name] -column 0 -row ${i}
    }

    foreach chan [list 0 1 2 3] {
        puts "\#\# assembling ssi syn ${chan}"
        create_rp_group ssi_${chan}_syn -design bsg_chip -columns 3 -rows 1
        add_to_rp_group bsg_chip::ssi_${chan}_syn -hier [all_rp_hierarchicals [get_attribute ${guts_comm_link}ch_${chan}__ssi/bapg/ptr_sync/p_z_blss/bsg_SYNC_2_r_reg_5_ rp_group_name]] -column 0 -row 0
        add_to_rp_group bsg_chip::ssi_${chan}_syn -hier [all_rp_hierarchicals [get_attribute ${guts_comm_link}ch_${chan}__ssi/baf/bapg_wr/ptr_sync/p_z_blss/bsg_SYNC_2_r_reg_5_ rp_group_name]]  -column 1 -row 0
        add_to_rp_group bsg_chip::ssi_${chan}_syn -hier [all_rp_hierarchicals [get_attribute ${guts_comm_link}ch_${chan}__ssi/baf/bapg_rd/ptr_sync/p_z_blss/bsg_SYNC_2_r_reg_5_ rp_group_name]]  -column 2 -row 0
    }

    foreach i [list 0 1 2 3] {
        puts "\#\# assembling ssi_${i}"
        create_rp_group ssi_${i} -design bsg_chip -columns 3 -rows 1
        add_to_rp_group bsg_chip::ssi_${i} -hier [get_attribute ${guts_comm_link}ch_${i}__ssi/twofer/mem_1r1w/macro_w2_b8/reg_w0_b6 rp_group_name]       -column 2 -row 0
        add_to_rp_group bsg_chip::ssi_${i} -hier [get_attribute ${guts_comm_link}ch_${i}__ssi/baf/ctrl_MSYNC_1r1w/macro_w32_b2/reg_w17_b1 rp_group_name] -column 1 -row 0
        add_to_rp_group bsg_chip::ssi_${i} -hier [get_attribute ${guts_comm_link}ch_${i}__ssi/baf/MSYNC_1r1w/macro_w32_b16/reg_w5_b0 rp_group_name]      -column 0 -row 0
    }

    # guts/comm_link/bao/fifos_2__ring_packet_fifo/empty_r_reg

#    create_rp_group bao_fifo_valid -design bsg_chip -columns 1 -rows 10
#    foreach i [list 0 1 2 3 4 5 6 7 8 9]

    puts "\#\# assembling bao fifos valids"
    create_rp_group bao_fifo_valid -design bsg_chip -columns 1 -rows 5
    foreach i [list 0 1 2 3 4] {
        add_to_rp_group bsg_chip::bao_fifo_valid -leaf ${fuser_comm_link}bao/fifos_${i}__ring_packet_fifo/empty_r_reg -row $i
    }

    puts "\#\# assembling bai fifo valids"
    create_rp_group bai_fifo_valid -design bsg_chip -columns 1 -rows 10
    foreach i [list 0 1 2 3 4 5 6 7 8 9] {
        add_to_rp_group bsg_chip::bai_fifo_valid -leaf ${fuser_comm_link}bai/fifos_${i}__ring_packet_fifo/empty_r_reg -row $i
    }

    check_rp_groups -all


    bsg_fix_all_placed
    unsuppress_message MWUI-710
}

#
#########################################################################################################

proc bsg_place_comm_link_guts { ofs_x ofs_y { horiz 0 } } {
    set bai_height 480
    set bai_width  400
    set bao_width  340
    set sbox_width 100
    set sbox_height 220
    set fsb_hop_width 60
    set node_width 100
    set node_sep 100
    global new_comm_link

    suppress_message MWUI-710

    bsg_bound_creator_abs_list bai_rr      [list bai*ready_rr   ]      [expr $ofs_x + $sbox_width + $bai_width/4]                           [expr $ofs_y + $sbox_height*3/4]  [expr $ofs_x+$sbox_width+$bai_width-$fsb_hop_width] [expr $ofs_y + $sbox_height*5/4]
    bsg_bound_creator_abs_list bai_fifo    [list *bai*fifos*mem_1r1w*macro*]  [expr $ofs_x + $sbox_width+$bai_width - $fsb_hop_width]                [expr $ofs_y + 0]  [expr $ofs_x + $sbox_width + $bai_width] [expr $ofs_y + $bai_height]

    update_bounds -name bai_rr -add [get_flat_cells -quiet *bai*oc*c_ptr/ptr_r*]

    bsg_bound_creator_abs_list sbox_in     [list sbox*__pipe_in ]      [expr $ofs_x + 0]                                     [expr $ofs_y + $sbox_height/2]  [expr $ofs_x + $sbox_width]              [expr $ofs_y + $sbox_height*3/2]
    bsg_bound_creator_abs_list bai         [list bai            ]      [expr $ofs_x + $sbox_width]                           [expr $ofs_y + 0]  [expr $ofs_x + $sbox_width + $bai_width - $fsb_hop_width] [expr $ofs_y + $bai_height]
    bsg_bound_creator_abs_list fsb_hop_in  [list  *fsb_node_0__hopin*] [expr $ofs_x + $sbox_width+$bai_width]                [expr $ofs_y + 0]  [expr $ofs_x + $sbox_width + $bai_width + $fsb_hop_width] [expr $ofs_y + $bai_height]
    # mbt fix
    bsg_bound_creator_abs_list node_in     [list *n_0__clnt*fifo_in*]  [expr $ofs_x + $sbox_width+$bai_width+$fsb_hop_width+$node_sep] [expr $ofs_y + 0]  [expr $ofs_x + $sbox_width + $bai_width + $fsb_hop_width + $node_width + $node_sep] [expr $ofs_y + $bai_height]

    if {$horiz == 1} {
        set out_ofs_x [expr $ofs_x + $bai_width + $sbox_width + $fsb_hop_width + $node_sep]
        set out_ofs_y [expr $ofs_y]
    } else {
        set out_ofs_x [expr $ofs_x]
        set out_ofs_y [expr $ofs_y + $bai_height]
    }

    bsg_bound_creator_abs_list bao_rr      [list bao*ready_rr   ]       [expr $out_ofs_x + $sbox_width + $bao_width/4]                           [expr $out_ofs_y + $sbox_height*3/4]  [expr $out_ofs_x+$sbox_width+($bao_width*10)/16] [expr $out_ofs_y + $sbox_height*5/4]

    # mbt fix -- narrowing is not in the new comm link
    if {$new_comm_link==0} {
	bsg_bound_creator_abs_list nrw_nrw     [list *comm_link*nrw_nrw*]   [expr $out_ofs_x + $sbox_width+$bao_width - $fsb_hop_width]                [expr $out_ofs_y + 0]  [expr $out_ofs_x + $sbox_width + $bao_width] [expr $out_ofs_y + $bai_height]
    }

    bsg_bound_creator_abs_list sbox_out    [list sbox*__pipe_out]       [expr $out_ofs_x + 0]                                     [expr $out_ofs_y + $sbox_height/2] [expr $out_ofs_x + $sbox_width]                                             [expr $out_ofs_y + $sbox_height*3/2]
    bsg_bound_creator_abs_list bao         [list bao*           ]       [expr $out_ofs_x + $sbox_width]                           [expr $out_ofs_y] [expr $out_ofs_x + $sbox_width + $bao_width]                                [expr $out_ofs_y + $bai_height ]

    # NB: these should be captured by the rule above; but live in comm link. if we update
    # the above rule to be more specific, then we will have to readd these rules back
    #update_bounds -name bao -add [get_flat_cells -quiet  *core_top_active_channel_bao_r*]
    #update_bounds -name bai -add [get_flat_cells -quiet  *core_top_active_channel_bai_r*]

    bsg_bound_creator_abs_list fsb_hop_out [list  *fsb_node_0__hopout*] [expr $out_ofs_x + $sbox_width+$bao_width]                [expr $out_ofs_y] [expr $out_ofs_x + $sbox_width + $bao_width + $fsb_hop_width]               [expr $out_ofs_y + $bai_height]

    # mbt fix -- this is not mandatory in many nodes
    bsg_bound_creator_abs_list node_out    [list *n_0__clnt*fifo_out*]  [expr $out_ofs_x + $sbox_width+$bao_width+$fsb_hop_width] [expr $out_ofs_y] [expr $out_ofs_x + $sbox_width + $bao_width + $fsb_hop_width + $node_width] [expr $out_ofs_y + $bai_height]

    bsg_bound_creator_abs_list sbox_reset  [list sbox]                  [expr $ofs_x +     0]                                     [expr $ofs_y+ $sbox_height/2  ] [expr $ofs_x + $sbox_width] [expr $out_ofs_y + $sbox_height*3/2]


    update_bounds -name bai_rr -add [get_flat_cells -quiet *out_to_core_sync_calib_done*]

    # mbt fix -- these reset signals are not in new comm link
    if {$new_comm_link==0} {
	update_bounds -name bai_rr -add [get_flat_cells -quiet *cr_0__core_calib_reset_fanout_reg*]
	update_bounds -name sbox_reset -add [get_flat_cells -quiet *cr_1__core_calib_reset_fanout_reg*]
	update_bounds -name bao_rr -add [get_flat_cells -quiet *cr_2__core_calib_reset_fanout_reg*]
	update_bounds -name bai_rr -add [get_flat_cells -quiet *cr_3__core_calib_reset_fanout_reg*]
	update_bounds -name nrw_nrw -add [get_flat_cells -quiet *cr_4__core_calib_reset_fanout_reg*]
	update_bounds -name fsb_hop_out -add [get_flat_cells -quiet *cr_5__core_calib_reset_fanout_reg*]
    }
    unsuppress_message MWUI-710
}
