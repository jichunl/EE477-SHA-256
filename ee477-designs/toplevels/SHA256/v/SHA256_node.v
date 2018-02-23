//This is the wrapper for SHA256_core and assembler
//
module SHA256_node #(parameter ring_width_p = "inv"
		    ,parameter id_p="inv")
	(input	clk_i
	,input	reset_i
	,input 	en_i
	,input	v_i
	,input 	yumi_i
	,input  [ring_width_p - 1:0] data_i
	,output	ready_o
	,output v_o
	,output	[255:0]	data_o
	);
	
	logic msg_ready, msg_v, core_ready;
	reg	[255:0]	msg;
	
	bsg_assembler
		asb	(.clk_i(clk_i)
			,.reset_i(reset_i)
			,.en_i(en_i)
			,.v_i(v_i)
			,.data_i(data_i)
			,.ready_o(msg_ready)
			,.v_o(msg_v)
			,.data_o(msg)
			,.yumi_i(core_ready)
			);
	
	SHA256_core
		core	(.clk_i(clk_i)
			,.reset_i(reset_i)
			,.en_i(en_i)
			,.v_i(msg_v)
			,.yumi_i(yumi_i)
			,.msg_i(msg)
			,.ready_o(core_ready)
			,.v_o(v_o)
			,.digest_o(data_o)
			);
endmodule
