// This is the pre_processing module for message scheduler
//
// input
//
// output
//

module SHA256_pre_processing 
	(input 	[255:0] msg_i
	
	,output [511:0] pre_pro_o
	)

	localparam init_index;
	generate genvar i;
	for (i = 255; i >= 0; i++) begin
		if (msg_i[i] != 0) begin
			init_index = i;
		end
	end
	endgenerate
	localparam k;
	assign k = 512 - init_index - 1 - 1;
	assign pre_pro_o = {msg_i[init_index:0], 1'b1, k'b0};
endmodule
	
