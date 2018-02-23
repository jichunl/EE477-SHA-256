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
	,input	[511:0]			msg_i

	,output 			ready_o
	,output 			v_o
	,output [255:0]			digest_o
	);

	// initial hashing values for SHA256
	//reg [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
	//reg [31:0] a, b, c, d, e, f, g, h;
	//reg [31:0] h0_n, h1_n, h3_n, h4_n, h5_n, h6_n, h7_n;
	//reg [31:0] a_n, b_n, c_n, d_n, e_n, f_n, g_n, h_n;
	
	parameter SHA256_H0 = 32'h6a09e667;
	parameter SHA256_H1 = 32'hbb67ae85;
	parameter SHA256_H2 = 32'h3c6ef372;
	parameter SHA256_H3 = 32'ha54ff53a;
	parameter SHA256_H4 = 32'h510e527f;
	parameter SHA256_H5 = 32'h9b05688c;
	parameter SHA256_H6 = 32'h1f83d9ab;
	parameter SHA256_H7 = 32'h5be0cd19;
	
	parameter msg_init = {SHA256_H7, SHA256_H6, SHA256_H5, SHA256_H4
			     ,SHA256_H3, SHA256_H2, SHA256_H1, SHA256_H0
			     };


	reg 	[255:0]    	digest_r;
	reg	[31:0]		Kt_r;
	reg	[31:0]		Wt_r;
	

	// data flow
	reg	[255:0]		msg_r, msg_n;
	
	// control logic
	reg			v_r, v_n;
	assign v_o = v_r;
	reg	[5:0]	cycle_counter, cycle_counter_n;
	assign cycle_counter_n = cycle_counter + 1'b1;
	reg msg_sch_init;
	assign msg_sch_init = (state_n == eBusy);


	// state
	typedef enum [1:0] {eWait, eBusy, eDone} state_e;
	state_e substate_next, substate_r;	
	
	

	SHA256_Kt_mem
		Kt_mem	(.addr(cycle_counter)
			,.Kt_o(Kt_r)
			);	
	


	SHA256_message_scheduler
		msg_sch	(.M_i(msg_i)
			,.clk_i(clk_i)
			,.reset_i(reset_i)
			,.v_i(msg_sch_init)
			,.Wt_o(Wt_r)
			);

	SHA256_compression
		comp	(.message_i({msg_r})
			,.Kt_i(Kt_r)
			,.Wt_i(Wt_r)
			,.digest_o(digest_r)
			);

	always @(posedge clk_i) begin
		if (reset_i) begin
			state_r <= eWait;
			cycle_counter <= 6'b0;
			msg_r <= 256'b0;
			v_r <= 1'b0;
		end else begin
			state_r <= state_n;
			cycle_counter <= cycle_counter_n;
			msg_r <= msg_n;
			v_r <= v_n;
		end
	end
	
	always_comb begin
		case(state_r)
			eWait: begin
				if (raedy_o & v_i) begin
					state_n = eBusy;
					msg_n = msg_init;
					v_n = 1'b0;
				end
			end
			
			eBusy: begin
				if (cycle_counter == 64) begin
					state_n = eDone;
					digest_o = digest_r;
					v_n = 1'b1;
				end else begin
					state_n = eBusy;
					v_n = 1'b0;
					msg_n = digest_r;
				end
			end

			eDone: begin
				if (yumi_i) begin
					state_n = eWait;
					cycle_counter_n = 6'b0;
				end
			end
			
			default: begin
				state_n = eWait;
			end
		endcase
	end



endmodule
		/*
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
	*/	

	/*
	// define cases
	typedef enum [1:0] {eWait, eBusy, eDone} state_e;
	
	state_e substate_next, substate_r;	
	
	// State register
	always_ff @(posedge clk_i)
		substate_r <= reset_i ? eWait : substate_next;

	assign v_o = (substate_r == eDone);
	assign ready_o = (substate_r == eWait);
	

	/*
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
*/

