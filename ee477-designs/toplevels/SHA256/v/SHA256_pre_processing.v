// This is the pre_processing module for message scheduler
//
// input
//
// output
//

module SHA256_pre_processing
	(input 	[255:0] msg_i
	,input		clk_i
	,input		v_i
	,input 		reset_i
	,input		yumi_i
	,output 	ready_o
	,output		v_o
	,output logic 	[511:0] pre_proc_o
	);
	
	/*
	reg [511:0] pre_proc_init, pre_proc_r, pre_proc_r_r;
	/*
	integer init_index = 255;
	genvar i;
	generate
	for (i = 255; i >= 0; i--) begin
		if (msg_i[i] != 1'b0) begin
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
	assign pre_proc_o = pre_proc_r;*/
	/*
	assign pre_proc_init[511:0] = {msg_i[255:0], 1'b1, 255'b0};
	
	
	logic start;
	assign start = (pre_proc_r != pre_proc_r_r);
	
	always_ff @(posedge clk_i) begin
		if (start) begin
			pre_proc_r <= pre_proc_init;
		end else begin
			pre_proc_r <= pre_proc_r_r << 1;
			pre_proc_r_r <= pre_proc_r;
		end	
	end*/
	/*
	always @(posedge clk_i) begin
		while (pre_proc_r[511] == 0) begin
			pre_proc_r = pre_proc_r_r << 1;
			pre_proc_r_r = pre_proc_r;
		end
	end*/
	// assign pre_proc_o = pre_proc_r;
	//
	//
	//
	//
	//
	//
	//
	// control logic
	typedef enum [1:0] {eWait, eBusy, eDone} state_e;
	state_e state_n, state_r;
	
	assign v_o = (state_r == eDone);
	assign ready_o = ((v_o & yumi_i) | reset_i) & (state_r == eWait);

	always_ff @(posedge clk_i) begin
		state_r <= reset_i ? eWait : state_r;
	end
	
	logic [511:0] pre_proc_r,  pre_proc_shift;
	assign pre_proc_shift = pre_proc_r << 1;
	/*
	always_ff @(posedge clk_i) begin
		if (state_n != eBusy) begin
			pre_proc_r <= pre_proc_r_r;
		end
	end
*/
	always_comb begin
		unique case(state_r)
			eWait: begin
				if (v_i & ready_o) begin
					state_n = eBusy;
					pre_proc_r = {msg_i[255:0], 1'b1, 255'b0};
				end else begin
					state_n = eWait;
				end
			end

			eBusy: begin
				if (pre_proc_r[511] == 0) begin
					pre_proc_r = pre_proc_shift;
					state_n = eBusy;
				end else begin
					state_n = eDone;
					pre_proc_o = pre_proc_r;
				end
			end
			
			eDone: begin
				if (yumi_i) begin
					state_n = eWait;
				end	
			end
			
			default: begin
				state_n = eWait;
			end

		endcase
	end

endmodule
	
