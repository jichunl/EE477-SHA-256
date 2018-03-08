// This is the assembler module that takes four inputs and convert them into
// 	one 256-bit output
//
// Comments on update:
//
// input:
//
//
// output:
//
//
// Last modified on: Tue Mar  6 19:34:18 2018

module bsg_assembler
  	(input  		clk_i
  	,input  		reset_i
  	,input  		en_i
  	,input        		v_i
	,input			yumi_i
  	,input		[63:0] data_i
  	,output	logic        	ready_o
  	,output	logic          	v_o
  	,output	reg	[255:0] data_o
  	);

	wire [63:0] join_i;

	wire [63:0] in1_out;
	wire [63:0] in2_out;
	wire [63:0] in3_out;
	wire [63:0] in4_out;

	assign join_i = data_i;  //first pass

	localparam IN1 = 3'b000;
	localparam IN2 = 3'b001;
	localparam IN3 = 3'b010;
	localparam IN4 = 3'b011;
	localparam DONE = 3'b100;
	localparam WAIT = 3'b111;

	reg [2:0] state, state_n;
	
	logic en_1; 
	logic en_2;
	logic en_3;
	logic en_4;


	bsg_dff_en #(.width_p(64))
		in1	(.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en_1)
            		,.data_o(in1_out)
            		);


	bsg_dff_en #(.width_p(64))
		in2     (.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en_2)
            		,.data_o(in2_out)
            		);

	bsg_dff_en #(.width_p(64))
		in3     (.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en_3)
            		,.data_o(in3_out)
            		);

	bsg_dff_en #(.width_p(64))
		in4     (.clock_i(clk_i)
            		,.data_i(join_i)
            		,.en_i(en_4)
            		,.data_o(in4_out)
            		);

	always_ff @(posedge clk_i) begin
		if (reset_i) begin 
			state <=  WAIT;
		end else if (en_i) begin
			state <= state_n;
		end else begin
			state <= state;
		end
	end

	always_comb begin        
		case(state)
			WAIT: begin
				ready_o = 1'b1;
				v_o = 1'b0;
				en_1 = 1'b0;
				en_2 = 1'b0;
				en_3 = 1'b0;
				en_4 = 1'b0;
				if (v_i) begin
					state_n = IN1;
				end
			end
	
			IN1: begin
				ready_o = 1'b1;
				v_o = 1'b0;
				en_1 = 1'b1;
				en_2 = 1'b0;
				en_3 = 1'b0;
				en_4 = 1'b0;
				if (v_i) begin
					state_n = IN2;
				end
			end

			IN2: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en_1 = 1'b0;
        			en_2 = 1'b1;
				en_3 = 1'b0;		
				en_4 = 1'b0;
				if (v_i) begin
					state_n = IN3;
				end
        		end

			IN3: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en_1 = 1'b0;
				en_2 = 1'b0;
        			en_3 = 1'b1;
				en_4 = 1'b0;
				if (v_i) begin
					state_n = IN4;
				end
        		end


			IN4: begin
        			ready_o = 1'b1;
        			v_o = 1'b0;
				en_1 = 1'b0;	
				en_2 = 1'b0;
				en_3 = 1'b0;
        			en_4 = 1'b1;
				if (v_i) begin
					state_n = DONE;
				end
        		end

			DONE: begin
				ready_o =1'b0;
				v_o = 1'b1;
				en_1 = 1'b0;
        			en_2 = 1'b0;
        			en_3 = 1'b0;
        			en_4 = 1'b0;
				data_o = {in4_out,in3_out,in2_out,in1_out};
				if (v_i & yumi_i) begin
					state_n = IN1;
				end
			end
		endcase
	end
endmodule


