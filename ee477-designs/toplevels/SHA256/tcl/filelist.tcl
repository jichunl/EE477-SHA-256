# filelist.tcl
#
# This file defines a list of all files required to synthesize
# and simulate the design.
#


# bsg repo dirs
#
# These envvars define the path to all the cad repos used in the
# flow. These envvars should be set in the  chip repo
# Makefile.design.include file.
#
set bsg_ip_cores_dir         $::env(BSG_IP_CORES_DIR)
set bsg_designs_dir          $::env(BSG_DESIGNS_DIR)
set bsg_designs_target_dir   $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir        $::env(BSG_PACKAGING_DIR)
set bsg_manycore_dir        $::env(BSG_MANYCORE_DIR)


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


# bsg_sverilog_source_files
#
# DO NOT change the name of this variable. This special variable
# is a list of all verilog files needed for the design. The order
# is the order they are elaborated, therefore 'header' verilog
# files should be higher up the list to ensure their definitions
# are elaborated before they are referenced.
#

# TODO - ADD THE TOPLEVEL SVERILOG WRAPPER HERE
set bsg_sverilog_source_files [join "
  $bsg_ip_cores_dir/bsg_misc/bsg_defines.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_pkg.v
  $bsg_ip_cores_dir/bsg_misc/bsg_and.v
  $bsg_ip_cores_dir/bsg_misc/bsg_transpose.v
  $bsg_ip_cores_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $bsg_ip_cores_dir/bsg_misc/bsg_cycle_counter.v
  $bsg_ip_cores_dir/bsg_misc/bsg_round_robin_arb.v
  $bsg_ip_cores_dir/bsg_misc/bsg_arb_fixed.v
  $bsg_ip_cores_dir/bsg_misc/bsg_priority_encode.v
  $bsg_ip_cores_dir/bsg_misc/bsg_priority_encode_one_hot_out.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux_one_hot.v
  $bsg_ip_cores_dir/bsg_misc/bsg_mux.v
  $bsg_ip_cores_dir/bsg_misc/bsg_encode_one_hot.v
  $bsg_ip_cores_dir/bsg_misc/bsg_scan.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down.v
  $bsg_ip_cores_dir/bsg_misc/bsg_circular_ptr.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_up_down_variable.v
  $bsg_ip_cores_dir/bsg_misc/bsg_adder_cin.v
  $bsg_ip_cores_dir/bsg_misc/bsg_nor2.v
  $bsg_ip_cores_dir/bsg_misc/bsg_buf_ctrl.v
  $bsg_ip_cores_dir/bsg_misc/bsg_buf.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_en.v
  $bsg_ip_cores_dir/bsg_misc/bsg_xnor.v
  $bsg_ip_cores_dir/bsg_misc/bsg_imul_iterative.v
  $bsg_ip_cores_dir/bsg_misc/bsg_idiv_iterative_controller.v
  $bsg_ip_cores_dir/bsg_misc/bsg_idiv_iterative.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $bsg_ip_cores_dir/bsg_misc/bsg_counter_clear_up.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_2r1w_sync.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_2r1w_sync_synth.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_banked_crossbar.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_tracker.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte_synth.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync.v
  $bsg_ip_cores_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_two_fifo.v
  $bsg_ip_cores_dir/bsg_noc/bsg_noc_pkg.v
  $bsg_ip_cores_dir/bsg_noc/bsg_noc_links.vh
  $bsg_ip_cores_dir/bsg_noc/bsg_mesh_router.v
  $bsg_ip_cores_dir/bsg_noc/bsg_mesh_stitch.v
  $bsg_ip_cores_dir/bsg_noc/bsg_mesh_router_buffered.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode_with_v.v
  $bsg_ip_cores_dir/bsg_misc/bsg_decode.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_reset.v
  $bsg_ip_cores_dir/bsg_misc/bsg_clkbuf.v
  $bsg_ip_cores_dir/bsg_misc/bsg_dff_reset_en.v
  $bsg_manycore_dir/v/vanilla_bean/alu.v
  $bsg_manycore_dir/v/vanilla_bean/cl_decode.v
  $bsg_manycore_dir/v/vanilla_bean/cl_state_machine.v
  $bsg_manycore_dir/v/vanilla_bean/hobbit.v
  $bsg_manycore_dir/v/vanilla_bean/rf_2r1w_sync_wrapper.v
  $bsg_manycore_dir/v/vanilla_bean/bsg_manycore_proc_vanilla.v
  $bsg_manycore_dir/v/vanilla_bean/imul_idiv_iterative.v
  $bsg_manycore_dir/v/bsg_manycore_hetero_socket.v
  $bsg_manycore_dir/v/bsg_manycore_tile.v
  $bsg_manycore_dir/v/bsg_manycore_mesh.v
  $bsg_manycore_dir/v/bsg_manycore_mesh_node.v
  $bsg_manycore_dir/v/bsg_manycore_links_to_fsb.v
  $bsg_manycore_dir/v/bsg_manycore.v
  $bsg_manycore_dir/v/bsg_manycore_pkt_encode.v
  $bsg_manycore_dir/v/bsg_manycore_pkt_decode.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint.v
  $bsg_manycore_dir/v/bsg_manycore_endpoint_standard.v
  $bsg_manycore_dir/v/bsg_manycore_link_sif_tieoff.v
  $bsg_manycore_dir/v/bsg_manycore_accel_default.v
  $bsg_ip_cores_dir/bsg_misc/bsg_tiehi.v
  $bsg_ip_cores_dir/bsg_misc/bsg_tielo.v
  $bsg_ip_cores_dir/bsg_misc/bsg_thermometer_count.v
  $bsg_ip_cores_dir/bsg_misc/bsg_popcount.v
  $bsg_ip_cores_dir/bsg_misc/bsg_gray_to_binary.v
  $bsg_ip_cores_dir/bsg_misc/bsg_binary_plus_one_to_gray.v
  $bsg_ip_cores_dir/bsg_misc/bsg_rotate_right.v
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
  $bsg_ip_cores_dir/bsg_dataflow/bsg_flatten_2D_array.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_make_2D_array.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_round_robin_fifo_to_fifo.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_sbox.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_scatter_gather.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_fifo_1r1w_narrowed.v
  $bsg_ip_cores_dir/bsg_dataflow/bsg_channel_narrow.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb_murn_gateway.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_in.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_front_side_bus_hop_out.v
  $bsg_ip_cores_dir/bsg_fsb/bsg_fsb.v
  $bsg_designs_dir/modules/bsg_guts_new/bsg_guts.v
  $bsg_designs_dir/modules/bsg_guts_new/bsg_comm_link.v
  $bsg_designs_dir/modules/bsg_guts_new/bsg_comm_link_kernel.v
  $bsg_designs_dir/modules/bsg_guts_new/bsg_comm_link_fuser.v
  $bsg_designs_target_dir/v/bsg_chip.v
  $bsg_designs_target_dir/v/bsg_test_node_client.v
  $bsg_designs_target_dir/v/bsg_assembler.v
  $bsg_designs_target_dir/v/SHA256_compression.v
  $bsg_designs_target_dir/v/SHA256_core.v
  $bsg_designs_target_dir/v/SHA256_message_scheduler.v
  $bsg_designs_target_dir/v/SHA256_node.v
  $bsg_designs_target_dir/v/SHA256_pre_processing.v
  $bsg_designs_target_dir/v/SHA256_Kt_mem.v
  $bsg_designs_target_dir/v/bsg_deassembler.v 
  $bsg_designs_dir/modules/bsg_manycore_1x1/bsg_manycore_1x1_pkg.v
  $bsg_designs_dir/modules/bsg_manycore_1x1/bsg_manycore_client_node.v

"]

