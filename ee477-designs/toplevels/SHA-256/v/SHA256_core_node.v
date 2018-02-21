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

module SHA256_core (parameter ring_width_p="inv")
	(input 				clk_i
	,input 				reset_i
	,input 				en_i
	,input 				v_i
	,input 				yumi_i
	,input	[ring_width_p-1:0]	msg_i

	,output 			ready_o
	,output 			v_o
	,output [255:0]			digest_o
	);
	
	
	// This is pre-defined K values for SHA256
	localparam [63:0] K = {
		32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
		32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
		32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
		32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
		32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
		32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
		32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
		32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
		32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
		32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
		32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
		32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
		32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
		32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
		32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
		32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};

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
	reg 	[7:0][31:0]     word_reg;


	SHA256_pre_processing 
		pre_proc (.msg_i(msg_i)
			 ,.pre_proc_o(pre_proc_msg)
			 );

	SHA256_message_scheduler
		msg_sch	(.M_i(pre_proc_msg)
			,.Wt_o(Wt_ary)
			);
	
	// define cases
	typedef enum [1:0] {eWait, eBusy, eDone} state_e;
	
	// State register
	always_ff @(posedge clk_i)
		substate_r <= reset_i ? eWait : substate_next;

	
	

	
	always_comb
		unique case(substate_r)
			eWait: begin // Waiting for the input
				if (v_i & ready_o) begin
					substate_next = eBusy;
				
				end else begin
					substate_next = eWait;
				end
		 	end
		
			eBusy: begin // Calculating the hash value
				if ()

			end

			eDone:
			
			end

			default: begin:w



