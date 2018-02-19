// This is the message scheduler module for SHA-256 accelerator which produces the Wt value for SHA-256 digest
//
// input:
//	M_i:	input message
// 	clk_i:	The clock that this module runs on
// 
// output:
// 	Wt_o: 	The output of the message scheduler
module message scheduler
	(input 	[31:0] 	M_i 
	,input 		clk_i
	
	,output [31:0] 	Wt_o 
	);

endmodule 

// This is the sigma_0 function for the message scheduler
// 
// input:
// 	M_i:
//	
// output:
// 	msg_sch_sigma_0:
module msg_sch_sigma_0
	(input 	[31:0] M_i
	
	,output msg_sch_sigma_0_o
	);
	
	reg [31:0] msg_7, msg_18, msg_3;

	assign msg_7 	= M_i >> 7;
	assign msg_18 	= M_i >> 18;
	assign msg_3	= M_i >> 3;
	
	assign msg_sch_sigma_0_o = (msg_7 ^ msg_18) ^ msg_3;
endmodule

// This is the sigma_1 function for the message scheduler
// 
// input:
//	M_i: 
// 	
// output:
// 	msg_sch_sigma_1:
module msg_sch_sigma_1
	(input 	[31:0]	M_i
	
	,output [31:0]	msg_sch_sigma_1_o
	);
	
	reg 	[31:0] 	msg_17, msg_19, msg_10; 
	
	assign msg_17 	= M_i >> 17;
	assign msg_19 	= M_i >> 19;
	assign msg_10	= M_i >> 10;

	assign msg_sch_sigma_1_o = (msg_17 ^ msg_19) ^ msg_10;
endmodule
