/**
 * This file is used to instantiate all of the FSB master
 * nodes on the gateway chip. This specific file will instantiate
 * a trace-replay and a trace-rom for each node. The trace-rom
 * needs to have the module name bsg_trace_master_N_rom where
 * N is the master node ID.
 */

`define bsg_trace_master_n_rom(n)                                \
  bsg_trace_master_``n``_rom #(.width_p(rom_data_width_lp)       \
                              ,.addr_width_p(rom_addr_width_lp)) \
    trace_rom_``n``                                              \
      (.addr_i(rom_addr_li)                                      \
      ,.data_o(rom_data_lo));

module bsg_test_node_master

    import bsg_fsb_pkg::*;

 #(parameter ring_width_p="inv"
  ,parameter master_id_p="inv"
  ,parameter client_id_p="inv"
  )

  (input  clk_i
  ,input  reset_i
  ,input  en_i
  
  ,input                     v_i
  ,input  [ring_width_p-1:0] data_i
  ,output                    ready_o
  
  ,output                    v_o
  ,output [ring_width_p-1:0] data_o
  ,input                     yumi_i
  );
    
  logic done_lo;

  if (master_id_p == 0 || master_id_p == 1) begin

    // Each FSB packet is ring_width_p bits wide (usually 80) but
    // in this file, each master talks to the client of the same
    // id so the 4-bit dest id is automatically calculated and
    // does not need to be specified in the trace.
    localparam trace_width_lp = ring_width_p - 4;

    // Arbitrarily large so we don't run out of addresses
    localparam rom_addr_width_lp = 32;

    // Added 4 bits for the trace-replay command
    localparam rom_data_width_lp = 4 + trace_width_lp;

    // Wires from ROM to trace replay
    logic [rom_addr_width_lp-1:0] rom_addr_li;
    logic [rom_data_width_lp-1:0] rom_data_lo;

    // Right now, the total num of nodes that the FSB supports
    // is 16, so I just 
    if (master_id_p == 0) begin
      `bsg_trace_master_n_rom(0);
    end else if (master_id_p == 1) begin
      `bsg_trace_master_n_rom(1);
    end

    // Data out of the trace replay. The dest_id which is automatically
    // calculated will be prepended to this and sent out the module.
    logic [trace_width_lp-1:0] data_lo;

    // Done signal from trace-replay (cmd=3). Once each trace replay has
    // asserted this singal, the simulation will $finish;
    //logic done_lo;

    // The infamous trace-replay
    bsg_fsb_node_trace_replay #( .ring_width_p(trace_width_lp), .rom_addr_width_p(rom_addr_width_lp) )
      trace_replay
        (.clk_i      (clk_i)
        ,.reset_i    (reset_i)
        ,.en_i       (en_i)

        /* rom connections */
        ,.rom_addr_o (rom_addr_li)
        ,.rom_data_i (rom_data_lo)

        /* input channel */
        ,.v_i        (v_i)
        ,.data_i     (data_i[0+:trace_width_lp])
        ,.ready_o    (ready_o)

        /* output channel */
        ,.v_o        (v_o)
        ,.data_o     (data_lo)
        ,.yumi_i     (yumi_i)

        /* signals */
        ,.done_o     (done_lo)
        ,.error_o    ());

    // Add the dest ID infront of the data out. The dest ID is the
    // same ID as the master_id.
    assign data_o = {(4)'(master_id_p), data_lo};

  end else if (master_id_p == 2) begin

    assign done_lo = mc_master_node.finish_lo;

    bsg_manycore_master_node #(.ring_width_p(ring_width_p), .master_id_p(master_id_p), .client_id_p(client_id_p))
      mc_master_node
        (.clk_i      (clk_i)
        ,.reset_i    (reset_i)
        ,.en_i       (en_i)

        /* input channel */
        ,.v_i        (v_i)
        ,.data_i     (data_i)
        ,.ready_o    (ready_o)

        /* output channel */
        ,.v_o        (v_o)
        ,.data_o     (data_o)
        ,.yumi_i     (yumi_i));
  end

endmodule

