module decode (
    clk,
    reset,
    instr1,
    instr2
);
    input clk, reset;
    input [0:31] instr1, instr2;

    logic [0 : INTERNAL_OPCODE_SIZE - 1]    opcode_even, opcode_odd;
    logic [0 : IMM7 - 1]                    imm7_even, imm7_odd;
    logic [0 : IMM10 - 1]                   imm10_even, imm10_odd;
    logic [0 : IMM16 - 1]                   imm16_odd;
    logic [0 : IMM18 - 1]                   imm18_odd;
    logic [0 : QUADWORD - 1]                ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd, rc_rd_odd;
    logic [0 : QUADWORD - 1]                rt_wt_even, rt_wt_odd;

    logic [0:22] instr_ROM [0:0] = {
        {add_word, 4'd3, ADD_WORD, 1'd1}        //EVEN = 1, ODD = 0;
    };    //Instr ROM

    always_comb begin : Decoder
        //instr1 decode
        for (int i = 0; i < 1; i++) begin
            //RR_RI7 type (11-bit opcode)
            if(instr1[0:10] == instr_ROM[i][0:10]) begin
                if(instr1[22]) begin
                    ra_rd_even = instr1[18:24];
                    rb_rd_even = instr1[11:17];
                    rt_wt_even = instr1[25:31];
                    imm7_even = instr1[11:17];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    ra_rd_odd = instr1[18:24];
                    rb_rd_odd = instr1[11:17];
                    rt_wt_odd = instr1[25:31];
                    imm7_odd = instr1[11:17];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RI16 type (9-bit opcode)
            else if(instr1[0:8] == instr_ROM[i][0:8]) begin
                if(instr1[22]) begin
                    rt_wt_even = instr1[25:31];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    imm16_odd = instr1[9:24];
                    rt_wt_odd = instr1[25:31];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RI10 type (8-bit opcode)
            else if(instr1[0:7] == instr_ROM[i][0:7]) begin
                if(instr1[22]) begin
                    imm10_even = instr1[8:17];
                    ra_rd_even = instr1[18:24];
                    rt_wt_even = instr1[25:31];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    imm10_odd = instr1[8:17];
                    ra_rd_odd = instr1[18:24];
                    rt_wt_odd = instr1[25:31];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RI18 type (7-bit opcode)
            else if(instr1[0:6] == instr_ROM[i][0:6]) begin //TODO: no even instr wit 7-bit opcode so remove if-else later
                if(instr1[22]) begin
                    rt_wt_even = instr1[25:31];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    imm18_odd = instr1[7:24];
                    rt_wt_odd = instr1[25:31];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RRR type (4-bit opcode)
            else if(instr1[0:3] == instr_ROM[i][0:3]) begin
                if(instr1[22]) begin
                    ra_rd_even = instr1[18:24];
                    rb_rd_even = instr1[11:17];
                    rc_rd_even = instr1[25:31];
                    rt_wt_even = instr1[4:10];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    ra_rd_odd = instr1[18:24];
                    rb_rd_odd = instr1[11:17];
                    rc_rd_odd = instr1[25:31];
                    rt_wt_odd = instr1[4:10];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
        end


        //instr2 decode
        for (int i = 0; i < 96; i++) begin
            //RR_RI7 type (11-bit opcode)
            if(instr2[0:10] == instr_ROM[i][0:10]) begin
                if(instr2[22]) begin
                    ra_rd_even = instr2[18:24];
                    rb_rd_even = instr2[11:17];
                    rt_wt_even = instr2[25:31];
                    imm7_even = instr2[11:17];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    ra_rd_odd = instr2[18:24];
                    rb_rd_odd = instr2[11:17];
                    rt_wt_odd = instr2[25:31];
                    imm7_odd = instr2[11:17];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RI16 type (9-bit opcode)
            else if(instr2[0:8] == instr_ROM[i][0:8]) begin
                if(instr2[22]) begin
                    rt_wt_even = instr2[25:31];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    imm16_odd = instr2[9:24];
                    rt_wt_odd = instr2[25:31];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RI10 type (8-bit opcode)
            else if(instr2[0:7] == instr_ROM[i][0:7]) begin
                if(instr2[22]) begin
                    imm10_even = instr2[8:17];
                    ra_rd_even = instr2[18:24];
                    rt_wt_even = instr2[25:31];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    imm10_odd = instr2[8:17];
                    ra_rd_odd = instr2[18:24];
                    rt_wt_odd = instr2[25:31];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RI18 type (7-bit opcode)
            else if(instr2[0:6] == instr_ROM[i][0:6]) begin
                if(instr2[22]) begin
                    rt_wt_even = instr2[25:31];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    imm18_odd = instr2[7:24];
                    rt_wt_odd = instr2[25:31];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
            //RRR type (4-bit opcode)
            else if(instr2[0:3] == instr_ROM[i][0:3]) begin
                if(instr2[22]) begin
                    ra_rd_even = instr2[18:24];
                    rb_rd_even = instr2[11:17];
                    rc_rd_even = instr2[25:31];
                    rt_wt_even = instr2[4:10];
                    opcode_even = instr_ROM[i][15:21];
                end
                else begin
                    ra_rd_odd = instr2[18:24];
                    rb_rd_odd = instr2[11:17];
                    rc_rd_odd = instr2[25:31];
                    rt_wt_odd = instr2[4:10];
                    opcode_odd = instr_ROM[i][15:21];
                end
            end
        end
    end
    
        
    
endmodule