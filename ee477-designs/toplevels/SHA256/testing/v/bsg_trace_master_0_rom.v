// auto-generated by bsg_ascii_to_rom.py from /home/jichunli/SHA256_test/ee477-designs/toplevels/SHA256/testing/v/trace_master_0.tr; do not modify
module bsg_trace_master_0_rom #(parameter width_p=-1, addr_width_p=-1)
(input  [addr_width_p-1:0] addr_i
,output logic [width_p-1:0]      data_o
);
always_comb case(addr_i)
                                 // #######################################################################################################
                                 // #
                                 // # format:   <4 bit op> <fsb packet>
                                 // #   op = 0000: wait one cycle
                                 // #   op = 0001: send
                                 // #   op = 0010: receive & check
                                 // #   op = 0011: done; disable but do not stop
                                 // #   op = 0100: finish; stop simulation
                                 // #   op = 0101: wait for cycle ctr to reach 0
                                 // #   op = 0110: set cycle ctr
                                 // #
                                 // # fsb packet (data)
                                 // # 1 bit    75 bits
                                 // #   0       data
                                 // #
                                 // # fsb packet (control)
                                 // # 1 bit    7 bits    4 bits   64 bits
                                 // #   1      opcode    srcid    data
                                 // #
                                 // # opcodes
                                 // #   1: 0000_001 = disable
                                 // #   2: 0000_010 = enable
                                 // #   5: 0000_101 = assert reset
                                 // #   6: 0000_110 = deassert reset
                                 // #
                                 // #send:  s  rst=0    src   data
         0: data_o = width_p ' (80'b0001____1__0000110__0000__00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000); // 0x18600000000000000000
                                 // #send:  s  en=1     src   data
         1: data_o = width_p ' (80'b0001____1__0000010__0000__00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000); // 0x18200000000000000000
                                 // ## TODO - Add Test Cases Here!
                                 // ##
                                 // # TRACES FOR BITCOIN ASIC
                                 // # I'm first sending the values for the mid-state. midstate = {32'h56f6950a, 32'h86a3a529, 32'h7961969c, 32'h7bfdb28c, 32'h54c9af5a, 32'h951237b8, 32'h7979d96f, 32'hc01823e1};
                                 // # sending the last two hex's first {32'h7979d96f, 32'hc01823e1} in the 64 bit trace. Assembler catches all 8 32 bit inputs, which are then sent to a pre-processor (o/p- 512 bits after padding)
                                 // #0001____0__00000000_0001_1111001011110011101100101101111__11000000000110000010001111100001
                                 // #0001____0__00000000_0001_1010100110010011010111101011010__10010101000100100011011110111000
                                 // #0001____0__00000000_0001_1111001011000011001011010011100__01111011111111011011001010001100
                                 // #0001____0__00000000_0001_1010110111101101001010100001010__10000110101000111010010100101001
                                 // #these are sent to the bitcoin miner as the mid-state when we finish with the asic.
                                 // #as a sanity check we can send an empty string of 256 zeros which can be used as an input for the sha-256
                                 // #the has output of this should be-  67f022195ee405142968ca1b53ae2513a8bab0404d70577785316fa95218e8ba
                                 // #0001____0__00000000_0000_0000000000000000000000000000000__00000000000000000000000000000000
                                 // #0001____0__00000000_0000_0000000000000000000000000000000__00000000000000000000000000000000
                                 // #0001____0__00000000_0000_0000000000000000000000000000000__00000000000000000000000000000000
                                 // #0001____0__00000000_0000_0000000000000000000000000000000__00000000000000000000000000000000
         2: data_o = width_p ' (80'b0001____0__0000000__0000___00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000010); // 0x10000000000000000002
         3: data_o = width_p ' (80'b0010____0__0000000__0000___00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000); // 0x20000000000000000000
                                 // #done:  indicated done, when all trace-replays are done, the
                                 // #       simulation will finish.
         4: data_o = width_p ' (80'b0011____0__0000000__0000__00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000); // 0x30000000000000000000
   default: data_o = 'X;
endcase
endmodule
