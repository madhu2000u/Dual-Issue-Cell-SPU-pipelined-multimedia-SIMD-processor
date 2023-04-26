module decode (
    clk,
    reset,
    instr1_issue,
    instr2,
    dep_stall_instr2,
    fx1_stage1_result,
    fx1_stage2_result,
    byte_stage1_result,
    byte_stage2_result,
    byte_stage3_result,
    fx2_stage1_result,
    fx2_stage2_result,
    fx2_stage3_result,
    sp_fp_stage1_result,
    sp_fp_stage2_result,
    sp_fp_stage3_result,
    sp_fp_stage4_result,
    sp_fp_stage5_result,
    sp_fp_stage6_result,
    sp_int_stage1_result,
    sp_int_stage2_result,
    sp_int_stage3_result,
    sp_int_stage4_result,
    sp_int_stage5_result,
    sp_int_stage6_result,
    sp_int_stage7_result,
    //odd pipe
    perm_stage1_result,
    perm_stage2_result,
    perm_stage3_result, 
    ls_stage1_result,
    ls_stage2_result,
    ls_stage3_result,
    ls_stage4_result,
    ls_stage5_result,
    ls_stage6_result,
    branch_stage1_result,
    branch_stage2_result,
    branch_stage3_result
);
    input clk, reset;
    logic [0 : WORD - 1] instr1;
    input [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1]  fx1_stage1_result, fx1_stage2_result,
                                                                    byte_stage1_result, byte_stage2_result, byte_stage3_result,
                                                                    fx2_stage1_result, fx2_stage2_result, fx2_stage3_result,
                                                                    sp_fp_stage1_result, sp_fp_stage2_result, sp_fp_stage3_result, sp_fp_stage4_result, sp_fp_stage5_result, sp_fp_stage6_result,
                                                                    sp_int_stage1_result, sp_int_stage2_result, sp_int_stage3_result, sp_int_stage4_result, sp_int_stage5_result, sp_int_stage6_result, sp_int_stage7_result,
                                                                    //odd pipe
                                                                    perm_stage1_result, perm_stage2_result, perm_stage3_result, 
                                                                    ls_stage1_result, ls_stage2_result, ls_stage3_result, ls_stage4_result, ls_stage5_result, ls_stage6_result,
                                                                    branch_stage1_result, branch_stage2_result, branch_stage3_result;

    input [0 : WORD - 1] instr1_issue, instr2;
    logic dep_stall_instr1, issue_done;
    output logic dep_stall_instr2;
    logic instr1_pipe, instr2_pipe;  //1 => even, 0 => odd
    logic [0 : INTERNAL_OPCODE_SIZE - 1]    instr1_opcode_even, instr1_opcode_odd, instr2_opcode_even, instr2_opcode_odd, opcode_even, opcode_odd;
    logic [0 : IMM7 - 1]                    imm7_even, imm7_odd;
    logic [0 : IMM10 - 1]                   imm10_even, imm10_odd;
    logic [0 : IMM16 - 1]                   imm16_odd;
    logic [0 : IMM18 - 1]                   imm18_odd;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even, addr_rt_wt_odd;

    logic [0:26] instr_ROM [0:95] = { //EVEN = 1, ODD = 0;
        {add_word,   ADD_WORD,  1'b1, 1'b1, 3'd1},
        {add_word_immediate , 3 'b0,  ADD_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {subtract_from_word ,   SUBTRACT_FROM_WORD ,  1'b1, 1'b1, 3'd1},
        {subtract_from_word_immediate , 3 'b0,  SUBTRACT_FROM_WORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {add_extended ,   ADD_EXTENDED ,  1'b1, 1'b1, 3'd1},
        {carry_generate ,   CARRY_GENERATE ,  1'b1, 1'b1, 3'd1},
        {subtract_from_extended ,   SUBTRACT_FROM_EXTENDED ,  1'b1, 1'b1, 3'd1},
        {borrow_generate ,   BORROW_GENERATE ,  1'b1, 1'b1, 3'd1},
        {add_halfword ,   ADD_HALFWORD,  1'b1, 1'b1, 3'd1},
        {add_halfword_immediate , 3 'b0,  ADD_HALFWORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {subtract_from_halfword ,   SUBTRACT_FROM_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {subtract_from_halfword_immediate , 3 'b0,  SUBTRACT_FROM_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {count_leading_zeros ,   COUNT_LEADING_ZEROS ,  1'b1, 1'b1, 3'd1},
        {form_select_mask_for_halfword ,   FORM_SELECT_MASK_FOR_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {form_select_mark_for_words ,   FORM_SELECT_MARK_FOR_WORDS ,  1'b1, 1'b1, 3'd1},
        {And ,   AND ,  1'b1, 1'b1, 3'd1},
        {and_with_complement ,   AND_WITH_COMPLEMENT ,  1'b1, 1'b1, 3'd1},
        {and_halfword_immediate , 3 'b0,  AND_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {and_word_immediate , 3 'b0,  AND_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {Or ,   OR ,  1'b1, 1'b1, 3'd1},
        {or_with_complement ,   OR_WITH_COMPLEMENT ,  1'b1, 1'b1, 3'd1},
        {or_halfword_immediate , 3 'b0,  OR_HALFWORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {or_word_immediate , 3 'b0,  OR_WORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {exclusive_or ,   EXCLUSIVE_OR ,  1'b1, 1'b1, 3'd1},
        {exclusive_or_halfword_immediate , 3 'b0,  EXCLUSIVE_OR_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {exclusive_or_word_immediate , 3 'b0,  EXCLUSIVE_OR_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {Nand ,   NAND ,  1'b1, 1'b1, 3'd1},
        {Nor ,   NOR ,  1'b1, 1'b1, 3'd1},
        {compare_equal_halfword ,   COMPARE_EQUAL_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {compare_equal_halfword_immediate , 3 'b0,  COMPARE_EQUAL_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_equal_word ,   COMPARE_EQUAL_WORD ,  1'b1, 1'b1, 3'd1},
        {compare_equal_word_immediate , 3 'b0,  COMPARE_EQUAL_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_halfword ,   COMPARE_GREATER_THAN_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_halfword_immediate , 3 'b0,  COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_word ,   COMPARE_GREATER_THAN_WORD ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_word_immediate , 3 'b0,  COMPARE_GREATER_THAN_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_halfword ,   COMPARE_LOGICAL_GREATER_THAN_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_halfword_immediate, 3 'b0,  COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_word ,   COMPARE_LOGICAL_GREATER_THAN_WORD ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_word_immediate , 3 'b0,  COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {shift_left_halfword ,   SHIFT_LEFT_HALFWORD ,  1'b1, 1'b1, 3'd3},
        {shift_left_halfword_immediate ,   SHIFT_LEFT_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd3},
        {shift_left_word ,   SHIFT_LEFT_WORD ,  1'b1, 1'b1, 3'd3},
        {shift_left_word_immediate ,   SHIFT_LEFT_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd3},
        {rotate_halfword ,   ROTATE_HALFWORD ,  1'b1, 1'b1, 3'd3},
        {rotate_halfword_immediate ,   ROTATE_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd3},
        {rotate_word ,   ROTATE_WORD ,  1'b1, 1'b1, 3'd3},
        {rotate_word_immediate ,   ROTATE_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd3},
        {floating_add ,   FLOATING_ADD ,  1'b1, 1'b1, 3'd4},
        {floating_subtract ,   FLOATING_SUBTRACT ,  1'b1, 1'b1, 3'd4},
        {floating_multiply_and_add , 7 'b0,  FLOATING_MULTIPLY_AND_ADD ,  1'b1, 1'b1, 3'd4},
        {floating_negative_multiply_and_substract , 7 'b0,  FLOATING_NEGATIVE_MULTIPLY_AND_SUBSTRACT ,  1'b1, 1'b1, 3'd4},
        {floating_multiply_and_subtract , 7 'b0,  FLOATING_MULTIPLY_AND_SUBTRACT ,  1'b1, 1'b1, 3'd4},
        {flaoting_multiply ,   FLAOTING_MULTIPLY ,  1'b1, 1'b1, 3'd4},
        {multiply ,   MULTIPLY ,  1'b1, 1'b1, 3'd4},
        {multiply_unsigned ,   MULTIPLY_UNSIGNED ,  1'b1, 1'b1, 3'd4},
        {multiply_immediate , 3 'b0,  MULTIPLY_IMMEDIATE ,  1'b1, 1'b1, 3'd4},
        {multiply_unsigned_immediate , 3 'b0,  MULTIPLY_UNSIGNED_IMMEDIATE ,  1'b1, 1'b1, 3'd4},
        {multiply_and_add , 7 'b0,  MULTIPLY_AND_ADD ,  1'b1, 1'b1, 3'd4},
        {count_ones_in_bytes ,   COUNT_ONES_IN_BYTES ,  1'b1, 1'b1, 3'd2},
        {absolute_differences_of_bytes ,   ABSOLUTE_DIFFERENCES_OF_BYTES ,  1'b1, 1'b1, 3'd2},
        {average_bytes ,   AVERAGE_BYTES ,  1'b1, 1'b1, 3'd2},
        {sum_bytes_into_halfword ,   SUM_BYTES_INTO_HALFWORD ,  1'b1, 1'b1, 3'd2},
        {shift_left_quadword_by_bits ,   SHIFT_LEFT_QUADWORD_BY_BITS ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bits_immediate , 2 'b0,  SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bytes , 2 'b0,  SHIFT_LEFT_QUADWORD_BY_BYTES ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bytes_immediate , 2 'b0,  SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bytes_from_bit_shift_count , 2 'b0,  SHIFT_LEFT_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bytes , 2 'b0,  ROTATE_QUADWORD_BY_BYTES ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bytes_immediate , 2 'b0,  ROTATE_QUADWORD_BY_BYTES_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bytes_from_bit_shift_count , 2 'b0,  ROTATE_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bits , 2 'b0,  ROTATE_QUADWORD_BY_BITS ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bits_immediate , 2 'b0,  ROTATE_QUADWORD_BY_BITS_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {gather_bits_from_bytes , 2 'b0,  GATHER_BITS_FROM_BYTES ,  1'b0, 1'b1, 3'd5},
        {gather_bits_from_halfword , 2 'b0,  GATHER_BITS_FROM_HALFWORD ,  1'b0, 1'b1, 3'd5},
        {gather_bits_from_words , 2 'b0,  GATHER_BITS_FROM_WORDS ,  1'b0, 1'b1, 3'd5},
        {shuffle_bytes , 7 'b0,  SHUFFLE_BYTES ,  1'b0, 1'b1, 3'd5},
        {load_quadword_d , 3 'b0,  LOAD_QUADWORD_D ,  1'b0, 1'b1, 3'd6},
        {load_quadword_x ,   LOAD_QUADWORD_X ,  1'b0, 1'b1, 3'd6},
        {load_quadword_a , 2 'b0,  LOAD_QUADWORD_A ,  1'b0, 1'b1, 3'd6},
        {store_quadword_d , 3 'b0,  STORE_QUADWORD_D ,  1'b0, 1'b0, 3'd6},
        {store_quadword_x ,   STORE_QUADWORD_X ,  1'b0, 1'b0, 3'd6},
        {store_quadword_a , 2 'b0,  STORE_QUADWORD_A ,  1'b0, 1'b0, 3'd6},
        {immediate_load_halfword , 2 'b0,  IMMEDIATE_LOAD_HALFWORD ,  1'b0, 1'b1, 3'd6},
        {immediate_load_word , 2 'b0,  IMMEDIATE_LOAD_WORD ,  1'b0, 1'b1, 3'd6},
        {immediate_load_address , 4 'b0,  IMMEDIATE_LOAD_ADDRESS ,  1'b0, 1'b1, 3'd6},
        {branch_relative , 2 'b0,  BRANCH_RELATIVE ,  1'b0, 1'b0, 3'd7},
        {branch_absolute , 2 'b0,  BRANCH_ABSOLUTE ,  1'b0, 1'b0, 3'd7},
        {branch_relative_and_set_link , 2 'b0,  BRANCH_RELATIVE_AND_SET_LINK ,  1'b0, 1'b1, 3'd7},
        {branch_absolute_and_set_link , 2 'b0,  BRANCH_ABSOLUTE_AND_SET_LINK ,  1'b0, 1'b1, 3'd7},
        {branch_if_not_zero_word , 2 'b0,  BRANCH_IF_NOT_ZERO_WORD ,  1'b0, 1'b0, 3'd7},
        {branch_if_zero_word , 2 'b0,  BRANCH_IF_ZERO_WORD ,  1'b0, 1'b0, 3'd7},
        {branch_if_not_zero_halfword , 2 'b0,  BRANCH_IF_NOT_ZERO_HALFWORD ,  1'b0, 1'b0, 3'd7},
        {branch_if_zero_halfword , 2 'b0,  BRANCH_IF_ZERO_HALFWORD ,  1'b0, 1'b0, 3'd7},
        {nop ,   NOP ,  1'b0, 1'b0, 3'd0},
        {lnop ,   LNOP ,  1'b0, 1'b0, 3'd0}
    




        
    };    //Instr ROM

    //TODO: remove this
    logic [0:6] array_even [0:2] = '{fx1_stage1_result[UNIT_ID_SIZE + 1 +: REG_ADDR_WIDTH], fx1_stage2_result[UNIT_ID_SIZE + 1 +: REG_ADDR_WIDTH], byte_stage1_result[UNIT_ID_SIZE + 1 +: REG_ADDR_WIDTH]} ;

    always_comb begin : Decoder_Issue_Route_Logic
        if(issue_done) begin
            instr1 = instr1_pipe ? {NOP, 21'd0} : {LNOP, 21'd0};
        end
        else begin
            instr1 = instr1_issue;
        end
        if(dep_stall_instr1) begin
            opcode_even = NOP;
            opcode_odd = LNOP;
            addr_ra_rd_even = 0;
            addr_rb_rd_even = 0;
            addr_rc_rd_even = 0;
            addr_ra_rd_odd = 0;
            addr_rb_rd_odd = 0;
            addr_rc_rd_odd = 0;
        end
        else if (dep_stall_instr2 && !dep_stall_instr1) begin
            if(!issue_done) begin
                for (int i = 0; i < 96; i++) begin
                    //RR_RI7 type (11-bit opcode)
                    if(instr1[0:10] == instr_ROM[i][0:10]) begin
                        if(instr_ROM[i][22]) begin
                            addr_ra_rd_even = instr1[18:24];
                            addr_rb_rd_even = instr1[11:17];
                            addr_rt_wt_even = instr1[25:31];
                            imm7_even = instr1[11:17];
                            instr1_opcode_even = instr_ROM[i][15:21];
                            instr1_pipe = 1;
                        end
                        else begin
                            addr_ra_rd_odd = instr1[18:24];
                            addr_rb_rd_odd = instr1[11:17];
                            addr_rt_wt_odd = instr1[25:31];
                            imm7_odd = instr1[11:17];
                            instr1_opcode_odd = instr_ROM[i][15:21];
                            instr1_pipe = 0;
                        end                                     //TODO: instr1_pipe = instr_ROM[i][22]
                    end
                    //RI16 type (9-bit opcode)
                    else if(instr1[0:8] == instr_ROM[i][0:8]) begin
                        if(instr_ROM[i][22]) begin
                            addr_rt_wt_even = instr1[25:31];
                            instr1_opcode_even = instr_ROM[i][15:21];
                            instr1_pipe = 1;
                        end
                        else begin
                            imm16_odd = instr1[9:24];
                            addr_rt_wt_odd = instr1[25:31];
                            instr1_opcode_odd = instr_ROM[i][15:21];
                            instr1_pipe = 0;
                        end
                    end
                    //RI10 type (8-bit opcode)
                    else if(instr1[0:7] == instr_ROM[i][0:7]) begin
                        if(instr_ROM[i][22]) begin
                            imm10_even = instr1[8:17];
                            addr_ra_rd_even = instr1[18:24];
                            addr_rt_wt_even = instr1[25:31];
                            instr1_opcode_even = instr_ROM[i][15:21];
                            instr1_pipe = 1;
                        end
                        else begin
                            imm10_odd = instr1[8:17];
                            addr_ra_rd_odd = instr1[18:24];
                            addr_rt_wt_odd = instr1[25:31];
                            instr1_opcode_odd = instr_ROM[i][15:21];
                            instr1_pipe = 0;
                        end
                    end
                    //RI18 type (7-bit opcode)
                    else if(instr1[0:6] == instr_ROM[i][0:6]) begin //TODO: no even instr wit 7-bit opcode so remove if-else later
                        if(instr_ROM[i][22]) begin
                            addr_rt_wt_even = instr1[25:31];
                            instr1_opcode_even = instr_ROM[i][15:21];
                            instr1_pipe = 1;
                        end
                        else begin
                            imm18_odd = instr1[7:24];
                            addr_rt_wt_odd = instr1[25:31];
                            instr1_opcode_odd = instr_ROM[i][15:21];
                            instr1_pipe = 0;
                        end
                    end
                    //RRR type (4-bit opcode)
                    else if(instr1[0:3] == instr_ROM[i][0:3]) begin
                        if(instr_ROM[i][22]) begin
                            addr_ra_rd_even = instr1[18:24];
                            addr_rb_rd_even = instr1[11:17];
                            addr_rc_rd_even = instr1[25:31];
                            addr_rt_wt_even = instr1[4:10];
                            instr1_opcode_even = instr_ROM[i][15:21];
                            instr1_pipe = 1;
                        end
                        else begin
                            addr_ra_rd_odd = instr1[18:24];
                            addr_rb_rd_odd = instr1[11:17];
                            addr_rc_rd_odd = instr1[25:31];
                            addr_rt_wt_odd = instr1[4:10];
                            instr1_opcode_odd = instr_ROM[i][15:21];
                            instr1_pipe = 0;
                        end
                    end
                end
                //if instr 1 stall lifted, we need to issue other pipe instruciton also, so if instr1 was even then we issue odd (lnop) and vice-versa
                if(instr1_pipe) begin
                    opcode_odd = LNOP;
                    addr_ra_rd_odd = 0;
                    addr_rb_rd_odd = 0;
                    addr_rc_rd_odd = 0;
                end
                else begin
                    opcode_even = NOP;
                    addr_ra_rd_even = 0;
                    addr_rb_rd_even = 0;
                    addr_rc_rd_even = 0;
                end
            end
            else begin
                opcode_even = NOP;
                opcode_odd = LNOP;
                addr_ra_rd_even = 0;
                addr_rb_rd_even = 0;
                addr_rc_rd_even = 0;
                addr_ra_rd_odd = 0;
                addr_rb_rd_odd = 0;
                addr_rc_rd_odd = 0;
            end
        end
        else begin
            //instr1 decode
            for (int i = 0; i < 96; i++) begin
                //RR_RI7 type (11-bit opcode)
                if(instr1[0:10] == instr_ROM[i][0:10]) begin
                    if(instr_ROM[i][22]) begin
                        addr_ra_rd_even = instr1[18:24];
                        addr_rb_rd_even = instr1[11:17];
                        addr_rt_wt_even = instr1[25:31];
                        imm7_even = instr1[11:17];
                        instr1_opcode_even = instr_ROM[i][15:21];
                        instr1_pipe = 1;
                    end
                    else begin
                        addr_ra_rd_odd = instr1[18:24];
                        addr_rb_rd_odd = instr1[11:17];
                        addr_rt_wt_odd = instr1[25:31];
                        imm7_odd = instr1[11:17];
                        instr1_opcode_odd = instr_ROM[i][15:21];
                        instr1_pipe = 0;
                    end                                     //TODO: instr1_pipe = instr_ROM[i][22]
                end
                //RI16 type (9-bit opcode)
                else if(instr1[0:8] == instr_ROM[i][0:8]) begin
                    if(instr_ROM[i][22]) begin
                        addr_rt_wt_even = instr1[25:31];
                        instr1_opcode_even = instr_ROM[i][15:21];
                        instr1_pipe = 1;
                    end
                    else begin
                        imm16_odd = instr1[9:24];
                        addr_rt_wt_odd = instr1[25:31];
                        instr1_opcode_odd = instr_ROM[i][15:21];
                        instr1_pipe = 0;
                    end
                end
                //RI10 type (8-bit opcode)
                else if(instr1[0:7] == instr_ROM[i][0:7]) begin
                    if(instr_ROM[i][22]) begin
                        imm10_even = instr1[8:17];
                        addr_ra_rd_even = instr1[18:24];
                        addr_rt_wt_even = instr1[25:31];
                        instr1_opcode_even = instr_ROM[i][15:21];
                        instr1_pipe = 1;
                    end
                    else begin
                        imm10_odd = instr1[8:17];
                        addr_ra_rd_odd = instr1[18:24];
                        addr_rt_wt_odd = instr1[25:31];
                        instr1_opcode_odd = instr_ROM[i][15:21];
                        instr1_pipe = 0;
                    end
                end
                //RI18 type (7-bit opcode)
                else if(instr1[0:6] == instr_ROM[i][0:6]) begin //TODO: no even instr wit 7-bit opcode so remove if-else later
                    if(instr_ROM[i][22]) begin
                        addr_rt_wt_even = instr1[25:31];
                        instr1_opcode_even = instr_ROM[i][15:21];
                        instr1_pipe = 1;
                    end
                    else begin
                        imm18_odd = instr1[7:24];
                        addr_rt_wt_odd = instr1[25:31];
                        instr1_opcode_odd = instr_ROM[i][15:21];
                        instr1_pipe = 0;
                    end
                end
                //RRR type (4-bit opcode)
                else if(instr1[0:3] == instr_ROM[i][0:3]) begin
                    if(instr_ROM[i][22]) begin
                        addr_ra_rd_even = instr1[18:24];
                        addr_rb_rd_even = instr1[11:17];
                        addr_rc_rd_even = instr1[25:31];
                        addr_rt_wt_even = instr1[4:10];
                        instr1_opcode_even = instr_ROM[i][15:21];
                        instr1_pipe = 1;
                    end
                    else begin
                        addr_ra_rd_odd = instr1[18:24];
                        addr_rb_rd_odd = instr1[11:17];
                        addr_rc_rd_odd = instr1[25:31];
                        addr_rt_wt_odd = instr1[4:10];
                        instr1_opcode_odd = instr_ROM[i][15:21];
                        instr1_pipe = 0;
                    end
                end
            end


            //instr2 decode
            for (int i = 0; i < 96; i++) begin
                //RR_RI7 type (11-bit opcode)
                if(instr2[0:10] == instr_ROM[i][0:10]) begin
                    if(instr_ROM[i][22]) begin
                        addr_ra_rd_even = instr2[18:24];
                        addr_rb_rd_even = instr2[11:17];
                        addr_rt_wt_even = instr2[25:31];
                        imm7_even = instr2[11:17];
                        instr2_opcode_even = instr_ROM[i][15:21];
                        instr2_pipe = 1;

                        
                    end
                    else begin
                        addr_ra_rd_odd = instr2[18:24];
                        addr_rb_rd_odd = instr2[11:17];
                        addr_rt_wt_odd = instr2[25:31];
                        imm7_odd = instr2[11:17];
                        instr2_opcode_odd = instr_ROM[i][15:21];
                        instr2_pipe = 0;
                    end
                end
                //RI16 type (9-bit opcode)
                else if(instr2[0:8] == instr_ROM[i][0:8]) begin
                    if(instr_ROM[i][22]) begin
                        addr_rt_wt_even = instr2[25:31];
                        instr2_opcode_even = instr_ROM[i][15:21];
                        instr2_pipe = 1;
                    end
                    else begin
                        imm16_odd = instr2[9:24];
                        addr_rt_wt_odd = instr2[25:31];
                        instr2_opcode_odd = instr_ROM[i][15:21];
                        instr2_pipe = 0;
                    end
                end
                //RI10 type (8-bit opcode)
                else if(instr2[0:7] == instr_ROM[i][0:7]) begin
                    if(instr_ROM[i][22]) begin
                        imm10_even = instr2[8:17];
                        addr_ra_rd_even = instr2[18:24];
                        addr_rt_wt_even = instr2[25:31];
                        instr2_opcode_even = instr_ROM[i][15:21];
                        instr2_pipe = 1;
                    end
                    else begin
                        imm10_odd = instr2[8:17];
                        addr_ra_rd_odd = instr2[18:24];
                        addr_rt_wt_odd = instr2[25:31];
                        instr2_opcode_odd = instr_ROM[i][15:21];
                        instr2_pipe = 0;
                    end
                end
                //RI18 type (7-bit opcode)
                else if(instr2[0:6] == instr_ROM[i][0:6]) begin
                    if(instr_ROM[i][22]) begin
                        addr_rt_wt_even = instr2[25:31];
                        instr2_opcode_even = instr_ROM[i][15:21];
                        instr2_pipe = 1;
                    end
                    else begin
                        imm18_odd = instr2[7:24];
                        addr_rt_wt_odd = instr2[25:31];
                        instr2_opcode_odd = instr_ROM[i][15:21];
                        instr2_pipe = 0;
                    end
                end
                //RRR type (4-bit opcode)
                else if(instr2[0:3] == instr_ROM[i][0:3]) begin
                    if(instr_ROM[i][22]) begin
                        addr_ra_rd_even = instr2[18:24];
                        addr_rb_rd_even = instr2[11:17];
                        addr_rc_rd_even = instr2[25:31];
                        addr_rt_wt_even = instr2[4:10];
                        instr2_opcode_even = instr_ROM[i][15:21];
                        instr2_pipe = 1;
                    end
                    else begin
                        addr_ra_rd_odd = instr2[18:24];
                        addr_rb_rd_odd = instr2[11:17];
                        addr_rc_rd_odd = instr2[25:31];
                        addr_rt_wt_odd = instr2[4:10];
                        instr2_opcode_odd = instr_ROM[i][15:21];
                        instr2_pipe = 0;
                    end
                end
            end
        end
    end


    always_comb begin : HazardChk
        dep_stall_instr1 = 0;
        dep_stall_instr2 = 0;

        //TODO: check for regWr signals also when checking hazard
        //RAW hazard check for instruction 1 - if hazard, stall both because in-order-execution
        for (int i = 0; i < 96; i++) begin
            if(instr1[0:10] == instr_ROM[i][0:10]) begin
                if( instr1[18:24] == fx1_stage1_result    ||
                    instr1[18:24] == fx1_stage2_result    ||
                    instr1[18:24] == byte_stage1_result   ||
                    instr1[18:24] == byte_stage2_result   ||
                    instr1[18:24] == byte_stage3_result   ||
                    instr1[18:24] == fx2_stage1_result    ||
                    instr1[18:24] == fx2_stage2_result    ||
                    instr1[18:24] == fx2_stage3_result    ||
                    instr1[18:24] == sp_fp_stage1_result  ||
                    instr1[18:24] == sp_fp_stage2_result  ||
                    instr1[18:24] == sp_fp_stage3_result  ||
                    instr1[18:24] == sp_fp_stage4_result  ||
                    instr1[18:24] == sp_fp_stage5_result  ||
                    instr1[18:24] == sp_fp_stage6_result  ||
                    instr1[18:24] == sp_int_stage1_result ||
                    instr1[18:24] == sp_int_stage2_result ||
                    instr1[18:24] == sp_int_stage3_result ||
                    instr1[18:24] == sp_int_stage4_result ||
                    instr1[18:24] == sp_int_stage5_result ||
                    instr1[18:24] == sp_int_stage6_result ||
                    instr1[18:24] == sp_int_stage7_result ||
                    instr1[18:24] == perm_stage1_result   ||
                    instr1[18:24] == perm_stage2_result   ||
                    instr1[18:24] == perm_stage3_result   ||
                    instr1[18:24] == ls_stage1_result     ||
                    instr1[18:24] == ls_stage2_result     ||
                    instr1[18:24] == ls_stage3_result     ||
                    instr1[18:24] == ls_stage4_result     ||
                    instr1[18:24] == ls_stage5_result     ||
                    instr1[18:24] == ls_stage6_result     ||
                    instr1[18:24] == branch_stage1_result ||
                    instr1[18:24] == branch_stage2_result ||
                    instr1[18:24] == branch_stage3_result ||
                    //
                    instr1[11:17] == fx1_stage1_result    ||
                    instr1[11:17] == fx1_stage2_result    ||
                    instr1[11:17] == byte_stage1_result   ||
                    instr1[11:17] == byte_stage2_result   ||
                    instr1[11:17] == byte_stage3_result   ||
                    instr1[11:17] == fx2_stage1_result    ||
                    instr1[11:17] == fx2_stage2_result    ||
                    instr1[11:17] == fx2_stage3_result    ||
                    instr1[11:17] == sp_fp_stage1_result  ||
                    instr1[11:17] == sp_fp_stage2_result  ||
                    instr1[11:17] == sp_fp_stage3_result  ||
                    instr1[11:17] == sp_fp_stage4_result  ||
                    instr1[11:17] == sp_fp_stage5_result  ||
                    instr1[11:17] == sp_fp_stage6_result  ||
                    instr1[11:17] == sp_int_stage1_result ||
                    instr1[11:17] == sp_int_stage2_result ||
                    instr1[11:17] == sp_int_stage3_result ||
                    instr1[11:17] == sp_int_stage4_result ||
                    instr1[11:17] == sp_int_stage5_result ||
                    instr1[11:17] == sp_int_stage6_result ||
                    instr1[11:17] == sp_int_stage7_result ||
                    instr1[11:17] == perm_stage1_result   ||
                    instr1[11:17] == perm_stage2_result   ||
                    instr1[11:17] == perm_stage3_result   ||
                    instr1[11:17] == ls_stage1_result     ||
                    instr1[11:17] == ls_stage2_result     ||
                    instr1[11:17] == ls_stage3_result     ||
                    instr1[11:17] == ls_stage4_result     ||
                    instr1[11:17] == ls_stage5_result     ||
                    instr1[11:17] == ls_stage6_result     ||
                    instr1[11:17] == branch_stage1_result ||
                    instr1[11:17] == branch_stage2_result ||
                    instr1[11:17] == branch_stage3_result) begin
                        dep_stall_instr1 = 1;
                    end
            end

            else if(instr1[0:7] == instr_ROM[i][0:7]) begin
                if( instr1[18:24] == fx1_stage1_result    ||
                    instr1[18:24] == fx1_stage2_result    ||
                    instr1[18:24] == byte_stage1_result   ||
                    instr1[18:24] == byte_stage2_result   ||
                    instr1[18:24] == byte_stage3_result   ||
                    instr1[18:24] == fx2_stage1_result    ||
                    instr1[18:24] == fx2_stage2_result    ||
                    instr1[18:24] == fx2_stage3_result    ||
                    instr1[18:24] == sp_fp_stage1_result  ||
                    instr1[18:24] == sp_fp_stage2_result  ||
                    instr1[18:24] == sp_fp_stage3_result  ||
                    instr1[18:24] == sp_fp_stage4_result  ||
                    instr1[18:24] == sp_fp_stage5_result  ||
                    instr1[18:24] == sp_fp_stage6_result  ||
                    instr1[18:24] == sp_int_stage1_result ||
                    instr1[18:24] == sp_int_stage2_result ||
                    instr1[18:24] == sp_int_stage3_result ||
                    instr1[18:24] == sp_int_stage4_result ||
                    instr1[18:24] == sp_int_stage5_result ||
                    instr1[18:24] == sp_int_stage6_result ||
                    instr1[18:24] == sp_int_stage7_result ||
                    instr1[18:24] == perm_stage1_result   ||
                    instr1[18:24] == perm_stage2_result   ||
                    instr1[18:24] == perm_stage3_result   ||
                    instr1[18:24] == ls_stage1_result     ||
                    instr1[18:24] == ls_stage2_result     ||
                    instr1[18:24] == ls_stage3_result     ||
                    instr1[18:24] == ls_stage4_result     ||
                    instr1[18:24] == ls_stage5_result     ||
                    instr1[18:24] == ls_stage6_result     ||
                    instr1[18:24] == branch_stage1_result ||
                    instr1[18:24] == branch_stage2_result ||
                    instr1[18:24] == branch_stage3_result) begin
                        dep_stall_instr1 = 1;
                    end
            end

            else if(instr1[0:3] == instr_ROM[i][0:3]) begin
                if( instr1[18:24] == fx1_stage1_result    ||
                    instr1[18:24] == fx1_stage2_result    ||
                    instr1[18:24] == byte_stage1_result   ||
                    instr1[18:24] == byte_stage2_result   ||
                    instr1[18:24] == byte_stage3_result   ||
                    instr1[18:24] == fx2_stage1_result    ||
                    instr1[18:24] == fx2_stage2_result    ||
                    instr1[18:24] == fx2_stage3_result    ||
                    instr1[18:24] == sp_fp_stage1_result  ||
                    instr1[18:24] == sp_fp_stage2_result  ||
                    instr1[18:24] == sp_fp_stage3_result  ||
                    instr1[18:24] == sp_fp_stage4_result  ||
                    instr1[18:24] == sp_fp_stage5_result  ||
                    instr1[18:24] == sp_fp_stage6_result  ||
                    instr1[18:24] == sp_int_stage1_result ||
                    instr1[18:24] == sp_int_stage2_result ||
                    instr1[18:24] == sp_int_stage3_result ||
                    instr1[18:24] == sp_int_stage4_result ||
                    instr1[18:24] == sp_int_stage5_result ||
                    instr1[18:24] == sp_int_stage6_result ||
                    instr1[18:24] == sp_int_stage7_result ||
                    instr1[18:24] == perm_stage1_result   ||
                    instr1[18:24] == perm_stage2_result   ||
                    instr1[18:24] == perm_stage3_result   ||
                    instr1[18:24] == ls_stage1_result     ||
                    instr1[18:24] == ls_stage2_result     ||
                    instr1[18:24] == ls_stage3_result     ||
                    instr1[18:24] == ls_stage4_result     ||
                    instr1[18:24] == ls_stage5_result     ||
                    instr1[18:24] == ls_stage6_result     ||
                    instr1[18:24] == branch_stage1_result ||
                    instr1[18:24] == branch_stage2_result ||
                    instr1[18:24] == branch_stage3_result ||
                    //
                    instr1[11:17] == fx1_stage1_result    ||
                    instr1[11:17] == fx1_stage2_result    ||
                    instr1[11:17] == byte_stage1_result   ||
                    instr1[11:17] == byte_stage2_result   ||
                    instr1[11:17] == byte_stage3_result   ||
                    instr1[11:17] == fx2_stage1_result    ||
                    instr1[11:17] == fx2_stage2_result    ||
                    instr1[11:17] == fx2_stage3_result    ||
                    instr1[11:17] == sp_fp_stage1_result  ||
                    instr1[11:17] == sp_fp_stage2_result  ||
                    instr1[11:17] == sp_fp_stage3_result  ||
                    instr1[11:17] == sp_fp_stage4_result  ||
                    instr1[11:17] == sp_fp_stage5_result  ||
                    instr1[11:17] == sp_fp_stage6_result  ||
                    instr1[11:17] == sp_int_stage1_result ||
                    instr1[11:17] == sp_int_stage2_result ||
                    instr1[11:17] == sp_int_stage3_result ||
                    instr1[11:17] == sp_int_stage4_result ||
                    instr1[11:17] == sp_int_stage5_result ||
                    instr1[11:17] == sp_int_stage6_result ||
                    instr1[11:17] == sp_int_stage7_result ||
                    instr1[11:17] == perm_stage1_result   ||
                    instr1[11:17] == perm_stage2_result   ||
                    instr1[11:17] == perm_stage3_result   ||
                    instr1[11:17] == ls_stage1_result     ||
                    instr1[11:17] == ls_stage2_result     ||
                    instr1[11:17] == ls_stage3_result     ||
                    instr1[11:17] == ls_stage4_result     ||
                    instr1[11:17] == ls_stage5_result     ||
                    instr1[11:17] == ls_stage6_result     ||
                    instr1[11:17] == branch_stage1_result ||
                    instr1[11:17] == branch_stage2_result ||
                    instr1[11:17] == branch_stage3_result ||
                    //
                    instr1[25:31] == fx1_stage1_result    ||
                    instr1[25:31] == fx1_stage2_result    ||
                    instr1[25:31] == byte_stage1_result   ||
                    instr1[25:31] == byte_stage2_result   ||
                    instr1[25:31] == byte_stage3_result   ||
                    instr1[25:31] == fx2_stage1_result    ||
                    instr1[25:31] == fx2_stage2_result    ||
                    instr1[25:31] == fx2_stage3_result    ||
                    instr1[25:31] == sp_fp_stage1_result  ||
                    instr1[25:31] == sp_fp_stage2_result  ||
                    instr1[25:31] == sp_fp_stage3_result  ||
                    instr1[25:31] == sp_fp_stage4_result  ||
                    instr1[25:31] == sp_fp_stage5_result  ||
                    instr1[25:31] == sp_fp_stage6_result  ||
                    instr1[25:31] == sp_int_stage1_result ||
                    instr1[25:31] == sp_int_stage2_result ||
                    instr1[25:31] == sp_int_stage3_result ||
                    instr1[25:31] == sp_int_stage4_result ||
                    instr1[25:31] == sp_int_stage5_result ||
                    instr1[25:31] == sp_int_stage6_result ||
                    instr1[25:31] == sp_int_stage7_result ||
                    instr1[25:31] == perm_stage1_result   ||
                    instr1[25:31] == perm_stage2_result   ||
                    instr1[25:31] == perm_stage3_result   ||
                    instr1[25:31] == ls_stage1_result     ||
                    instr1[25:31] == ls_stage2_result     ||
                    instr1[25:31] == ls_stage3_result     ||
                    instr1[25:31] == ls_stage4_result     ||
                    instr1[25:31] == ls_stage5_result     ||
                    instr1[25:31] == ls_stage6_result     ||
                    instr1[25:31] == branch_stage1_result ||
                    instr1[25:31] == branch_stage2_result ||
                    instr1[25:31] == branch_stage3_result) begin
                        dep_stall_instr1 = 1;
                    end
            end
        end

        //RAW, WAW and Strutural Hazard check for instruction 2
        for (int i = 0; i < 96; i++) begin
            if(instr2[0:10] == instr_ROM[i][0:10]) begin
                //RAW hazard check for instruction 2
                if( instr2[18:24] == fx1_stage1_result    ||
                    instr2[18:24] == fx1_stage2_result    ||
                    instr2[18:24] == byte_stage1_result   ||
                    instr2[18:24] == byte_stage2_result   ||
                    instr2[18:24] == byte_stage3_result   ||
                    instr2[18:24] == fx2_stage1_result    ||
                    instr2[18:24] == fx2_stage2_result    ||
                    instr2[18:24] == fx2_stage3_result    ||
                    instr2[18:24] == sp_fp_stage1_result  ||
                    instr2[18:24] == sp_fp_stage2_result  ||
                    instr2[18:24] == sp_fp_stage3_result  ||
                    instr2[18:24] == sp_fp_stage4_result  ||
                    instr2[18:24] == sp_fp_stage5_result  ||
                    instr2[18:24] == sp_fp_stage6_result  ||
                    instr2[18:24] == sp_int_stage1_result ||
                    instr2[18:24] == sp_int_stage2_result ||
                    instr2[18:24] == sp_int_stage3_result ||
                    instr2[18:24] == sp_int_stage4_result ||
                    instr2[18:24] == sp_int_stage5_result ||
                    instr2[18:24] == sp_int_stage6_result ||
                    instr2[18:24] == sp_int_stage7_result ||
                    instr2[18:24] == perm_stage1_result   ||
                    instr2[18:24] == perm_stage2_result   ||
                    instr2[18:24] == perm_stage3_result   ||
                    instr2[18:24] == ls_stage1_result     ||
                    instr2[18:24] == ls_stage2_result     ||
                    instr2[18:24] == ls_stage3_result     ||
                    instr2[18:24] == ls_stage4_result     ||
                    instr2[18:24] == ls_stage5_result     ||
                    instr2[18:24] == ls_stage6_result     ||
                    instr2[18:24] == branch_stage1_result ||
                    instr2[18:24] == branch_stage2_result ||
                    instr2[18:24] == branch_stage3_result ||
                    //
                    instr2[11:17] == fx1_stage1_result    ||
                    instr2[11:17] == fx1_stage2_result    ||
                    instr2[11:17] == byte_stage1_result   ||
                    instr2[11:17] == byte_stage2_result   ||
                    instr2[11:17] == byte_stage3_result   ||
                    instr2[11:17] == fx2_stage1_result    ||
                    instr2[11:17] == fx2_stage2_result    ||
                    instr2[11:17] == fx2_stage3_result    ||
                    instr2[11:17] == sp_fp_stage1_result  ||
                    instr2[11:17] == sp_fp_stage2_result  ||
                    instr2[11:17] == sp_fp_stage3_result  ||
                    instr2[11:17] == sp_fp_stage4_result  ||
                    instr2[11:17] == sp_fp_stage5_result  ||
                    instr2[11:17] == sp_fp_stage6_result  ||
                    instr2[11:17] == sp_int_stage1_result ||
                    instr2[11:17] == sp_int_stage2_result ||
                    instr2[11:17] == sp_int_stage3_result ||
                    instr2[11:17] == sp_int_stage4_result ||
                    instr2[11:17] == sp_int_stage5_result ||
                    instr2[11:17] == sp_int_stage6_result ||
                    instr2[11:17] == sp_int_stage7_result ||
                    instr2[11:17] == perm_stage1_result   ||
                    instr2[11:17] == perm_stage2_result   ||
                    instr2[11:17] == perm_stage3_result   ||
                    instr2[11:17] == ls_stage1_result     ||
                    instr2[11:17] == ls_stage2_result     ||
                    instr2[11:17] == ls_stage3_result     ||
                    instr2[11:17] == ls_stage4_result     ||
                    instr2[11:17] == ls_stage5_result     ||
                    instr2[11:17] == ls_stage6_result     ||
                    instr2[11:17] == branch_stage1_result ||
                    instr2[11:17] == branch_stage2_result ||
                    instr2[11:17] == branch_stage3_result ||
                    (instr1[25:31] == instr2[25:31]) || (instr1_pipe == instr2_pipe)) begin     //WAW or Structural Hazard
                        dep_stall_instr2 = 1;
                    end
            end

            else if(instr2[0:7] == instr_ROM[i][0:7]) begin
                if( instr2[18:24] == fx1_stage1_result    ||
                    instr2[18:24] == fx1_stage2_result    ||
                    instr2[18:24] == byte_stage1_result   ||
                    instr2[18:24] == byte_stage2_result   ||
                    instr2[18:24] == byte_stage3_result   ||
                    instr2[18:24] == fx2_stage1_result    ||
                    instr2[18:24] == fx2_stage2_result    ||
                    instr2[18:24] == fx2_stage3_result    ||
                    instr2[18:24] == sp_fp_stage1_result  ||
                    instr2[18:24] == sp_fp_stage2_result  ||
                    instr2[18:24] == sp_fp_stage3_result  ||
                    instr2[18:24] == sp_fp_stage4_result  ||
                    instr2[18:24] == sp_fp_stage5_result  ||
                    instr2[18:24] == sp_fp_stage6_result  ||
                    instr2[18:24] == sp_int_stage1_result ||
                    instr2[18:24] == sp_int_stage2_result ||
                    instr2[18:24] == sp_int_stage3_result ||
                    instr2[18:24] == sp_int_stage4_result ||
                    instr2[18:24] == sp_int_stage5_result ||
                    instr2[18:24] == sp_int_stage6_result ||
                    instr2[18:24] == sp_int_stage7_result ||
                    instr2[18:24] == perm_stage1_result   ||
                    instr2[18:24] == perm_stage2_result   ||
                    instr2[18:24] == perm_stage3_result   ||
                    instr2[18:24] == ls_stage1_result     ||
                    instr2[18:24] == ls_stage2_result     ||
                    instr2[18:24] == ls_stage3_result     ||
                    instr2[18:24] == ls_stage4_result     ||
                    instr2[18:24] == ls_stage5_result     ||
                    instr2[18:24] == ls_stage6_result     ||
                    instr2[18:24] == branch_stage1_result ||
                    instr2[18:24] == branch_stage2_result ||
                    instr2[18:24] == branch_stage3_result ||
                    (instr1[25:31] == instr2[25:31]) || (instr1_pipe == instr2_pipe)) begin
                        dep_stall_instr2 = 1;
                    end
            end

            else if(instr2[0:3] == instr_ROM[i][0:3]) begin
                if( instr2[18:24] == fx1_stage1_result    ||
                    instr2[18:24] == fx1_stage2_result    ||
                    instr2[18:24] == byte_stage1_result   ||
                    instr2[18:24] == byte_stage2_result   ||
                    instr2[18:24] == byte_stage3_result   ||
                    instr2[18:24] == fx2_stage1_result    ||
                    instr2[18:24] == fx2_stage2_result    ||
                    instr2[18:24] == fx2_stage3_result    ||
                    instr2[18:24] == sp_fp_stage1_result  ||
                    instr2[18:24] == sp_fp_stage2_result  ||
                    instr2[18:24] == sp_fp_stage3_result  ||
                    instr2[18:24] == sp_fp_stage4_result  ||
                    instr2[18:24] == sp_fp_stage5_result  ||
                    instr2[18:24] == sp_fp_stage6_result  ||
                    instr2[18:24] == sp_int_stage1_result ||
                    instr2[18:24] == sp_int_stage2_result ||
                    instr2[18:24] == sp_int_stage3_result ||
                    instr2[18:24] == sp_int_stage4_result ||
                    instr2[18:24] == sp_int_stage5_result ||
                    instr2[18:24] == sp_int_stage6_result ||
                    instr2[18:24] == sp_int_stage7_result ||
                    instr2[18:24] == perm_stage1_result   ||
                    instr2[18:24] == perm_stage2_result   ||
                    instr2[18:24] == perm_stage3_result   ||
                    instr2[18:24] == ls_stage1_result     ||
                    instr2[18:24] == ls_stage2_result     ||
                    instr2[18:24] == ls_stage3_result     ||
                    instr2[18:24] == ls_stage4_result     ||
                    instr2[18:24] == ls_stage5_result     ||
                    instr2[18:24] == ls_stage6_result     ||
                    instr2[18:24] == branch_stage1_result ||
                    instr2[18:24] == branch_stage2_result ||
                    instr2[18:24] == branch_stage3_result ||
                    //
                    instr2[11:17] == fx1_stage1_result    ||
                    instr2[11:17] == fx1_stage2_result    ||
                    instr2[11:17] == byte_stage1_result   ||
                    instr2[11:17] == byte_stage2_result   ||
                    instr2[11:17] == byte_stage3_result   ||
                    instr2[11:17] == fx2_stage1_result    ||
                    instr2[11:17] == fx2_stage2_result    ||
                    instr2[11:17] == fx2_stage3_result    ||
                    instr2[11:17] == sp_fp_stage1_result  ||
                    instr2[11:17] == sp_fp_stage2_result  ||
                    instr2[11:17] == sp_fp_stage3_result  ||
                    instr2[11:17] == sp_fp_stage4_result  ||
                    instr2[11:17] == sp_fp_stage5_result  ||
                    instr2[11:17] == sp_fp_stage6_result  ||
                    instr2[11:17] == sp_int_stage1_result ||
                    instr2[11:17] == sp_int_stage2_result ||
                    instr2[11:17] == sp_int_stage3_result ||
                    instr2[11:17] == sp_int_stage4_result ||
                    instr2[11:17] == sp_int_stage5_result ||
                    instr2[11:17] == sp_int_stage6_result ||
                    instr2[11:17] == sp_int_stage7_result ||
                    instr2[11:17] == perm_stage1_result   ||
                    instr2[11:17] == perm_stage2_result   ||
                    instr2[11:17] == perm_stage3_result   ||
                    instr2[11:17] == ls_stage1_result     ||
                    instr2[11:17] == ls_stage2_result     ||
                    instr2[11:17] == ls_stage3_result     ||
                    instr2[11:17] == ls_stage4_result     ||
                    instr2[11:17] == ls_stage5_result     ||
                    instr2[11:17] == ls_stage6_result     ||
                    instr2[11:17] == branch_stage1_result ||
                    instr2[11:17] == branch_stage2_result ||
                    instr2[11:17] == branch_stage3_result ||
                    //
                    instr2[25:31] == fx1_stage1_result    ||
                    instr2[25:31] == fx1_stage2_result    ||
                    instr2[25:31] == byte_stage1_result   ||
                    instr2[25:31] == byte_stage2_result   ||
                    instr2[25:31] == byte_stage3_result   ||
                    instr2[25:31] == fx2_stage1_result    ||
                    instr2[25:31] == fx2_stage2_result    ||
                    instr2[25:31] == fx2_stage3_result    ||
                    instr2[25:31] == sp_fp_stage1_result  ||
                    instr2[25:31] == sp_fp_stage2_result  ||
                    instr2[25:31] == sp_fp_stage3_result  ||
                    instr2[25:31] == sp_fp_stage4_result  ||
                    instr2[25:31] == sp_fp_stage5_result  ||
                    instr2[25:31] == sp_fp_stage6_result  ||
                    instr2[25:31] == sp_int_stage1_result ||
                    instr2[25:31] == sp_int_stage2_result ||
                    instr2[25:31] == sp_int_stage3_result ||
                    instr2[25:31] == sp_int_stage4_result ||
                    instr2[25:31] == sp_int_stage5_result ||
                    instr2[25:31] == sp_int_stage6_result ||
                    instr2[25:31] == sp_int_stage7_result ||
                    instr2[25:31] == perm_stage1_result   ||
                    instr2[25:31] == perm_stage2_result   ||
                    instr2[25:31] == perm_stage3_result   ||
                    instr2[25:31] == ls_stage1_result     ||
                    instr2[25:31] == ls_stage2_result     ||
                    instr2[25:31] == ls_stage3_result     ||
                    instr2[25:31] == ls_stage4_result     ||
                    instr2[25:31] == ls_stage5_result     ||
                    instr2[25:31] == ls_stage6_result     ||
                    instr2[25:31] == branch_stage1_result ||
                    instr2[25:31] == branch_stage2_result ||
                    instr2[25:31] == branch_stage3_result ||
                    (instr1[4:10] == instr2[4:10]) || (instr1_pipe == instr2_pipe)) begin
                        dep_stall_instr2 = 1;
                    end
            end
        end
    end

    always_ff @(posedge clk ) begin : IssueLogicController
        if(dep_stall_instr2 && !dep_stall_instr1 && !issue_done) begin
            issue_done <= 1;
        end
        else if(!dep_stall_instr2 && issue_done)begin
            issue_done <= 0;
        end
    end

        
    
        
    
endmodule