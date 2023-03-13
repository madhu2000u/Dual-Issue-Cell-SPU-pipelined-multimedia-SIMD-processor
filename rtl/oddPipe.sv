/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: March 03, 2023
*/

module oddPipe (
    clk,
    reset,
    ra_rd_odd,
    rb_rd_odd,
    rc_rd_odd,
    rt_wt_odd,
    addr_ra_rd_odd, 
    addr_rb_rd_odd,
    addr_rc_rd_odd,
    addr_rt_wt_odd,
    regWr_en_odd,
    opcode,
    i7,
    i10,
    i16
    );
input clk, reset;
input [0:127] ra_rd_odd, rb_rd_odd, rc_rd_odd, rt_wt_odd;
input [0:6] addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd, addr_rt_wr_odd;
input [0:6] i7;
input [0:9] i10;
input [0:15] i16;
logic [0:31] lsa, y;
logic [0:13] x0;
logic [0:17] x1;
logic [0:15]s;
logic [0:7]s1;
logic [0:3]s2; 
logic [0:255]Rconcat;
logic [0:7] b, c;// for bits shift value; later we can make a common s temp register with maximum bits possible
logic [0:127] temp, temp1; //temperory registers
always_comb begin : Odd_pipe_operations 
case(opcode) 
SHIFT_LEFT_QUADWORD_BY_BITS : begin 
                                s = rb_rd_odd[29:31] & 8'h07;
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s) < 127)
                                        temp[b] = ra_rd_odd[b+s];
                                    else
                                        temp[b] = 1'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1; 
                            end 
                              
SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE: begin  
                                s = i7 & 8'h07 ;
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s) < 127)
                                        temp[b] = ra_rd_odd[b+s];
                                    else
                                        temp[b] = 1'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1; 
                            end   
                                                    
SHIFT_LEFT_QUADWORD_BY_BYTES : begin 
                                s = rb_rd_odd[29:31] & 8'h07;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8))+:8];
                                    else
                                        temp[(8*b)+:8] = 8'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1; 
                            end 
                            
SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE : begin 
                                s = i7 & 8'h1F ;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8))+:8];
                                    else
                                        temp[(8*b)+:8] = 8'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1; 
                            end 
                            
SHIFT_LEFT_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT :  begin 
                                s = rb_rd_odd[24:28] & 8'h1F;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8))+:8];
                                    else
                                        temp[(8*b)+:8] = 8'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1; 
                            end  
                                 
ROTATE_QUADWORD_BY_BYTES :   begin 
                                s = rb_rd_odd[28:31] & 8'h0F;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8))+:8];
                                    else
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8)-(16*8))+:8];
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1;
                            end 
                         
ROTATE_QUADWORD_BY_BYTES_IMMEDIATE :  begin 
                                        s = i7 & 8'h0F;
                                        for(int b=0; b<16; b++) 
                                        begin
                                            if ((b+s) < 16)
                                                temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8))+:8];
                                            else
                                                temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8)-(16*8))+:8];
                                        end
                                        rt_wt_odd = temp;
                                        regWr_en_odd = 1;
                                        end  
                                        
ROTATE_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT : begin 
                                s = i7 & 8'h1F;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8))+:8];
                                    else
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s*8)-(16*8))+:8];
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1;
                                end 
ROTATE_QUADWORD_BY_BITS :     begin 
                                s = rb_rd_odd[29:31] & 8'h07;
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s) < 127)
                                        temp[b] = ra_rd_odd[b+s];
                                    else
                                        temp[b] = ra_rd_odd[b+s-128];
                                end
                                rt_wt_odd = temp;
                                 regWr_en_odd = 1;
                            end     
ROTATE_QUADWORD_BY_BITS_IMMEDIATE :  begin 
                                s = i7 & 8'h07; 
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s) < 127)
                                        temp[b] = ra_rd_odd[b+s];
                                    else
                                        temp[b] = ra_rd_odd[b+s-128];
                                end
                                rt_wt_odd = temp;
                                 regWr_en_odd = 1;
                            end                                                       
GATHER_BITS_FROM_BYTES : begin 
                        int k = 0;
                        s = 16'b0;
                        for(int j = 7; j=128; j=j+8) begin
                            s[k] = ra_rd_odd[j];
                            k = k+1;
                        end
                        rt_wt_odd[0:31] = {16'b0,s};
                        rt_wt_odd[32:63] = 32'b0;
                        rt_wt_odd[64:95] = 32'b0;
                        rt_wt_odd[95:127] = 32'b0;
                        regWr_en_odd = 1;
                        end
GATHER_BITS_FROM_HALFWORD :  begin 
                        int k = 0;
                        s1 = 8'b0;
                        for(int j = 15; j=128; j=j+15) begin
                            s[k] = ra_rd_odd[j];
                            k = k+1;
                        end
                        rt_wt_odd[0:31] = {24'b0,s};
                        rt_wt_odd[32:63] = 32'b0;
                        rt_wt_odd[64:95] = 32'b0;
                        rt_wt_odd[95:127] = 32'b0;
                        regWr_en_odd = 1;
                            end 
GATHER_BITS_FROM_WORDS : begin
                        int k = 0;
                        s2 = 4'b0;
                        for(int j = 31; j=128; j=j+32) begin
                            s[k] = ra_rd_odd[j];
                            k = k+1;
                        end
                        rt_wt_odd[0:31] = {32'b0,s};
                        rt_wt_odd[32:63] = 32'b0;
                        rt_wt_odd[64:95] = 32'b0;
                        rt_wt_odd[95:127] = 32'b0;
                        regWr_en_odd = 1;
                        regWr_en_odd = 1;
                        end  
SHUFFLE_BYTES : begin
                Rconcat = {ra_rd_odd, rb_rd_odd};
                for(int j = 0; j<16; j++) begin
                   b = rc_rd_odd[(8*j)+:8]
                   if(b[0:1]==2'b10) begin
                        c = 8'h0;
                   end
                   else if(b[0:2]==3'b110) begin
                        c = 8'hFF;
                   end
                   else if(b[0:2]==3'b111) begin
                        c = 8'h80;
                   end
                   else begin
                        b = b & 8'h1F;
                        c = Rconcat[(8*b)+:8];
                   end
                   rt_wt_odd[(8*j)+:8] = c;
                end   
                regWr_en_odd = 1;             
                end
LOAD_QUADWORD_D : begin
                    x0 = {i10,4'b0};
                    y = {{18{x0[0]}},x0};
                    lsa = (y + ra_rd_odd[0:31]) & 32'hFFFFFFF0;
                    //RT = localstore
                    regWr_en_odd = 1;
                end  
LOAD_QUADWORD_X : begin
                    lsa = (ra_rd_odd[0:31] + rb_rd_odd[0:31]) & 32'hFFFFFFF0;
                     //RT = localstore
                     regWr_en_odd = 1;
                  end  
LOAD_QUADWORD_A : begin
                    x1 = {i16,2'b0};
                    lsa =  ({{14{x1[0]}},x1}) & 32'hFFFFFFF0; 
                    //RT = localstore
                    regWr_en_odd = 1;
                  end 
STORE_QUADWORD_D : begin
                   x0 = {i10,4'b0};
                   y = {{18{x0[0]}},x0};
                   lsa = (y + ra_rd_odd[0:31]) & 32'hFFFFFFF0;
                   // local store = RT
                   end     
STORE_QUADWORD_X : begin
                    lsa = (ra_rd_odd[0:31] + rb_rd_odd[0:31]) & 32'hFFFFFFF0;
                     //local store = RT
                  end  
STORE_QUADWORD_A : begin
                   x1 = {i16,2'b0};
                   lsa =  ({{14{x1[0]}},x1}) & 32'hFFFFFFF0; 
                    //local store = RT
                  end    
BRANCH_RELATIVE : begin
                  x1 = {i16,2'b0};
                  PC = PC + ({{14{x1[0]}},x1});
                  end
BRANCH_ABSOLUTE : begin
                  x1 = {i16,2'b0};
                  PC = ({{14{x1[0]}},x1});
                  end 
BRANCH_RELATIVE_AND_SET_LINK : begin
                  rt_wt_odd[0:31] = PC + 4;
                  rt_wt_odd[32:127] = 96'd0;
                  x1 = {i16,2'b0};
                  PC = PC + ({{14{x1[0]}},x1});
                  end
BRANCH_ABSOLUTE_AND_SET_LINK :  begin  
                                rt_wt_odd[0:31] = PC + 4;
                                rt_wt_odd[32:127] = 96'd0;  
                                x1 = {i16,2'b0};
                                PC = ({{14{x1[0]}},x1});                                 
                                end 
BRANCH_IF_NOT_ZERO_WORD : begin 
                          if (rt_wt_odd[0:31] != 0) begin
                                x1 = {i16,2'b0};
                                PC = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC;  
                          end   
                          else
                                PC = PC + 4;
                          end 
BRANCH_IF_ZERO_WORD : begin
                      if (rt_wt_odd[0:31] == 0) begin
                                x1 = {i16,2'b0};
                                PC = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC;  
                          end   
                          else
                                PC = PC + 4;
end    
BRANCH_IF_NOT_ZERO_HALFWORD : begin
                                if (rt_wt_odd[16:31] != 0) begin
                                    x1 = {i16,2'b0};
                                    PC = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC;  
                                end   
                                else
                                    PC = PC + 4;
                              end                                                                          
BRANCH_IF_ZERO_HALFWORD : begin
                            if (rt_wt_odd[16:31] == 0) begin
                                x1 = {i16,2'b0};
                                PC = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC;  
                                end   
                            else
                                PC = PC + 4;
                              end                        

endcase
end

endmodule
