// This is the message scheduler module for SHA-256 accelerator which produces the Wt value for SHA-256 digest
//
// input:
//	M_i:	input message
// 	clk_i:	The clock that this module runs on
// 
// output:
// 	Wt_o: 	The output of the message scheduler
module SHA256_message_scheduler
	(input 	[511:0] M_i 
//	,input 		clk_i
	
	,output [63:0][31:0] 	Wt_o 
	);
        
// Create word array
	reg [63:0][31:0] w;
        // copy the chunk into first 16 words to word array
	/*
	generate genvar i,j;
	for (i = 0; i < 16; i++) begin
		for (j = 0; j < 32; j++) begin
			w[i][j] = M_i[32 * i + j];
		end
	end
	endgenerate
	*/ // code doesn't work, do it by hand

	assign w[0][31:0] = M_i[31:0];
	assign w[1][31:0] = M_i[63:32];
	assign w[2][31:0] = M_i[95:64];
	assign w[3][31:0] = M_i[127:96];
	assign w[4][31:0] = M_i[159:128];
	assign w[5][31:0] = M_i[191:160];
	assign w[6][31:0] = M_i[223:192];
	assign w[7][31:0] = M_i[255:224];
	assign w[8][31:0] = M_i[287:256];
	assign w[9][31:0] = M_i[319:288];
	assign w[10][31:0] = M_i[351:320];
	assign w[11][31:0] = M_i[383:352];
	assign w[12][31:0] = M_i[415:384];
	assign w[13][31:0] = M_i[447:416];
	assign w[14][31:0] = M_i[479:448];
	assign w[15][31:0] = M_i[511:480];
	
	reg [31:0] s0, s1;
	
	genvar j;
	generate 
	// compute values for rest of w
	for (j = 16; j < 64; j++) begin
		msg_sch_sigma_0 sigma0(.word_i(w[j - 15][31:0]), .s0_o(s0));
		msg_sch_sigma_1 sigma1(.word_i(w[j - 2][31:0]),  .s1_o(s1)); 
		//w[j][31:0] = w[j - 16][31:0] + s0+ w[j - 7][31:0] + s1;
		ary_assign assign_word	(.word_16_i(w[j - 16][31:0]) 
				       	,.word_7_i(w[j - 7][31:0])
					,.s0_i(s0)
					,.s1_i(s1)
					,.w_o(w[j][31:0])
					);
	end
	endgenerate
	assign Wt_o = w; 
endmodule 

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
