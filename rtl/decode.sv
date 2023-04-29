module decode (
    clk,
    reset,
    instr1_dec_input,
    instr2,
    dep_stall_instr1,
    dep_stall_instr2,
    issue_even_opcode,
    issue_odd_opcode,
    issue_addr_ra_rd_even,
    issue_addr_rb_rd_even,
    issue_addr_rc_rd_even,
    issue_addr_rt_wt_even,
    issue_addr_ra_rd_odd,
    issue_addr_rb_rd_odd,
    issue_addr_rc_rd_odd,
    issue_addr_rt_wt_odd,
    issue_imm7_even,
    issue_imm7_odd,
    issue_imm10_even,
    issue_imm10_odd,
    issue_imm16_odd,
    issue_imm18_odd,
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
    parameter REG_ADDR = UNIT_ID_SIZE + 1;  //Location of the register address in the 139-bit stage packet.

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

    input [0 : WORD - 1] instr1_dec_input, instr2;
    logic issue_done;
    output logic dep_stall_instr2, dep_stall_instr1;
    output logic [0 : INTERNAL_OPCODE_SIZE - 1] issue_even_opcode, issue_odd_opcode;   //both conntected to even and odd pipe RESPECTIVELY.
    logic instr1_pipe, instr2_pipe;  //1 => even, 0 => odd
    logic [0 : INTERNAL_OPCODE_SIZE - 1]    a,b,c,d,e,dec_instr1_opcode_even, dec_instr1_opcode_odd, dec_instr2_opcode_even, dec_instr2_opcode_odd, opcode_even, opcode_odd;
    output logic [0 : IMM7 - 1]             issue_imm7_even, issue_imm7_odd;
    output logic [0 : IMM10 - 1]            issue_imm10_even, issue_imm10_odd;
    output logic [0 : IMM16 - 1]            issue_imm16_odd;
    output logic [0 : IMM18 - 1]            issue_imm18_odd;
    // logic [0 : REG_ADDR_WIDTH - 1]          dec_addr_ra_rd_even, dec_addr_rb_rd_even, dec_addr_rc_rd_even, dec_addr_ra_rd_odd, dec_addr_rb_rd_odd, dec_addr_rc_rd_odd;  //Decoder output to issue logic
    logic [0 : REG_ADDR_WIDTH - 1]          dec_instr1_addr_ra_rd_even, dec_instr1_addr_rb_rd_even, dec_instr1_addr_rc_rd_even, dec_instr1_addr_ra_rd_odd, dec_instr1_addr_rb_rd_odd, dec_instr1_addr_rc_rd_odd;  //Decoder output to issue logic
    logic [0 : REG_ADDR_WIDTH - 1]          dec_instr2_addr_ra_rd_even, dec_instr2_addr_rb_rd_even, dec_instr2_addr_rc_rd_even, dec_instr2_addr_ra_rd_odd, dec_instr2_addr_rb_rd_odd, dec_instr2_addr_rc_rd_odd;  //Decoder output to issue logic
    output logic [0 : REG_ADDR_WIDTH - 1]          issue_addr_ra_rd_even, issue_addr_rb_rd_even, issue_addr_rc_rd_even, issue_addr_ra_rd_odd, issue_addr_rb_rd_odd, issue_addr_rc_rd_odd;  //Issue Logic input
    logic [0 : REG_ADDR_WIDTH - 1]          dec_instr1_addr_rt_wt_even, dec_instr1_addr_rt_wt_odd, dec_instr2_addr_rt_wt_even, dec_instr2_addr_rt_wt_odd;
    output logic [0 : REG_ADDR_WIDTH - 1]   issue_addr_rt_wt_even, issue_addr_rt_wt_odd;
    logic [0 : IMM7 - 1]             dec_instr1_imm7_even, dec_instr2_imm7_even,  dec_instr1_imm7_odd, dec_instr2_imm7_odd;
    logic [0 : IMM10 - 1]            dec_instr1_imm10_even, dec_instr2_imm10_even,  dec_instr1_imm10_odd, dec_instr2_imm10_odd;
    logic [0 : IMM16 - 1]            dec_instr1_imm16_odd, dec_instr2_imm16_odd;
    logic [0 : IMM18 - 1]            dec_instr1_imm18_odd, dec_instr2_imm18_odd;
    logic                                   dec_instr1_regWr_even, dec_instr1_regWr_odd, dec_instr2_regWr_even, dec_instr2_regWr_odd;
    logic                                   issue_regWr_even, issue_regWr_odd;
    logic [0 : UNIT_ID_SIZE - 1]            dec_instr1_unitId_even, dec_instr1_unitId_odd, dec_instr2_unitId_even, dec_instr2_unitId_odd;
    logic [0 : UNIT_ID_SIZE - 1]            issue_unitId_even, issue_unitId_odd;

    logic [0:15] instr_ROM_4 [0:4] = {
        {floating_multiply_and_add ,  FLOATING_MULTIPLY_AND_ADD ,  1'b1, 1'b1, 3'd4},
        {floating_negative_multiply_and_substract ,  FLOATING_NEGATIVE_MULTIPLY_AND_SUBSTRACT ,  1'b1, 1'b1, 3'd4},
        {floating_multiply_and_subtract ,  FLOATING_MULTIPLY_AND_SUBTRACT ,  1'b1, 1'b1, 3'd4},
        {multiply_and_add ,  MULTIPLY_AND_ADD ,  1'b1, 1'b1, 3'd4},
        {shuffle_bytes ,  SHUFFLE_BYTES ,  1'b0, 1'b1, 3'd5}
    };
    logic [0:18] instr_ROM_7 [0:0] = {
        {immediate_load_address,  IMMEDIATE_LOAD_ADDRESS ,  1'b0, 1'b1, 3'd6}
    };
    logic [0:19] instr_ROM_8[0:19] = {
        {add_word_immediate ,  ADD_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {subtract_from_word_immediate ,  SUBTRACT_FROM_WORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {add_halfword_immediate ,  ADD_HALFWORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {subtract_from_halfword_immediate ,  SUBTRACT_FROM_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {and_halfword_immediate ,  AND_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {and_word_immediate ,  AND_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {or_halfword_immediate ,  OR_HALFWORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {or_word_immediate ,  OR_WORD_IMMEDIATE,  1'b1, 1'b1, 3'd1},
        {exclusive_or_halfword_immediate ,  EXCLUSIVE_OR_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {exclusive_or_word_immediate ,  EXCLUSIVE_OR_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_equal_halfword_immediate ,  COMPARE_EQUAL_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_equal_word_immediate ,  COMPARE_EQUAL_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_halfword_immediate ,  COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_word_immediate ,  COMPARE_GREATER_THAN_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_halfword_immediate,  COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_word_immediate ,  COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE ,  1'b1, 1'b1, 3'd1},
        {multiply_immediate ,  MULTIPLY_IMMEDIATE ,  1'b1, 1'b1, 3'd4},
        {multiply_unsigned_immediate ,  MULTIPLY_UNSIGNED_IMMEDIATE ,  1'b1, 1'b1, 3'd4},
        {load_quadword_d ,  LOAD_QUADWORD_D ,  1'b0, 1'b1, 3'd6},
        {store_quadword_d ,  STORE_QUADWORD_D ,  1'b0, 1'b0, 3'd6}
    };
    logic [0:20] instr_ROM_9 [0:11] = {
        {load_quadword_a ,  LOAD_QUADWORD_A ,  1'b0, 1'b1, 3'd6},
        {store_quadword_a ,  STORE_QUADWORD_A ,  1'b0, 1'b0, 3'd6},
        {immediate_load_halfword ,  IMMEDIATE_LOAD_HALFWORD ,  1'b0, 1'b1, 3'd6},
        {immediate_load_word ,  IMMEDIATE_LOAD_WORD ,  1'b0, 1'b1, 3'd6},
        {branch_relative ,  BRANCH_RELATIVE ,  1'b0, 1'b0, 3'd7},
        {branch_absolute ,  BRANCH_ABSOLUTE ,  1'b0, 1'b0, 3'd7},
        {branch_relative_and_set_link ,  BRANCH_RELATIVE_AND_SET_LINK ,  1'b0, 1'b1, 3'd7},
        {branch_absolute_and_set_link ,  BRANCH_ABSOLUTE_AND_SET_LINK ,  1'b0, 1'b1, 3'd7},
        {branch_if_not_zero_word ,  BRANCH_IF_NOT_ZERO_WORD ,  1'b0, 1'b0, 3'd7},
        {branch_if_zero_word ,  BRANCH_IF_ZERO_WORD ,  1'b0, 1'b0, 3'd7},
        {branch_if_not_zero_halfword ,  BRANCH_IF_NOT_ZERO_HALFWORD ,  1'b0, 1'b0, 3'd7},
        {branch_if_zero_halfword ,  BRANCH_IF_ZERO_HALFWORD ,  1'b0, 1'b0, 3'd7}
    };
    logic [0:22] instr_ROM_11 [0:57] = { //EVEN = 1, ODD = 0;
        //{opcoe, bit-padding, internal_opcode, even-odd bit, regWr-bit, unitID}
        // {rotate_quadword_by_bytes ,  ROTATE_QUADWORD_BY_BYTES ,  1'b0, 1'b1, 3'd5},
        {add_word,   ADD_WORD, 1'b1, 1'b1, 3'd1},
        {subtract_from_word ,   SUBTRACT_FROM_WORD ,  1'b1, 1'b1, 3'd1},
        {add_extended ,   ADD_EXTENDED ,  1'b1, 1'b1, 3'd1},
        {carry_generate ,   CARRY_GENERATE ,  1'b1, 1'b1, 3'd1},
        {subtract_from_extended ,   SUBTRACT_FROM_EXTENDED ,  1'b1, 1'b1, 3'd1},
        {borrow_generate ,   BORROW_GENERATE ,  1'b1, 1'b1, 3'd1},
        {add_halfword ,   ADD_HALFWORD,  1'b1, 1'b1, 3'd1},
        {subtract_from_halfword ,   SUBTRACT_FROM_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {count_leading_zeros ,   COUNT_LEADING_ZEROS ,  1'b1, 1'b1, 3'd1},
        {form_select_mask_for_halfword ,   FORM_SELECT_MASK_FOR_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {form_select_mark_for_words ,   FORM_SELECT_MARK_FOR_WORDS ,  1'b1, 1'b1, 3'd1},
        {And ,   AND ,  1'b1, 1'b1, 3'd1},
        {and_with_complement ,   AND_WITH_COMPLEMENT ,  1'b1, 1'b1, 3'd1},
        {Or ,   OR ,  1'b1, 1'b1, 3'd1},
        {or_with_complement ,   OR_WITH_COMPLEMENT ,  1'b1, 1'b1, 3'd1},
        {exclusive_or ,   EXCLUSIVE_OR ,  1'b1, 1'b1, 3'd1},
        {Nand ,   NAND ,  1'b1, 1'b1, 3'd1},
        {Nor ,   NOR ,  1'b1, 1'b1, 3'd1},
        {compare_equal_halfword ,   COMPARE_EQUAL_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {compare_equal_word ,   COMPARE_EQUAL_WORD ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_halfword ,   COMPARE_GREATER_THAN_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {compare_greater_than_word ,   COMPARE_GREATER_THAN_WORD ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_halfword ,   COMPARE_LOGICAL_GREATER_THAN_HALFWORD ,  1'b1, 1'b1, 3'd1},
        {compare_logical_greater_than_word ,   COMPARE_LOGICAL_GREATER_THAN_WORD ,  1'b1, 1'b1, 3'd1},
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
        {flaoting_multiply ,   FLAOTING_MULTIPLY ,  1'b1, 1'b1, 3'd4},
        {multiply ,   MULTIPLY ,  1'b1, 1'b1, 3'd4},
        {multiply_unsigned ,   MULTIPLY_UNSIGNED ,  1'b1, 1'b1, 3'd4},
        {count_ones_in_bytes ,   COUNT_ONES_IN_BYTES ,  1'b1, 1'b1, 3'd2},
        {absolute_differences_of_bytes ,   ABSOLUTE_DIFFERENCES_OF_BYTES ,  1'b1, 1'b1, 3'd2},
        {average_bytes ,   AVERAGE_BYTES ,  1'b1, 1'b1, 3'd2},
        {sum_bytes_into_halfword ,   SUM_BYTES_INTO_HALFWORD ,  1'b1, 1'b1, 3'd2},
        {shift_left_quadword_by_bits ,   SHIFT_LEFT_QUADWORD_BY_BITS ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bits_immediate ,  SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bytes ,  SHIFT_LEFT_QUADWORD_BY_BYTES ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bytes_immediate ,  SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {shift_left_quadword_by_bytes_from_bit_shift_count ,  SHIFT_LEFT_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bytes ,  ROTATE_QUADWORD_BY_BYTES ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bytes_immediate ,  ROTATE_QUADWORD_BY_BYTES_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bytes_from_bit_shift_count ,  ROTATE_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bits ,  ROTATE_QUADWORD_BY_BITS ,  1'b0, 1'b1, 3'd5},
        {rotate_quadword_by_bits_immediate,  ROTATE_QUADWORD_BY_BITS_IMMEDIATE ,  1'b0, 1'b1, 3'd5},
        {gather_bits_from_bytes ,  GATHER_BITS_FROM_BYTES ,  1'b0, 1'b1, 3'd5},
        {gather_bits_from_halfword ,  GATHER_BITS_FROM_HALFWORD ,  1'b0, 1'b1, 3'd5},
        {gather_bits_from_words ,  GATHER_BITS_FROM_WORDS ,  1'b0, 1'b1, 3'd5},
        {load_quadword_x ,   LOAD_QUADWORD_X ,  1'b0, 1'b1, 3'd6},
        {store_quadword_x ,   STORE_QUADWORD_X ,  1'b0, 1'b0, 3'd6},
        {nop ,   NOP ,  1'b1, 1'b0, 3'd0},
        {lnop ,   LNOP ,  1'b0, 1'b0, 3'd0}

        
    };    //Instr ROM 11 bit opcodes

    //TODO: remove this
    //logic [0:6] array_even [0:2] = '{fx1_stage1_result[UNIT_ID_SIZE + 1 +: REG_ADDR_WIDTH], fx1_stage2_result[UNIT_ID_SIZE + 1 +: REG_ADDR_WIDTH], byte_stage1_result[UNIT_ID_SIZE + 1 +: REG_ADDR_WIDTH]} ;

    always_comb begin : Decoder_Route_Logic
            //instr1 decode
            for (int i = 0; i < 96; i++) begin
                //RR_RI7 type (11-bit opcode)
                if(instr1[0:10] == instr_ROM_11[i][0:10]) begin
                    if(instr_ROM_11[i][18]) begin
                        dec_instr1_addr_ra_rd_even = instr1[18:24];
                        dec_instr1_addr_rb_rd_even = instr1[11:17];
                        dec_instr1_addr_rt_wt_even = instr1[25:31];
                        dec_instr1_imm7_even = instr1[11:17];
                        dec_instr1_opcode_even = instr_ROM_11[i][11 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 1;
                        dec_instr1_regWr_even = instr_ROM_11[i][19];
                    end
                    else begin
                        dec_instr1_addr_ra_rd_odd = instr1[18:24];
                        dec_instr1_addr_rb_rd_odd = instr1[11:17];
                        dec_instr1_addr_rt_wt_odd = instr1[25:31];
                        dec_instr1_imm7_odd = instr1[11:17];
                        // a = instr_ROM_11[i][11 +: INTERNAL_OPCODE_SIZE];
                        dec_instr1_opcode_odd = instr_ROM_11[i][11 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 0;
                        dec_instr1_regWr_odd = instr_ROM_11[i][19];
                    end                                  //TODO: instr1_pipe = instr_ROM[i][18]
                    // break;
                end
                //RI16 type (9-bit opcode)
                else if(instr1[0:8] == instr_ROM_9[i][0:8]) begin   //no RI16 instr for even pipe
                    if(instr_ROM_9[i][16]) begin
                        dec_instr1_addr_rt_wt_even = instr1[25:31];
                        dec_instr1_opcode_even = instr_ROM_9[i][9 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 1;
                        dec_instr1_regWr_even = instr_ROM_9[i][17];
                    end
                    else begin
                        dec_instr1_imm16_odd = instr1[9:24];
                        dec_instr1_addr_rt_wt_odd = instr1[25:31];
                        // b = instr_ROM_9[i][9 +: INTERNAL_OPCODE_SIZE];
                        dec_instr1_opcode_odd = instr_ROM_9[i][9 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 0;
                        dec_instr1_regWr_odd = instr_ROM_9[i][17];
                    end
                    // break;
                end
                //RI10 type (8-bit opcode)
                else if(instr1[0:7] == instr_ROM_8[i][0:7]) begin
                    if(instr_ROM_8[i][15]) begin
                        // $display("%d %d", instr_ROM_8[i][11:17], i);
                        dec_instr1_imm10_even = instr1[8:17];
                        dec_instr1_addr_ra_rd_even = instr1[18:24];
                        dec_instr1_addr_rt_wt_even = instr1[25:31];
                        dec_instr1_opcode_even = instr_ROM_8[i][8 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 1;
                        dec_instr1_regWr_even = instr_ROM_8[i][16];
                    end
                    else begin
                        dec_instr1_imm10_odd = instr1[8:17];
                        dec_instr1_addr_ra_rd_odd = instr1[18:24];
                        dec_instr1_addr_rt_wt_odd = instr1[25:31];
                        dec_instr1_opcode_odd = instr_ROM_8[i][8 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 0;
                        dec_instr1_regWr_odd = instr_ROM_8[i][16];
                    end
                    // break;
                end
                //RI18 type (7-bit opcode)
                else if(instr1[0:6] == instr_ROM_7[i][0:6]) begin //TODO: no even instr wit 7-bit opcode so remove if-else later
                    if(instr_ROM_7[i][14]) begin
                        dec_instr1_addr_rt_wt_even = instr1[25:31];
                        dec_instr1_opcode_even = instr_ROM_7[i][7 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 1;
                        dec_instr1_regWr_even = instr_ROM_7[i][15];
                    end
                    else begin
                        dec_instr1_imm18_odd = instr1[7:24];
                        dec_instr1_addr_rt_wt_odd = instr1[25:31];
                        dec_instr1_opcode_odd = instr_ROM_7[i][7 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 0;
                        dec_instr1_regWr_odd = instr_ROM_7[i][15];
                    end
                //    break;
                end
                //RRR type (4-bit opcode)
                else if(instr1[0:3] == instr_ROM_4[i][0:3]) begin
                    if(instr_ROM_4[i][11]) begin
                        dec_instr1_addr_ra_rd_even = instr1[18:24];
                        dec_instr1_addr_rb_rd_even = instr1[11:17];
                        dec_instr1_addr_rc_rd_even = instr1[25:31];
                        dec_instr1_addr_rt_wt_even = instr1[4:10];
                        dec_instr1_opcode_even = instr_ROM_4[i][4 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 1;
                        dec_instr1_regWr_even = instr_ROM_4[i][12];
                    end
                    else begin
                        dec_instr1_addr_ra_rd_odd = instr1[18:24];
                        dec_instr1_addr_rb_rd_odd = instr1[11:17];
                        dec_instr1_addr_rc_rd_odd = instr1[25:31]; //Decoder output
                        dec_instr1_addr_rc_rd_odd = instr1[25:31];
                        dec_instr1_addr_rt_wt_odd = instr1[4:10];
                        dec_instr1_opcode_odd = instr_ROM_4[i][4 +: INTERNAL_OPCODE_SIZE];
                        instr1_pipe = 0;
                        dec_instr1_regWr_odd = instr_ROM_4[i][12];
                    end
                    // break;
                end
            // break;    
            end


            //instr2 decode
            for (int i = 0; i < 96; i++) begin
                //RR_RI7 type (11-bit opcode)
                if(instr2[0:10] == instr_ROM_11[i][0:10]) begin
                    // $display("%d", instr_ROM[i]);
                    if(instr_ROM_11[i][18]) begin
                        
                        // $display("%d", instr_ROM[i]);
                        dec_instr2_addr_ra_rd_even = instr2[18:24];
                        dec_instr2_addr_rb_rd_even = instr2[11:17];
                        dec_instr2_addr_rt_wt_even = instr2[25:31];
                        dec_instr2_imm7_even = instr2[11:17];
                        dec_instr2_opcode_even = instr_ROM_11[i][11 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 1;
                        dec_instr2_regWr_even = instr_ROM_11[i][19];

                        
                    end
                    else begin
                        dec_instr2_addr_ra_rd_odd = instr2[18:24];
                        dec_instr2_addr_rb_rd_odd = instr2[11:17];
                        dec_instr2_addr_rt_wt_odd = instr2[25:31];
                        dec_instr2_imm7_odd = instr2[11:17];
                        dec_instr2_opcode_odd = instr_ROM_11[i][11 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 0;
                        dec_instr2_regWr_odd = instr_ROM_11[i][19];
                    end
                    // break;
                end
                //RI16 type (9-bit opcode)
                else if(instr2[0:8] == instr_ROM_9[i][0:8]) begin
                    if(instr_ROM_9[i][16]) begin
                        dec_instr2_addr_rt_wt_even = instr2[25:31];
                        dec_instr2_opcode_even = instr_ROM_9[i][9 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 1;
                        dec_instr2_regWr_even = instr_ROM_9[i][17];
                    end
                    else begin
                        dec_instr2_imm16_odd = instr2[9:24];
                        dec_instr2_addr_rt_wt_odd = instr2[25:31];
                        dec_instr2_opcode_odd = instr_ROM_9[i][9 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 0;
                        dec_instr2_regWr_odd = instr_ROM_9[i][17];
                    end
                    // break;
                end
                //RI10 type (8-bit opcode)
                else if(instr2[0:7] == instr_ROM_8[i][0:7]) begin
                    if(instr_ROM_8[i][15]) begin
                        dec_instr2_imm10_even = instr2[8:17];
                        dec_instr2_addr_ra_rd_even = instr2[18:24];
                        dec_instr2_addr_rt_wt_even = instr2[25:31];
                        dec_instr2_opcode_even = instr_ROM_8[i][8 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 1;
                        dec_instr2_regWr_even = instr_ROM_8[i][16];
                    end
                    else begin
                        dec_instr2_imm10_odd = instr2[8:17];
                        dec_instr2_addr_ra_rd_odd = instr2[18:24];
                        dec_instr2_addr_rt_wt_odd = instr2[25:31];
                        dec_instr2_opcode_odd = instr_ROM_8[i][8 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 0;
                        dec_instr2_regWr_odd = instr_ROM_8[i][16];
                    end
                    // break;
                end
                //RI18 type (7-bit opcode)
                else if(instr2[0:6] == instr_ROM_7[i][0:6]) begin
                    if(instr_ROM_7[i][14]) begin
                        dec_instr2_addr_rt_wt_even = instr2[25:31];
                        dec_instr2_opcode_even = instr_ROM_7[i][7 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 1;
                        dec_instr2_regWr_even = instr_ROM_7[i][15];
                    end
                    else begin
                        dec_instr2_imm18_odd = instr2[7:24];
                        dec_instr2_addr_rt_wt_odd = instr2[25:31];
                        dec_instr2_opcode_odd = instr_ROM_7[i][7 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 0;
                        dec_instr2_regWr_odd = instr_ROM_7[i][15];
                    end
                //    break;
                end
                //RRR type (4-bit opcode)
                else if(instr2[0:3] == instr_ROM_4[i][0:3]) begin
                    if(instr_ROM_4[i][11]) begin
                        dec_instr2_addr_ra_rd_even = instr2[18:24];
                        dec_instr2_addr_rb_rd_even = instr2[11:17];
                        dec_instr2_addr_rc_rd_even = instr2[25:31];
                        dec_instr2_addr_rt_wt_even = instr2[4:10];
                        dec_instr2_opcode_even = instr_ROM_4[i][4 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 1;
                        dec_instr2_regWr_even = instr_ROM_4[i][12];
                    end
                    else begin
                        dec_instr2_addr_ra_rd_odd = instr2[18:24];
                        dec_instr2_addr_rb_rd_odd = instr2[11:17];
                        dec_instr2_addr_rc_rd_odd = instr2[25:31]; //Decoder output
                        //dec_addr_rc_rd_odd = instr2[25:31];
                        dec_instr2_addr_rt_wt_odd = instr2[4:10];
                        dec_instr2_opcode_odd = instr_ROM_4[i][4 +: INTERNAL_OPCODE_SIZE];
                        instr2_pipe = 0;
                        dec_instr2_regWr_odd = instr_ROM_4[i][12];
                    end
                    // break;
                end
            // break;        
            end
        // end
    end


    always_comb begin : HazardChk
        dep_stall_instr1 = 0;
        dep_stall_instr2 = 0;

        //TODO: check for regWr signals also when checking hazard
        //RAW hazard check for instruction 1 - if hazard, stall both because in-order-execution
        for (int i = 0; i < 96; i++) begin
            if(instr1[0:10] == instr_ROM_11[i][0:10]) begin
                if( (instr1[18:24] == issue_addr_rt_wt_even && issue_regWr_even) || (instr1[18:24] == issue_addr_rt_wt_odd && issue_regWr_odd) ||
                    (instr1[18:24] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    // (instr1[18:24] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    // (instr1[18:24] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    //
                    (instr1[11:17] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE])) begin
                        dep_stall_instr1 = 1;
                        dep_stall_instr2 = 1;
                    end
                    else begin 
                        dep_stall_instr1 = 0;
                        dep_stall_instr2 = 0;
                    end
            end

            else if(instr1[0:7] == instr_ROM_8[i][0:7]) begin
                if( (instr1[18:24] == issue_addr_rt_wt_even && issue_regWr_even) || (instr1[18:24] == issue_addr_rt_wt_odd && issue_regWr_odd) ||
                    (instr1[18:24] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE])) begin
                        dep_stall_instr1 = 1;
                    end
                    else begin 
                        dep_stall_instr1 = 0;
                        dep_stall_instr2 = 0;
                    end
            end

            else if(instr1[0:3] == instr_ROM_4[i][0:3]) begin
                if( (instr1[18:24] == issue_addr_rt_wt_even && issue_regWr_even) || (instr1[18:24] == issue_addr_rt_wt_odd && issue_regWr_odd) ||
                    (instr1[18:24] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[18:24] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    //
                    (instr1[11:17] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[11:17] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    //
                    (instr1[25:31] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr1[25:31] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE])) begin
                        dep_stall_instr1 = 1;
                    end
                    else begin 
                        dep_stall_instr1 = 0;
                        dep_stall_instr2 = 0;
                    end
            end
        end

        //RAW, WAW and Strutural Hazard check for instruction 2
        for (int i = 0; i < 96; i++) begin
            if(instr2[0:10] == instr_ROM_11[i][0:10]) begin
                //RAW hazard check for instruction 2
                if( (instr2[18:24] == issue_addr_rt_wt_even && issue_regWr_even) || (instr2[18:24] == issue_addr_rt_wt_odd && issue_regWr_odd) ||
                    (instr2[18:24] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    // (instr2[18:24] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    //
                    (instr2[11:17] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) || 
                    (instr1_pipe == instr2_pipe) || 
                    (((instr1_pipe ? dec_instr1_addr_rt_wt_even : dec_instr1_addr_rt_wt_odd) == (instr2_pipe ? dec_instr2_addr_rt_wt_even : dec_instr2_addr_rt_wt_odd)) &&
                    ((instr1_pipe ? dec_instr1_regWr_even : dec_instr1_regWr_odd) && (instr2_pipe ? dec_instr2_regWr_even : dec_instr2_regWr_odd)))) begin     //WAW or Structural Hazard
                        // a = 1;
                        dep_stall_instr2 = 1;
                    end
                    else begin 
                        dep_stall_instr2 = 0;
                        // a = 0;
                    end
            end

            else if(instr2[0:7] == instr_ROM_8[i][0:7]) begin
                if( (instr2[18:24] == issue_addr_rt_wt_even && issue_regWr_even) || (instr2[18:24] == issue_addr_rt_wt_odd && issue_regWr_odd) ||
                    (instr2[18:24] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1_pipe == instr2_pipe) || ((((instr1_pipe ? dec_instr1_addr_rt_wt_even : dec_instr1_addr_rt_wt_odd) == (instr2_pipe ? dec_instr2_addr_rt_wt_even : dec_instr2_addr_rt_wt_odd)) &&
                    ((instr1_pipe ? dec_instr1_regWr_even : dec_instr1_regWr_odd) && (instr2_pipe ? dec_instr2_regWr_even : dec_instr2_regWr_odd))))) begin
                        // b = 1;
                        dep_stall_instr2 = 1;
                    end
                    else begin 
                        dep_stall_instr2 = 0;
                        // b = 0;
                    end
            end

            else if(instr2[0:3] == instr_ROM_4[i][0:3]) begin
                if( (instr2[18:24] == issue_addr_rt_wt_even && issue_regWr_even) || (instr2[18:24] == issue_addr_rt_wt_odd && issue_regWr_odd) ||
                    (instr2[18:24] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[18:24] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    //
                    (instr2[11:17] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[11:17] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    //
                    (instr2[25:31] == fx1_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == fx1_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx1_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == byte_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == byte_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == byte_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (byte_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == fx2_stage1_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage1_result    [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == fx2_stage2_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage2_result    [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == fx2_stage3_result    [REG_ADDR +: REG_ADDR_WIDTH]) && (fx2_stage3_result    [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_fp_stage1_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage1_result  [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_fp_stage2_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage2_result  [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_fp_stage3_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage3_result  [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_fp_stage4_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage4_result  [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_fp_stage5_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage5_result  [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_fp_stage6_result  [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_fp_stage6_result  [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_int_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_int_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_int_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage3_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_int_stage4_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage4_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_int_stage5_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage5_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_int_stage6_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage6_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == sp_int_stage7_result [REG_ADDR +: REG_ADDR_WIDTH]) && (sp_int_stage7_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == perm_stage1_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage1_result   [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == perm_stage2_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage2_result   [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == perm_stage3_result   [REG_ADDR +: REG_ADDR_WIDTH]) && (perm_stage3_result   [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == ls_stage1_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage1_result     [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == ls_stage2_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage2_result     [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == ls_stage3_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage3_result     [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == ls_stage4_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage4_result     [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == ls_stage5_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage5_result     [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == ls_stage6_result     [REG_ADDR +: REG_ADDR_WIDTH]) && (ls_stage6_result     [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == branch_stage1_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage1_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == branch_stage2_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage2_result [UNIT_ID_SIZE]) ||
                    (instr2[25:31] == branch_stage3_result [REG_ADDR +: REG_ADDR_WIDTH]) && (branch_stage3_result [UNIT_ID_SIZE]) ||
                    (instr1_pipe == instr2_pipe) ||
                    (((instr1_pipe ? dec_instr1_addr_rt_wt_even : dec_instr1_addr_rt_wt_odd) == (instr2_pipe ? dec_instr2_addr_rt_wt_even : dec_instr2_addr_rt_wt_odd)) &&
                    ((instr1_pipe ? dec_instr1_regWr_even : dec_instr1_regWr_odd) && (instr2_pipe ? dec_instr2_regWr_even : dec_instr2_regWr_odd)))) begin
                        // c = 1;
                        dep_stall_instr2 = 1;
                    end
                    else begin 
                        dep_stall_instr2 = 0;
                        // c = 0;
                    end

            end

            // else if (((instr1_pipe ? dec_instr1_addr_rt_wt_even : dec_instr1_addr_rt_wt_odd) == (instr2_pipe ? dec_instr2_addr_rt_wt_even : dec_instr2_addr_rt_wt_odd)) &&
            //         ((instr1_pipe ? dec_instr1_regWr_even : dec_instr1_regWr_odd) && (instr2_pipe ? dec_instr2_regWr_even : dec_instr2_regWr_odd))) begin
            //     dep_stall_instr2 = 1;
            // end 
            // else dep_stall_instr2 = 0;

            // if (((instr2_pipe ? dec_instr2_addr_rt_wt_even : dec_instr2_addr_rt_wt_odd) == (instr1_pipe ? dec_instr1_addr_rt_wt_even : dec_instr1_addr_rt_wt_odd)) && 
            //         (instr1_pipe ? dec_instr1_regWr_even:dec_instr1_regWr_odd) && dec_instr2_regWr_even) begin
            //     dep_stall_instr2 = 1;
            // end
            // else dep_stall_instr2 = 0;

        end

        
    end

    always_comb begin : IssueLogic
        if(issue_done) begin
            if(instr2_pipe)
                instr1 = {lnop, 21'd0};
            else
                instr1 = {nop, 21'd0};
        end
        else begin
            instr1 = instr1_dec_input;
        end

    end

    always_ff @(posedge clk ) begin : IssueLogicController
        if(reset)
            issue_done <= 0;
        else begin
            if(dep_stall_instr2 && !dep_stall_instr1 && !issue_done) begin
                issue_done <= 1;
            end
            else if(!dep_stall_instr2 && issue_done)begin
                issue_done <= 0;
            end
        end

        if(dep_stall_instr1) begin
            issue_even_opcode <= NOP;
            issue_odd_opcode <= LNOP;
            issue_addr_ra_rd_even <= 0;
            issue_addr_rb_rd_even <= 0;
            issue_addr_rc_rd_even <= 0;
            issue_addr_ra_rd_odd <= 0;
            issue_addr_rb_rd_odd <= 0;
            issue_addr_rc_rd_odd <= 0; //Decoder output
            issue_addr_rc_rd_odd <= 0;
            issue_addr_rt_wt_even <= 0;
            issue_addr_rt_wt_odd <= 0;
            issue_imm7_even <= 0;
            issue_imm7_odd <= 0;
            issue_imm10_even <= 0;
            issue_imm10_odd <= 0;
            issue_imm16_odd <= 0;
            issue_imm18_odd <= 0;
            issue_regWr_even <= 0;
            issue_regWr_odd <= 0;
        end
        else if (dep_stall_instr2 && !dep_stall_instr1) begin
            // if(!issue_done) begin
                if(instr1_pipe) begin
                    issue_even_opcode <= dec_instr1_opcode_even;       //issue_even_opcode always connected to even pipe and same for odd
                    issue_addr_ra_rd_even <= dec_instr1_addr_ra_rd_even;      //TODO: no need of issue_addr_....., just pass dec_addr_... as output to this module, only opcode requires that issue since we need to route it. //Updated, NO-TODO: actually it is required since it is a stage - should go throught the register at posedge to next stage.
                    issue_addr_rb_rd_even <= dec_instr1_addr_rb_rd_even;
                    issue_addr_rc_rd_even <= dec_instr1_addr_rc_rd_even;
                    issue_addr_rt_wt_even <= dec_instr1_addr_rt_wt_even;

                    issue_odd_opcode <= LNOP;
                    issue_addr_ra_rd_odd <= 0;
                    issue_addr_rb_rd_odd <= 0;
                    issue_addr_rc_rd_odd <= 0;
                    issue_addr_rt_wt_odd <= 0;

                    issue_imm7_even <= dec_instr1_imm7_even;
                    issue_imm10_even <= dec_instr1_imm10_even;

                    issue_regWr_even <= dec_instr1_regWr_even;
                    
                end
                else begin
                    issue_odd_opcode <= dec_instr1_opcode_odd;        //think of criss-cross routing
                    issue_addr_ra_rd_odd <= dec_instr1_addr_ra_rd_odd;
                    issue_addr_rb_rd_odd <= dec_instr1_addr_rb_rd_odd;
                    issue_addr_rc_rd_odd <= dec_instr1_addr_rc_rd_odd;
                    issue_addr_rt_wt_odd <= dec_instr1_addr_rt_wt_odd;

                    issue_even_opcode <= NOP;
                    issue_addr_ra_rd_even <= 0;
                    issue_addr_rb_rd_even <= 0;
                    issue_addr_rc_rd_even <= 0;
                    issue_addr_rt_wt_even <= 0;

                    issue_imm7_odd <= dec_instr1_imm7_odd;
                    issue_imm10_odd <= dec_instr1_imm10_odd;
                    issue_imm16_odd <= dec_instr1_imm16_odd;
                    issue_imm18_odd <= dec_instr1_imm18_odd;

                    issue_regWr_odd <= dec_instr1_regWr_odd;
                end
        end
        else begin
                if(instr1_pipe) begin
                    issue_even_opcode <= dec_instr1_opcode_even;
                    issue_addr_ra_rd_even <= dec_instr1_addr_ra_rd_even;
                    issue_addr_rb_rd_even <= dec_instr1_addr_rb_rd_even;
                    issue_addr_rc_rd_even <= dec_instr1_addr_rc_rd_even;
                    issue_addr_rt_wt_even <= dec_instr1_addr_rt_wt_even;
                    
                    issue_imm7_even <= dec_instr1_imm7_even;
                    issue_imm10_even <= dec_instr1_imm10_even;
                    
                    issue_regWr_even <= dec_instr1_regWr_even;
                end
                else begin
                    issue_odd_opcode <= dec_instr1_opcode_odd;
                    issue_addr_ra_rd_odd <= dec_instr1_addr_ra_rd_odd;
                    issue_addr_rb_rd_odd <= dec_instr1_addr_rb_rd_odd;
                    issue_addr_rc_rd_odd <= dec_instr1_addr_rc_rd_odd;
                    issue_addr_rt_wt_odd <= dec_instr1_addr_rt_wt_odd;
                    
                    issue_imm7_odd <= dec_instr1_imm7_odd;
                    issue_imm10_odd <= dec_instr1_imm10_odd;
                    issue_imm16_odd <= dec_instr1_imm16_odd;
                    issue_imm18_odd <= dec_instr1_imm18_odd;
                    
                    issue_regWr_odd <= dec_instr1_regWr_odd;
                    
                end

                if(instr2_pipe) begin
                    issue_even_opcode <= dec_instr2_opcode_even;
                    issue_addr_ra_rd_even <= dec_instr2_addr_ra_rd_even;
                    issue_addr_rb_rd_even <= dec_instr2_addr_rb_rd_even;
                    issue_addr_rc_rd_even <= dec_instr2_addr_rc_rd_even;
                    issue_addr_rt_wt_even <= dec_instr2_addr_rt_wt_even;
                    
                    issue_imm7_even <= dec_instr2_imm7_even;
                    issue_imm10_even <= dec_instr2_imm10_even;

                    issue_regWr_even <= dec_instr2_regWr_even;
                end
                else begin
                    issue_odd_opcode <= dec_instr2_opcode_odd;
                    issue_addr_ra_rd_odd <= dec_instr2_addr_ra_rd_odd;
                    issue_addr_rb_rd_odd <= dec_instr2_addr_rb_rd_odd;
                    issue_addr_rc_rd_odd <= dec_instr2_addr_rc_rd_odd;
                    issue_addr_rt_wt_odd <= dec_instr2_addr_rt_wt_odd;
                    
                    issue_imm7_odd <= dec_instr2_imm7_odd;
                    issue_imm10_odd <= dec_instr2_imm10_odd;
                    issue_imm16_odd <= dec_instr2_imm16_odd;
                    issue_imm18_odd <= dec_instr2_imm18_odd;

                    issue_regWr_odd <= dec_instr2_regWr_odd;
                end
        
            
        end
    end

        
    
        
    
endmodule