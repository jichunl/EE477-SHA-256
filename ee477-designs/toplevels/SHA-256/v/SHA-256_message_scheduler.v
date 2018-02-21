// This is the message scheduler module for SHA-256 accelerator which produces the Wt value for SHA-256 digest
//
// input:
//	M_i:	input message
// 	clk_i:	The clock that this module runs on
// 
// output:
// 	Wt_o: 	The output of the message scheduler
module message scheduler
	(input 	[511:0] M_i 
//	,input 		clk_i
	
	,output [63:0][31:0] 	Wt_o 
	);
        
// Create word array
	reg [63:0][31:0] w;
        // copy the chunk into first 16 words to word array
	for (i = 0; i < 16; i++) begin
		w[i][31:0] = M_i[16 * i + 15 : i * 16];
	end
	
	reg [31:0] s0, s1;
	
	// compute values for rest of w
	for (i = 16; i < 64; i++) begin
		msg_sch_sigma_0 sigma0(.word_i(w[i - 15][31:0]), .s0_o(s0));
		msg_sch_sigma_1 sigma1(.word_i(w[i - 2][31:0]),  .s1_o(s1)); 
		w[i] = w[i - 16] + s0+ w[i - 7] + s1;
	end
	assign Wt_o = w; 
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
