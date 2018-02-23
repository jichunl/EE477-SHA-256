  1 // This is the pre_processing module for message scheduler
  2 //
  3 // input
  4 //
  5 // output
  6 //
  7 
  8 module SHA256_pre_processing
  9         (input  [255:0] msg_i
 10 
 11         ,output [511:0] pre_proc_o
 12         );
 13 
 14         reg [511:0] pre_proc_r;
 15 
 16         assign pre_proc_r = 512'b0;
 17         /*
 18         integer init_index = 255;
 19         genvar i;
 20         generate
 21         for (i = 255; i >= 0; i--) begin
 22                 if (msg_i[i] != 1'b0) begin
 23                         assign init_index = i;
 24                 end
 25         end
 26         endgenerate
 27         
 28         genvar j;
 29         generate
 30         for (j = init_index; j >= 0; j--) begin
 31                 assign pre_proc_r[511 - (init_index - j)] = msg_i[j];
 32         end
 33         endgenerate
 34         assign pre_proc_r [510 - init_index] = 1'b1;
 35         assign pre_proc_o = pre_proc_r;*/
 36 
 37         assign pre_proc_r[511:256] = msg_i[255:0];
 38         assign pre_proc_r[255] = 1'b1;
 39         always @(*)
 40         while (pre_proc_r[511] == 0) begin
 41                 pre_proc_r = pre_proc_r << 2;
 42         end
 43         assign pre_proc_o = pre_proc_r;
 44 endmodule
 45         

