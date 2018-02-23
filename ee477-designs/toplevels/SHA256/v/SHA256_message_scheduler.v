// This is the module for 
module SHA256_message_scheduler
	(input 	[511:0] M_i 
	,input 		clk_i
	,input		reset_i	
        ,input 		init_i	
	,output [31:0] 	Wt_o 
	);

	// data flow
	reg 	[31:0] 	word_mem [15:0];
	reg	[31:0]	word_next[15:0];
	reg	[31:0]	wt;
	// control logic
	reg			write_en;
	reg	[5:0]		cycle_counter, cycle_counter_next;
	reg			state_r, state_n; // busy = 1'b1, wait = 1'b0
	reg [31:0] w_0, w_1, w_9, w_14, s0, s1, w_new;

		

	assign Wt_o = wt;

	always @(posedge clk_i)	begin

		if (reset_i) begin
			state_n		<= 1'b0;
			cycle_counter   <= 6'b0;
			word_mem[0] 	<= 32'b0;
			word_mem[1] 	<= 32'b0;
			word_mem[2] 	<= 32'b0;
			word_mem[3] 	<= 32'b0;
			word_mem[4] 	<= 32'b0;
			word_mem[5] 	<= 32'b0;
			word_mem[6] 	<= 32'b0;
			word_mem[7] 	<= 32'b0;
			word_mem[8] 	<= 32'b0;
			word_mem[9] 	<= 32'b0;
			word_mem[10] 	<= 32'b0;
			word_mem[11] 	<= 32'b0;
			word_mem[12]	<= 32'b0;
			word_mem[13]	<= 32'b0;
			word_mem[14] 	<= 32'b0;
			word_mem[15] 	<= 32'b0;
		end else begin
			if (write_en) begin
				word_mem[0]	<= word_next[0];
				word_mem[1] 	<= word_next[1];
				word_mem[2]	<= word_next[2];
				word_mem[3] 	<= word_next[3];
				word_mem[4] 	<= word_next[4];
				word_mem[5] 	<= word_next[5];
				word_mem[6] 	<= word_next[6];
				word_mem[7]	<= word_next[7];
				word_mem[8] 	<= word_next[8];
				word_mem[9] 	<= word_next[9];
				word_mem[10] 	<= word_next[10];
				word_mem[11] 	<= word_next[11];
				word_mem[12] 	<= word_next[12];
				word_mem[13] 	<= word_next[13];
				word_mem[14] 	<= word_next[14];
				word_mem[15] 	<= word_next[15];
			end
		end
	end
	
	always @(*) begin
		
		word_next[0] 	<= 32'b0;
		word_next[1] 	<= 32'b0;
		word_next[2] 	<= 32'b0;
		word_next[3] 	<= 32'b0;
		word_next[4] 	<= 32'b0;
		word_next[5] 	<= 32'b0;
		word_next[6]	<= 32'b0;
		word_next[7] 	<= 32'b0;
		word_next[8] 	<= 32'b0;
		word_next[9] 	<= 32'b0;
		word_next[10] 	<= 32'b0;
		word_next[11] 	<= 32'b0;
		word_next[12]	<= 32'b0;
		word_next[13]	<= 32'b0;
		word_next[14] 	<= 32'b0;
		word_next[15] 	<= 32'b0;	
		
		w_0 = word_mem[0];
		w_1 = word_mem[1];
		w_9 = word_mem[9];
		w_14 = word_mem[14];
		
		s0 = {w_1[6:0], w_1[31:7]} 	^ {w_1[17:0], w_1[31:18]} 	^ (w_1 >> 3);
		s1 = {w_14[16:0], w_14[31:17]} 	^ {w_14[18:0], w_14[31:19]}	^ (w_14 >> 10);

		w_new = w_0 + s0 + w_9 + s1;

		if (init_i) begin
			write_en = 1'b1;
			word_next[15] = M_i[31:0];
			word_next[14] = M_i[63:32];
	 		word_next[13] = M_i[95:64];
	 		word_next[12] = M_i[127:96];
	 		word_next[11] = M_i[159:128];
	 		word_next[10] = M_i[191:160];
	 		word_next[9]  = M_i[223:192];
			word_next[8]  = M_i[255:224];
		 	word_next[7]  = M_i[287:256];
			word_next[6]  = M_i[319:288];
			word_next[5]  = M_i[351:320];
			word_next[4]  = M_i[383:352];
			word_next[3]  = M_i[415:384];
			word_next[2]  = M_i[447:416];
			word_next[1]  = M_i[479:448];
			word_next[0]  = M_i[511:480];
		end else begin
			if (cycle_counter > 15) begin
				write_en = 1'b1;
				word_next[15] = w_new;
				word_next[14] = word_mem[15];
	 			word_next[13] = word_mem[14];
	 			word_next[12] = word_mem[13];
	 			word_next[11] = word_mem[12];
	 			word_next[10] = word_mem[11];
	 			word_next[9]  = word_mem[10];
				word_next[8]  = word_mem[9];
		 		word_next[7]  = word_mem[8];
				word_next[6]  = word_mem[7];
				word_next[5]  = word_mem[6];
				word_next[4]  = word_mem[5];
				word_next[3]  = word_mem[4];
				word_next[2]  = word_mem[3];
				word_next[1]  = word_mem[2];
				word_next[0]  = word_mem[1];
			end
		end
	end

	always_comb begin	
		if (cycle_counter < 16) begin
			wt <= word_mem[cycle_counter[3:0]];
		end else begin
			wt <= w_new;
		end
	end	

	assign cycle_counter_next = cycle_counter + 1'b1;

	always @(*) begin	
		case(state_r)
			1'b0:begin // wait
				if (init_i) begin
					cycle_counter = 6'b0;
					state_n = 1'b1;
				end
			end

			1'b1:begin // busy
				if (cycle_counter == 6'b111111) begin
					state_n = 1'b0;
				end
				cycle_counter <= cycle_counter_next;

			end

			default: begin
				state_n = 1'b0;
			end
		endcase
	end
endmodule














 
/*
// This is a module solving 2D array assign issue
module ary_assign 
	(input [31:0]	 word_16_i
	,input [31:0]	 word_7_i
	,input [31:0]	 s0_i
	,input [31:0]    s1_i
	,output[31:0]    w_o
	);
	assign w_o = word_16_i + s0_i + word_7_i + s1_i;
endmodule


// This is the sigma_0 function for the message scheduler
// 
// input:
// 	word_i:		The word that is going to be rotated
//	
// output:
// 	msg_sch_sigma_0:The output of sigma_0 function
module msg_sch_sigma_0
	(input 	[31:0] word_i
	
	,output [31:0] s0_o
	);
	
	reg [31:0] word_7, word_18, word_3;

	assign word_7 	= {word_i[6:0],  word_i[31:7]};
	assign word_18 	= {word_i[17:0], word_i[31:18]};
	assign word_3	= word_i >> 3;
	
	assign msg_sch_sigma_0_o = (word_7 ^ word_18) ^ word_3;
endmodule

// This is the sigma_1 function for the message scheduler
// 
// input:
//	word_i: 	The word that is going to be rotated
// 	
// output:
// 	msg_sch_sigma_1:The output of sigma_1 function
module msg_sch_sigma_1
	(input 	[31:0]	word_i
	
	,output [31:0]	s1_o
	);
	
	reg 	[31:0] 	word_17, word_19, word_10; 
	
	assign word_17 	= {word_i[16:0], word_i[31:17]};
	assign word_19 	= {word_i[18_0], word_i[31:19]};
	assign word_10	= word_i >> 10;

	assign s1_o = (word_17 ^ word_19) ^ word_10;
endmodule
*/
