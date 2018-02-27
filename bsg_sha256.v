//module for sha
//wrapper for assembler and sha256_core
//
//24-feb-18, added state machine, changed variable names


module bsg_sha256 #(parameter ring_width_p = "inv"
		    ,parameter id_p="inv")
	(input	clk_i
	,input	reset_i
	,input 	en_i
	,input	v_i
	,input 	yumi_i
	,input  [ring_width_p - 1:0] data_i
	,output	ready_o
	,output v_o
	//,output	[255:0]	data_o
	,output [ring_width_p-1:0] data_o
	);
	
	logic core_ready_o, core_v_i, core_yumi_i, core_v_o, assembler_v_i, assembler_v_o, assembler_ready_o, assembler_en_i, core_en_i;
	reg	[255:0]	assembler_data_o;
	
	assign assembler_v_i = v_i;
	assign assembler_v_o = v_o;
	assign assembler_ready_o  = ready_o;
	
	bsg_assembler
	assembler	(.clk_i(clk_i)
			,.reset_i(reset_i)
			,.en_i(assembler_en_i)
			,.v_i(assembler_v_i)
			,.data_i(data_i)
			,.ready_o(assembler_ready_o)
			,.v_o(assembler_v_o)
			,.data_o(assembler_data_o)
			,.yumi_i(assembler_yumi_i)
			);
	
	SHA256_core
	core		(.clk_i(clk_i)
			,.reset_i(reset_i)
			,.en_i(core_en_i)
			,.v_i(core_v_i)
			,.yumi_i(core_yumi_i)
			,.msg_i(assembler_data_o)
			,.ready_o(core_ready_o)
			,.v_o(core_v_o)
			,.digest_o(data_o)
			);


localparam WAIT = 2'b00;
localparam CALC = 2'b01;
localparam DONE = 2'b10;
reg [1:0] state_next;
reg [1:0] state;

bsg_dff_en #(.width_p(2))
state_thingy(.clock_i(clk_i)
	    ,.data_i(state_next)
            ,.en_i(1'b1)
            ,.data_o(state)
            );

always_comb
begin        
	 case(state)
WAIT:

	begin
	assembler_en_i = 1'b1;
	core_en_i = 1'b0;
	end

CALC:	
	begin
		if(assembler_v_o==1'b1)
		begin		
		core_en_i = 1'b1;
		assembler_en_i =1'b0;
		end
	
		else
		begin	
		assembler_en_i = 1'b1;		
		core_en_i = 1'b0;
		end
	end
DONE:	
	begin
	ready_o = 1'b0;			
	v_o = 1'b0;
	assembler_en_i = 1'b0;		
	core_en_i = 1'b0;
	end
endcase
end


always @(*)
	begin
		if(reset_i == 1)
		state_next = WAIT;
		else
			begin 
			state_next = state; 
			case
 				( state ) 
				WAIT : 
				if( assembler_v_o == 1'b1 ) 
        			state_next = CALC; 
   			
				CALC : 
				if(core_v_o ==1'b1)
				state_next = DONE;
	    			DONE : 
				if( yumi_i ) 
	        		state_next = WAIT; 
			endcase
			end
	end
endmodule
