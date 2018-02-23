// This is the SHA256_core module which combines pre-processing, message
// message scheduler and comp[ression together
//
// input:
// 	clk_i:		the clock that this module runs on
// 	reset_i:	the reset from fsb
// 	en_i:		the enable line from fsb
// 	v_i:		the signal that tells the input data is valid
// 	yumi_i:		the signal that indicate the outside world is ready to
// 			accept our output data
//  	msg_i:		the input message for SHA256 core to hash
//
// output:
// 	ready_o: 	indicates that our output put
// 	v_o:		indicates that this module has produced valid outputfe
// 	digest_o:	the result of hashing

module SHA256_core 
	(input 				clk_i
	,input 				reset_i
	,input 				en_i
	,input 				v_i
	,input 				yumi_i
	,input	[255:0]			msg_i

	,output 			ready_o
	,output 			v_o
	,output [255:0]			digest_o
	);

	// initial hashing values for SHA256
	reg [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
	
	assign h0 = 32'h6a09e667;
	assign h1 = 32'hbb67ae85;
	assign h2 = 32'h3c6ef372;
	assign h3 = 32'ha54ff53a;
	assign h4 = 32'h510e527f;
	assign h5 = 32'h9b05688c;
	assign h6 = 32'h1f83d9ab;
	assign h7 = 32'h5be0cd19;
	
	
	wire 	[511:0] 	pre_proc_msg;
	reg 	[63:0][31:0] 	Wt_ary;	 
	reg 	[255:0]    	digest_r;
	reg     [5:0]		cycle_counter_r;
	reg	[31:0]		Kt_r;
	reg	[31:0]		Wt_r;
	reg	[255:0]		msg_r;	

	reg			init_r, yumi_pre_proc, ready_pre_proc, v_pre_proc;
	
	SHA256_Kt
		Kt	(.addr(cycle_counter_r)
			,.Kt_o(Kt_r)
			);	
	
	SHA256_pre_processing 
		pre_proc (.msg_i(msg_i)
			 ,.clk_i(clk_i)
			 ,.reset_i(reset_i)
			 ,.v_i(v_i)
			 ,.yumi_i(yumi_pre_proc)
			 ,.ready_o(ready_pre_proc)
			 ,.v_o(v_pre_proc)
			 ,.pre_proc_o(pre_proc_msg)
			 );

	SHA256_message_scheduler
		msg_sch	(.M_i(pre_proc_msg)
			,.clk_i(clk_i)
			,.reset_i(reset_i)
			,.init_i(init_r)
			,.Wt_o(Wt_ary)
			);

	SHA256_compression
		comp	(.message_i({msg_r})
			,.Kt_i(Kt_r)
			,.Wt_i(Wt_r)
			,.digest_o(digest_r)
			);
	
	// define cases
	typedef enum [1:0] {eWait, eBusy, eDone} state_e;
	
	state_e substate_next, substate_r;	
	
	// State register
	always_ff @(posedge clk_i)
		substate_r <= reset_i ? eWait : substate_next;

	assign v_o = (substate_r == eDone);
	assign ready_o = (substate_r == eWait);
	

	
	always_comb
		unique case(substate_r)
			eWait: begin // Waiting for the input
				if (v_i & ready_o) begin
					substate_next = eBusy;
					msg_r = {h7, h6, h5, h4, h3, h2, h1, h0};
					cycle_counter_r = 0;
					Wt_r = Wt_ary[0][31:0];
				end else begin
					substate_next = eWait;
				end
		 	end
		
			eBusy: begin // Calculating the hash value
				if (cycle_counter_r < 64) begin
					substate_next = eBusy;
					msg_r = digest_r;
					Wt_r = Wt_ary[cycle_counter_r];
				end else begin
					substate_next = eDone;
				end
			end

			eDone: begin // Done with the calculation
				if (yumi_i) begin
					substate_next = eWait;
				end
									
			end

			default: begin
				if (reset_i) begin
					substate_next = eWait;
				end
			end
		endcase
endmodule


