# filelist.tcl
#
# This file defines a list of all additional files required to
# run the design using this testbench. Only additional files that
# are not required by the main design need to be list here, however
# duplicated files should not cause problems.
#


# bsg repo dirs
#
# These envvars define the path to all the cad repos used in the
# flow. These envvars should be set in the  chip repo
# Makefile.design.include file.
#
set bsg_ip_cores_dir         $::env(BSG_OUT_DIR)/bsg_ip_cores
set bsg_designs_dir          $::env(BSG_OUT_DIR)/ee477-designs
set bsg_designs_target_dir   $::env(BSG_OUT_DIR)/ee477-designs/toplevels/$::env(BSG_DESIGNS_TARGET)
set bsg_packaging_dir        $::env(BSG_OUT_DIR)/ee477-packaging
set bsg_manycore_dir        $::env(BSG_OUT_DIR)/bsg_manycore
set bsg_boards_dir        $::env(BSG_OUT_DIR)/boards


# bsg packaging vars
#
# These envvars define while files should be found ensure the correct
# packaging and pinouts are used. These envvars should be set in the
# chip repo Makefile.design.include file.
#
set bsg_packaging_foundry    $::env(BSG_PACKAGING_FOUNDRY)
set bsg_pinout               $::env(BSG_PINOUT)
set bsg_pinout_foundry       $::env(BSG_PINOUT_FOUNDRY)
set bsg_pinout_iopad_mapping $::env(BSG_PINOUT_IOPAD_MAPPING)

# bsg_testing_source_files
#
# DO NOT change the name of this variable. This special variable
# is a list of additional files used throughout the testbench
# required to simulate the design.
#
set trace_source_files [list]
for {set i 0} {$i < 16} {incr i} {
  set fname $bsg_designs_target_dir/testing/v/bsg_trace_master_${i}_rom.v
  if {[file exists $fname]} {
    lappend trace_source_files $fname
  }
}

set bsg_testing_source_files [join "
 $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
 $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_pkg.v
 $bsg_ip_cores_dir/bsg_noc/bsg_noc_pkg.v
 $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_io_complex.v
 $bsg_manycore_dir/testbenches/common/v/bsg_manycore_spmd_loader.v
 $bsg_manycore_dir/testbenches/common/v/bsg_nonsynth_manycore_monitor.v
 $bsg_manycore_dir/testbenches/common/v/bsg_manycore_vscale_pipeline_trace.v
 $bsg_ip_cores_dir/bsg_misc/bsg_cycle_counter.v
 $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_clock_gen.v
 $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_reset_gen.v
 $bsg_ip_cores_dir/bsg_test/test_bsg_data_gen.v
 $bsg_ip_cores_dir/bsg_comm_link/test_bsg_comm_link_checker.v
 $bsg_boards_dir/pcb/double_trouble/v/bsg_double_trouble_pcb.v
 $bsg_boards_dir/pcb/double_trouble/v/bsg_two/bsg_gateway_socket.v
 $bsg_boards_dir/pcb/double_trouble/v/bsg_two/bsg_asic_socket.v
 $bsg_designs_target_dir/testing/v/bsg_gateway_chip.v
 $bsg_designs_dir/modules/bsg_manycore_1x1/bsg_test_node_master.v
 $trace_source_files
    $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_node_trace_replay.v
 $bsg_designs_dir/modules/bsg_guts/bsg_guts.v
 $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master.v
 $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_master_master.v
 $bsg_ip_cores_dir/bsg_misc/bsg_wait_cycles.v
 $bsg_ip_cores_dir/bsg_misc/bsg_wait_after_reset.v
 $bsg_ip_cores_dir/bsg_test/bsg_nonsynth_val_watcher_1p.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_flatten_2D_array.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_make_2D_array.v
 $bsg_ip_cores_dir/bsg_comm_link/bsg_comm_link.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_scan.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff.v
  $bsg_ip_cores_dir/bsg_misc/bsg_thermometer_count.v
  $bsg_ip_cores_dir/bsg_misc/bsg_popcount.v
  $bsg_ip_cores_dir/bsg_misc/bsg_gray_to_binary.v
  $bsg_ip_cores_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_credit_counter.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_fifo.v
  $bsg_ip_cores_dir/bsg_async/bsg_async_ptr_gray.v
  $bsg_ip_cores_dir/bsg_async/bsg_launch_sync_sync.v
  $bsg_ip_cores_dir/bsg_async/bsg_sync_sync.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_assembler_in.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_assembler_out.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_channel_control_slave.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_input.v
  $bsg_ip_cores_dir/bsg_comm_link/bsg_source_sync_output.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_fifo_to_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_sbox.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_scatter_gather.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_two_fifo.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_murn_gateway.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_in.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_out.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w_synth.v
 $bsg_manycore_dir/v/bsg_manycore_links_to_fsb.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_in.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_out.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_narrowed.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
 $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_tracker.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_narrow.v
  $bsg_ip_cores_dir/bsg_misc/bsg_rotate_right.v
 $bsg_manycore_dir/v/bsg_manycore_endpoint_standard.v
 $bsg_manycore_dir/v/bsg_manycore_endpoint.v
 $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down.v
 $bsg_manycore_dir/v/bsg_manycore_pkt_decode.v
 $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down_variable.v
 $bsg_ip_cores_dir/bsg_misc/bsg_round_robin_arb.v
 $bsg_ip_cores_dir/bsg_misc/bsg_crossbar_o_by_i.v
 $bsg_ip_cores_dir/bsg_misc/bsg_counter_clear_up.v
 $bsg_ip_cores_dir/bsg_misc/bsg_decode_with_v.v
 $bsg_ip_cores_dir/bsg_misc/bsg_decode.v
 $bsg_ip_cores_dir/bsg_misc/bsg_mux_one_hot.v  
 $bsg_designs_dir/modules/bsg_manycore_1x1/bsg_manycore_1x1_pkg.v
 $bsg_designs_dir/modules/bsg_manycore_1x1/bsg_manycore_master_node.v
 $bsg_designs_dir/modules/bsg_manycore_1x1/roms/boot/bsg_manycore_boot_node_rom.v
 $bsg_designs_dir/modules/bsg_manycore_1x1/roms/gcd/bsg_manycore_io_complex_rom.v

"]

