/*
Authors:
Madhu Sudhanan - 115294248
Suvarna Tirur Ananthanarayanan - 115012264
Date: March 03, 2023
*/

`include "LocalStore.sv"

module oddPipe (
    clk,
    reset,
    unit_id,
    PC,
    PC_out,
    branch_taken,
    ra_rd_odd,
    rb_rd_odd,
    rc_rd_odd,
    addr_rt_wt_odd,
    /*regWr_en_odd,*/
    opcode,
    imm7,
    imm10,
    imm16,
    imm18,
    perm_stage3_result, 
    ls_stage6_result,
    branch_stage3_result
    );
input clk, reset;
input [0 : UNIT_ID_SIZE - 1] unit_id;
input [0 : INTERNAL_OPCODE_SIZE - 1] opcode;
input signed [0:QUADWORD - 1] ra_rd_odd, rb_rd_odd, rc_rd_odd;
input [0:REG_ADDR_WIDTH-1] addr_rt_wt_odd;
input [0:IMM7-1] imm7;
input [0:IMM10-1] imm10;
input [0:IMM16-1] imm16;
input [0:IMM18-1] imm18;
input [0 : WORD - 1] PC;

logic regWr_en_odd, ls_wr_en;
logic [0:WORD-1] lsa, y;        //lsa <=> ls_addr
logic [0:13] x0;
logic [0:17] x1;
logic [0:HALFWORD-1]s0;
logic [0:BYTE-1]s1;
logic [0:3]s2; 
logic [0:(2*QUADWORD)-1]Rconcat;
logic [0:BYTE-1] b, c;// for bits shift value; later we can make a common s temp register with maximum bits possible
logic [0:QUADWORD - 1] temp, temp1; //temperory registers
logic [0 : QUADWORD - 1] ls_data_rd, rt_wt_odd;
logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD)-1] perm_stage1_result, perm_stage2_result, ls_stage1_result, ls_stage2_result, ls_stage3_result, ls_stage4_result, ls_stage5_result, branch_stage1_result, branch_stage2_result;
//logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD /*+ WORD + 1*/)-1] 

output logic branch_taken;
output logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD)-1] perm_stage3_result, ls_stage6_result, branch_stage3_result;
output logic [0:WORD-1] PC_out;
//output logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD + WORD + 1)-1] ls_stage6_result;

always_comb begin : oddPipeExecution 
perm_stage1_result = 0;
ls_stage1_result = 0;
branch_stage1_result = 0;
ls_wr_en = 0;
branch_taken = 0;

case(opcode) 
//Permute
SHIFT_LEFT_QUADWORD_BY_BITS : begin 
                                s0 = rb_rd_odd[29:31];
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s0) < 128)
                                        temp[b] = ra_rd_odd[b+s0];
                                    else
                                        temp[b] = 1'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1;
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};  
                            end 
                              
SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE: begin  
                                s0 = imm7 & 8'h07;
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s0) < 128)
                                        temp[b] = ra_rd_odd[b+s0];
                                    else
                                        temp[b] = 1'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1; 
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end   
                                                    
SHIFT_LEFT_QUADWORD_BY_BYTES : begin 
                                s0 = rb_rd_odd[29:31] & 8'h07;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s0) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8))+:8];
                                    else
                                        temp[(8*b)+:8] = 8'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1; 
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end 
                            
SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE : begin 
                                s0 = imm7 & 8'h1F ;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s0) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8))+:8];
                                    else
                                        temp[(8*b)+:8] = 8'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1; 
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end 
                            
SHIFT_LEFT_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT :  begin 
                                s0 = rb_rd_odd[24:28] & 8'h1F;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s0) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8))+:8];
                                    else
                                        temp[(8*b)+:8] = 8'b0;
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1; 
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end  
                                 
ROTATE_QUADWORD_BY_BYTES :   begin 
                                s0 = rb_rd_odd[28:31] & 8'h0F;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s0) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8))+:8];
                                    else
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8)-(16*8))+:8];
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1;
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end 
                         
ROTATE_QUADWORD_BY_BYTES_IMMEDIATE :  begin 
                                        s0 = imm7 & 8'h0F;
                                        for(int b=0; b<16; b++) 
                                        begin
                                            if ((b+s0) < 16)
                                                temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8))+:8];
                                            else
                                                temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8)-(16*8))+:8];
                                        end
                                        rt_wt_odd = temp;
                                        regWr_en_odd = 1'b1;
                                        perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                                        end  
                                        
ROTATE_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT : begin 
                                s0 = imm7 & 8'h1F;
                                for(int b=0; b<16; b++) 
                                begin
                                    if ((b+s0) < 16)
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8))+:8];
                                    else
                                        temp[(8*b)+:8] = ra_rd_odd[((8*b)+(s0*8)-(16*8))+:8];
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1;
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                                end 
ROTATE_QUADWORD_BY_BITS :     begin 
                                s0 = rb_rd_odd[29:31] & 8'h07;
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s0) < 127)
                                        temp[b] = ra_rd_odd[b+s0];
                                    else
                                        temp[b] = ra_rd_odd[b+s0-128];
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1;
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end     
ROTATE_QUADWORD_BY_BITS_IMMEDIATE :  begin 
                                s0 = imm7 & 8'h07; 
                                for(int b=0; b<128; b++) 
                                begin
                                    if ((b+s0) < 127)
                                        temp[b] = ra_rd_odd[b+s0];
                                    else
                                        temp[b] = ra_rd_odd[b+s0-128];
                                end
                                rt_wt_odd = temp;
                                regWr_en_odd = 1'b1;
                                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end                                                       
GATHER_BITS_FROM_BYTES : begin 
                        //int k = 0;
                        s0 = 16'b0;
                        for(int j = 7, int k = 0; j==128; j=j+8) begin
                            s0[k] = ra_rd_odd[j];
                            k = k+1;
                        end
                        rt_wt_odd[0:31] = {16'b0,s0};
                        rt_wt_odd[32:63] = 32'b0;
                        rt_wt_odd[64:95] = 32'b0;
                        rt_wt_odd[95:127] = 32'b0;
                        regWr_en_odd = 1'b1;
                        perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                        end
GATHER_BITS_FROM_HALFWORD :  begin 
                        //int k = 0;
                        s1 = 8'b0;
                        for(int j = 15, int k = 0; j==128; j=j+15) begin
                            s1[k] = ra_rd_odd[j];
                            k = k+1;
                        end
                        rt_wt_odd[0:31] = {24'b0,s1};
                        rt_wt_odd[32:63] = 32'b0;
                        rt_wt_odd[64:95] = 32'b0;
                        rt_wt_odd[95:127] = 32'b0;
                        regWr_en_odd = 1'b1;
                        perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                            end 
GATHER_BITS_FROM_WORDS : begin
                        //int k = 0;
                        s2 = 4'b0;
                        for(int j = 31, int k = 0; j==128; j=j+32) begin
                            s2[k] = ra_rd_odd[j];
                            k = k+1;
                        end
                        rt_wt_odd[0:31] = {32'b0,s2};
                        rt_wt_odd[32:63] = 32'b0;
                        rt_wt_odd[64:95] = 32'b0;
                        rt_wt_odd[95:127] = 32'b0;
                        regWr_en_odd = 1'b1;
                        perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                        end  
SHUFFLE_BYTES : begin
                Rconcat = {ra_rd_odd, rb_rd_odd};
                for(int j = 0; j<16; j++) begin
                   b = rc_rd_odd[(8*j)+:8];
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
                regWr_en_odd = 1'b1;
                perm_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};             
                end
//Load & Store                
LOAD_QUADWORD_D : begin
                    x0 = {imm10,4'b0};
                    y = {{18{x0[0]}},x0};
                    lsa = (y + ra_rd_odd[0:31]) & 32'hFFFFFFF0;
                    rt_wt_odd = ls_data_rd;
                    //RT = localstore
                    regWr_en_odd = 1'b1;
                    ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};
                end  
LOAD_QUADWORD_X : begin
                    lsa = (ra_rd_odd[0:31] + rb_rd_odd[0:31]) & 32'hFFFFFFF0;
                    rt_wt_odd = ls_data_rd;
                     //RT = localstore
                     regWr_en_odd = 1'b1;
                     ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};
                  end  
LOAD_QUADWORD_A : begin
                    x1 = {imm16,2'b0};
                    lsa =  ({{14{x1[0]}},x1}) & 32'hFFFFFFF0; 
                    rt_wt_odd = ls_data_rd;
                    //RT = localstore
                    regWr_en_odd = 1'b1;
                    ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};
                  end 
IMMEDIATE_LOAD_HALFWORD : begin
                    s0 = imm16;
                    for (int i = 0 ; i<8 ; i++) begin
                        rt_wt_odd[16*i +:16] = s0;
                    end
                    //RT = localstore
                    regWr_en_odd = 1'b1;
                    ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};
                  end 
IMMEDIATE_LOAD_WORD : begin
                    y = {{16{imm16[0]}},imm16};
                    for (int i = 0 ; i<4 ; i++) begin
                        rt_wt_odd[32*i +:32] = y;
                    end
                    regWr_en_odd = 1'b1;
                    ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};
                  end                  
IMMEDIATE_LOAD_ADDRESS : begin
                    y = {14'b0,imm18};
                    for (int i = 0 ; i<4 ; i++) begin
                        rt_wt_odd[32*i +:32] = y;
                    end
                    regWr_en_odd = 1'b1;
                    ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};
                    end
STORE_QUADWORD_D : begin
                   x0 = {imm10,4'b0};
                   y = {{18{x0[0]}},x0};
                   lsa = (y + ra_rd_odd[0:31]) & 32'hFFFFFFF0;
                   //lsa_mem[lsa] = rc_rd_odd;
                   // local store = RT
                   regWr_en_odd = 1'b0;
                   ls_wr_en = 1;
                   ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rc_rd_odd}; // lsa, ls_wr_en};
                   end     
STORE_QUADWORD_X : begin
                    lsa = (ra_rd_odd[0:31] + rb_rd_odd[0:31]) & 32'hFFFFFFF0;
                    //local store = RT
                    ///lsa_mem[lsa] = rc_rd_odd;
                    regWr_en_odd = 1'b0;
                    ls_wr_en = 1;
                    ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rc_rd_odd}; // lsa, ls_wr_en};
                  end  
STORE_QUADWORD_A : begin
                   x1 = {imm16,2'b0};
                   lsa =  ({{14{x1[0]}},x1}) & 32'hFFFFFFF0; 
                   //lsa_mem[lsa] = rc_rd_odd;
                   regWr_en_odd = 1'b0;
                   ls_wr_en = 1;
                   ls_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rc_rd_odd}; // lsa, ls_wr_en};
                  end    

//branch
BRANCH_RELATIVE : begin
                  x1 = {imm16,2'b0};
                  PC_out = PC + ({{14{x1[0]}},x1});
                  regWr_en_odd = 1'b0;
                  branch_taken = 1;
                  branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                  end
BRANCH_ABSOLUTE : begin
                  x1 = {imm16,2'b0};
                  PC_out = ({{14{x1[0]}},x1});
                  regWr_en_odd = 1'b0;
                  branch_taken = 1;
                  branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                  end 
BRANCH_RELATIVE_AND_SET_LINK : begin
                  rt_wt_odd[0:31] = PC + 4;
                  rt_wt_odd[32:127] = 96'd0;
                  x1 = {imm16,2'b0};
                  PC_out = PC + ({{14{x1[0]}},x1});
                  regWr_en_odd = 1'b1;
                  branch_taken = 1;
                  branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                  end
BRANCH_ABSOLUTE_AND_SET_LINK :  begin  
                                rt_wt_odd[0:31] = PC + 4;
                                rt_wt_odd[32:127] = 96'd0;  
                                x1 = {imm16,2'b0};
                                PC_out = ({{14{x1[0]}},x1});  
                                regWr_en_odd = 1'b1; 
                                branch_taken = 1;  
                                branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};                             
                                end 
BRANCH_IF_NOT_ZERO_WORD : begin 
                          if (rt_wt_odd[0:31] != 0) begin
                                x1 = {imm16,2'b0};
                                PC_out = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC;
                                branch_taken = 1;
                          end   
                          else begin
                                PC_out = PC + 4;
                                branch_taken = 0;
                          end
                            regWr_en_odd = 1'b0;  
                            branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};   
                          end 
BRANCH_IF_ZERO_WORD : begin
                      if (rt_wt_odd[0:31] == 0) begin
                                x1 = {imm16,2'b0};
                                PC_out = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC;  
                                branch_taken = 1;
                          end   
                          else begin
                                PC_out = PC + 4;
                                branch_taken = 0;
                          end
                            regWr_en_odd = 1'b0;  
                            branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};   
end    
BRANCH_IF_NOT_ZERO_HALFWORD : begin
                                if (rt_wt_odd[16:31] != 0) begin
                                    x1 = {imm16,2'b0};
                                    PC_out = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC;  
                                    branch_taken = 1;
                                end   
                                else begin
                                    PC_out = PC + 4;
                                    branch_taken = 0;
                                end
                                regWr_en_odd = 1'b0;    
                                branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd}; 
                              end                                                                          
BRANCH_IF_ZERO_HALFWORD : begin
                            if (rt_wt_odd[16:31] == 0) begin
                                x1 = {imm16,2'b0};
                                PC_out = (PC + ({{14{x1[0]}},x1})) & 32'hFFFFFFFC; 
                                branch_taken = 1; 
                                end   
                            else begin
                                PC_out = PC + 4;
                                branch_taken = 0;
                            end
                            regWr_en_odd = 1'b0; 
                            branch_stage1_result = {unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};   
                              end 
LNOP : begin
    regWr_en_odd = 1'b0;
    ls_wr_en = 1'b0;
    perm_stage1_result = 0;     //{unit_id, regWr_en_odd, addr_rt_wt_odd, rt_wt_odd};
end
default : begin
    regWr_en_odd = 0;
    ls_wr_en = 0;
    perm_stage1_result = 0;
    ls_stage1_result = 0;
end
endcase
end


always_ff @ ( posedge clk ) begin : oddPipeExecutionStages
    if(reset) begin
        //perm_stage1_result <= 0;
        perm_stage2_result <= 0;
        perm_stage3_result <= 0;
        //ls_stage1_result <= 0;
        ls_stage2_result <= 0;
        ls_stage3_result <= 0;
        ls_stage4_result <= 0;
        ls_stage5_result <= 0; 
        ls_stage6_result <= 0;   
        //branch_result <= 0;
        branch_stage2_result <= 0;
        branch_stage3_result <= 0;
         
    end

    else begin
//Permute
    perm_stage2_result <= perm_stage1_result;
    perm_stage3_result <= perm_stage2_result;  

//Load & Store   
    ls_stage2_result <=  ls_stage1_result; 
    ls_stage3_result <=  ls_stage2_result;
    ls_stage4_result <=  ls_stage3_result;  
    ls_stage5_result <=  ls_stage4_result;  
    ls_stage6_result <=  ls_stage5_result;

//Branch
    branch_stage2_result <= branch_stage1_result;
    branch_stage3_result <= branch_stage2_result;
    end

end

LocalStore ls (clk, reset, lsa, rc_rd_odd, ls_data_rd, ls_wr_en); // ls_stage6_result[139 +: WORD], ls_stage6_result[UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH +: QUADWORD], ls_data_rd, ls_stage6_result[139 + WORD]);

endmodule
