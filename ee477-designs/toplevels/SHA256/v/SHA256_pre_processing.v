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
	
