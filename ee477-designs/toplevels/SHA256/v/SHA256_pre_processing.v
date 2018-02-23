// This is the pre_processing module for message scheduler
//
// input
//
// output
//

module SHA256_pre_processing #(parameter ring_width_p = "inv") 
	(input 	[ring_width_p:0] msg_i
	
	,output [511:0] pre_proc_o
	);
	
	reg [511:0] pre_proc_r;
	
	assign pre_proc_r = 512'b0;

	integer init_index = 255;
	genvar i;
	generate
	for (i = 255; i >= 0; i++) begin
		if (msg_i[i] != 0) begin
			assign init_index = i;
		end
	end
	endgenerate
	
	genvar j;
	generate
	for (j = init_index; j >= 0; j--) begin
		assign pre_proc_r[511 - (init_index - j)] = msg_i[j];
	end
	endgenerate
	assign pre_proc_r [510 - init_index] = 1'b1;
	assign pre_proc_o = pre_proc_r;
endmodule
	
