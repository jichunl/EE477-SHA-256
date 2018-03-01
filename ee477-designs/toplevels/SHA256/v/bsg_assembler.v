// This is the assembler module for SHA256 which takes four 64-bit inputs and
// assemble them to get a 256-bit output
//
// Comments on update:
//	
// Input:
// 	
// 
// Output:
//
//
// Last modified on:
//
module bsg_assembler #(parameter ring_width_p="inv", parameter id_p="inv")
	(input  			clk_i
  	,input  			reset_i
  	,input  			en_i
  	,input                     	v_i
	,input				yumi_i
	,input	[ring_width_p -1 :0]	data_i
  	,output	logic        		ready_o
  	,output logic          		v_o
  	,output reg	[255:0] 	data_o
	);

	wire [63:0] join_i;
	wire [63:0] in1_out;
	wire [63:0] in2_out;
	wire [63:0] in3_out;
	wire [63:0] in4_out;

	assign join_i = data_i;	//first pass
	
	localparam IN1 = 3'b000;
	localparam IN2 = 3'b001;
	localparam IN3 = 3'b010;
	localparam IN4 = 3'b011;
	localparam DONE = 3'b100;

	reg [2:0] state_next;
	reg [2:0] state;

	logic en1_i; 
	logic en2_i;
	logic en3_i;
	logic en4_i;

	bsg_dff_en #(.width_p(64))
		in1	(.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en1_i)
            		,.data_o(in1_out)
            		);


	bsg_dff_en #(.width_p(64))
		in2	(.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en2_i)
            		,.data_o(in2_out)
            		);

	bsg_dff_en #(.width_p(64))
		in3	(.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en3_i)
            		,.data_o(in3_out)
            		);

	bsg_dff_en #(.width_p(64))
		in4	(.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en4_i)
            		,.data_o(in4_out)
            		);

	bsg_dff_en #(.width_p(3))
		state_thingy(.clock_i(clk_i)
	    		,.data_i(state_next)
            		,.en_i(1'b1)
            		,.data_o(state)
            		);

	always_comb begin
		case(state)
			IN1: begin
				ready_o = 1'b1;
				v_o = 1'b0;
				en1_i = 1'b1;
				en2_i = 1'b0;
				en3_i = 1'b0;
				en4_i = 1'b0;
			end

			IN2: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en1_i = 1'b0;
        			en2_i = 1'b1;
				en3_i = 1'b0;		
				en4_i = 1'b0;
        		end

			IN3: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en1_i = 1'b0;
				en2_i = 1'b0;
        			en3_i = 1'b1;
				en4_i = 1'b0;
        		end


			IN4: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en1_i = 1'b0;	
				en2_i = 1'b0;
				en3_i = 1'b0;
        			en4_i = 1'b1;
        		end

			DONE: begin
				v_o = 1'b1;
				ready_o =1'b0;
				en1_i = 1'b0;
        			en2_i = 1'b0;
        			en3_i = 1'b0;
        			en4_i = 1'b0;
				assign data_o = {in4_out,in3_out,in2_out,in1_out};
			end
		endcase
	end


	always @(*) begin
		if(reset_i==1)
			state_next = IN1;

		else begin	
			state_next = state;
			case (state)
				IN1: begin	
					if( v_i == 1'b1 )
        					state_next = IN2;
				end
   		        	IN2: begin
					if(v_i == 1'b1)
						state_next = IN3;
				end
				IN3: begin
					if(v_i == 1'b1)
						state_next = IN4;
				end
				IN4: begin 	
					if(v_i == 1'b1)
						state_next = DONE;
				end
				DONE: begin
					if(yumi_i)
						state_next = IN1;
				end

			endcase
		end
	end
endmodule
