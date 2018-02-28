// This is the controller that communicates with FSB and multiple SHA256_cores
//
// Comments on update:
//	
// input:
//	
//
// output:
//	
//
// Last modified on: 
module SHA256_multicore #(parameter ring_width_p = "inv"
			 ,parameter node_num = 2 /*"inv"*/)
	(input 	clk_i
	,input 	reset_i
	,input 	en_i
	,input 	v_i
	,input 	yumi_i
	
	,output v_o
	,output data_o
	);

	
