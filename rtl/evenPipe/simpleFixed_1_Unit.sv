
`typedef enum logic [6:0] {

//Simple Fixed 1
    ADD_WORD = 7'd1;
    ADD_WORD_IMMEDIATE = 7'd2
    SUBTRACT_FROM_WORD = 7'd3
    SUBTRACT_FROM_IMMEDIATE= 7'd4
    ADD_EXTENDED = 7'd5
    CARRY_GENERATE = 7'd6
    SUBTRACT_FROM_EXTENDED = 7'd7
    BORROW_GENERATE = 7'd8
    ADD_HALFWORD= 7'd9
    ADD_HALFWORD_IMMEDIATE= 7'd10
    SUBTRACT_FROM_HALFWORD = 7'd11
    SUBTRACT_FROM_HALFWORD_IMMEDIATE = 7'd12
    COUNT_LEADING_ZEROS = 7'd13
    FORM_SELECT_MASK_FOR_HALFWORD = 7'd14
    FORM_SELECT_MARK_FOR_WORDS = 7'd15
    AND = 7'd16
    AND_WITH_COMPLEMENT = 7'd17
    AND_HALFWORD_IMMEDIATE = 7'd18
    AND_WORD_IMMEDIATE = 7'd19
    OR = 7'd20
    OR_WITH_COMPLEMENT = 7'd21
    OR_HALFWORD_IMMEDIATE= 7'd22
    OR_WORD_IMMEDIATE= 7'd23
    EXCLUSIVE_OR = 7'd24
    EXCLUSIVE_OR_HALFWORD_IMMEDIATE = 7'd25
    EXCLUSIVE_OR_WORD_IMMEDIATE = 7'd26
    NAND = 7'd27
    NOR = 7'd28
    COMPARE_EQUAL_HALFWORD = 7'd29
    COMPARE_EQUAL_HALFWORD_IMMEDIATE = 7'd30
    COMPARE_EQUAL_WORD = 7'd31
    COMPARE_EQUAL_WORD_IMMEDIATE = 7'd32
    COMPARE_GREATER_THAN_HALFWORD = 7'd33
    COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE = 7'd34
    COMPARE_GREATER_THAN_WORD = 7'd35
    COMPARE_GREATER_THAN_WORD_IMMEDIATE = 7'd36
    COMPARE_LOGICAL_GREATER_THAN_HALFWORD = 7'd37
    COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE = 7'd38
    COMPARE_LOGICAL_GREATER_THAN_WORD = 7'd39
    COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE = 7'd40

 //Simple Fixed 2
    SHIFT_LEFT_HALFWORD =  7'd41;
    SHIFT_LEFT_HALFWORD_IMMEDIATE = 7'd42;
    SHIFT_LEFT_WORD = 7'd43;
    SHIFT_LEFT_WORD_IMMEDIATE = 7'd44;
    ROTATE_HALFWORD = 7'd45;
    ROTATE_HALFWORD_IMMEDIATE = 7'd46;
    ROTATE_WORD = 7'd47;
    ROTATE_WORD_IMMEDIATE = 7'd48;

 // Branch
    BRANCH_RELATIVE = 7'd49;
    BRANCH_ABSOLUTE = 7'd50;
    BRANCH_RELATIVE_AND_SET_LINK = 7'd51;
    BRANCH_ABSOLUTE_AND_SET_LINK = 7'd52;
    BRANCH_IF_NOT_ZERO_WORD = 7'd53;
    BRANCH_IF_ZERO_WORD = 7'd54;
    BRANCH_IF_NOT_ZERO_HALFWORD = 7'd55;
    BRANCH_IF_ZERO_WORD = 7'd56;

//Single Precision FP MAC
    FLOATING_MULTIPLY_AND_ADD = 7'd57;
    FLOATING_NEGATIVE_MULTIPLY_AND_SUBSTRACT = 7'd58;
    FLOATING_MULTIPLY_AND_SUBTRACT = 7'd59;
    FLAOTING_MULTIPLY = 7'd60;

//Single precision integer MAC   
    MULTIPLY = 7'd61;
    MULTIPLY_UNSIGNED = 7'd62;
    MULTIPLY_IMMEDIATE = 7'd63;
    MULTIPLY_UNSIGNED_IMMEDIATE = 7'd64;
    MULTIPLY_AND_ADD = 7'd65;

//Byte
    COUNT_ONES_IN_BYTES = 7'd66;
    ABSOLUTE_DIFFERENCES_OF_BYTES = 7'd67;
    AVERAGE_BYTES = 7'd68;
    SUM_BYTES_INTO_HALFWORD = 7'd69;

//Permute   
    SHIFT_LEFT_QUADWORD_BY_BITS = 7'd70;
    SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE = 7'd71;
    SHIFT_LEFT_QUADWORD_BY_BYTES = 7'd72;
    SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE = 7'd73
    SHIFT_LEFT_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT = 7'd74;
    ROTATE_QUADWORD_BY_BYTES = 7'd75;
    ROTATE_QUADWORD_BY_BYTES_IMMEDIATE = 7'd76;
    ROTATE_QUADWORD_BY_BYTES_FROM_BIT_SHIFT_COUNT = 7'd77;
    ROTATE_QUADWORD_BY_BITS = 7'd78;
    ROTATE_QUADWORD_BY_BITS_IMMEDIATE = 7'd79;
    GATHER_BITS_FROM_BYTES = 7'd80;
    GATHER_BITS_FROM_HALFWORD = 7'd81;
    GATHER_BITS_FROM_WORDS = 7'd82;
    SHUFFLE_BYTES = 7'd83;

//Load & Store
    LOAD_QUADWORD_D = 7'd84;
    LOAD_QUADWORD_X = 7'd85;
    LOAD_QUADWORD_A = 7'd86;
    STORE_QUADWORD_D = 7'd87;
    STORE_QUADWORD_X = 7'd88;
    STORE_QUADWORD_A = 7'd89;


} internal_opcodes;

module simpleFixed_1_Unit (
    unit_id,
    opcode,
    regWr_en_even,
    ra_rd_even,
    rb_rd_even,
    rc_rd_even,
    rt_wt_even,
    addr_rt_wt_even,
    imm10
);

    input [0 : UNIT_ID_SIZE - 1] unit_id;
    input [0 : INTERNAL_OPCODE_SIZE - 1] opcode;
    input [0 : QUADWORD - 1] ra_rd_even, rb_rd_even, rc_rd_even, rt_wt_even;

    input logic regWr_en_even;
    input logic [0 : REG_ADDR_WIDTH - 1] addr_rt_wt_even;
    input logic [0 : IMM10 - 1] imm10;

    logic [0 : (UNIT_ID_SIZE + INTERNAL_OPCODE_SIZE + QUADWORD) - 1] fx1_stage1_result;
    logic [0 : HALFWORD - 1] temp4;
    logic [0 : WORD - 1] temp, temp2;
    logic [0 : WORD] temp1[3]; //carry generate instr requires additional 1 bit to place the carry bit. (other instr that require this also uses temp1)
    logic [0 : QUADWORD - 1] temp3;




   always_comb begin : SimpleFixed_1_Execution
       
       case (opcode)
           ADD_WORD: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = ra_rd_even[WORD * i : (WORD * (i + 1)) - 1] + rb_rd_even[WORD * i : (WORD * (i + 1)) - 1];
                end
                regWr_en_even = 1;
                
           end
           ADD_WORD_IMMEDIATE: begin
                temp = {22{imm10[0]}, imm10};
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = ra_rd_even[WORD * i : (WORD * (i + 1)) - 1] + temp;
                end
                regWr_en_even = 1;
           end
           SUBTRACT_FROM_WORD: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = ra_rd_even[WORD * i : (WORD * (i + 1)) - 1] - rb_rd_even[WORD * i : (WORD * (i + 1)) - 1];
                end
                regWr_en_even = 1;
           end
           SUBTRACT_FROM_WORD_IMMEDIATE: begin
                temp = {22{imm10[0]}, imm10};
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = temp - ra_rd_even[WORD * i : (WORD * (i + 1)) - 1];
                end
                regWr_en_even = 1;
           end
           ADD_EXTENDED: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = ra_rd_even[WORD * i : (WORD * (i + 1)) - 1] + rb_rd_even[WORD * i : (WORD * (i + 1)) - 1] + rt_wt_even[i * WORD - 1];
                end
                regWr_en_even = 1;
           end
           CARRY_GENERATE: begin
                for (i = 0; i <= 3; i++) begin
                    temp1[i] = {1'b0, ra_rd_even[WORD * i : (WORD * (i + 1)) - 1]} + {1'b0, rb_rd_even[WORD * i : (WORD * (i + 1)) - 1]};
                    rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = {31'd0, temp1[i][0]};
                end
                regWr_en_even = 1;
           end
           SUBTRACT_FROM_EXTENDED: begin    //TODO

           end
           BORROW_GENERATE: begin
                for (i = 0; i <= 3; i++) begin
                    if($unsigned(rb_rd_even[WORD * i : (WORD * (i + 1)) - 1]) >= $unsigned(ra_rd_even[WORD * i : (WORD * (i + 1)) - 1]))
                        rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = 1;
                    else
                        rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = 0;
                end
                regWr_en_even = 1;
           end
           ADD_HALFWORD: begin
                for (i = 0; i <= 7; i++) begin
                    rt_wt_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1] = ra_rd_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1] + rb_rd_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1];
                end
                regWr_en_even = 1;
           end
           ADD_HALFWORD_IMMEDIATE: begin
                temp = {6{imm10[0]}, imm10};
                for (i = 0; i <= 7; i++) begin
                    rt_wt_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1] = ra_rd_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1] + rb_rd_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1];
                end
                regWr_en_even = 1;
           end
           SUBTRACT_FROM_HALFWORD: begin
                for (i = 0; i <= 7; i++) begin
                    rt_wt_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1] = rb_rd_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1] - ra_rd_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1];
                end
                regWr_en_even = 1;
           end
           SUBTRACT_FROM_HALFWORD_IMMEDIATE: begin
                temp = {6{imm10[0]}, imm10};
                for (i = 0; i <= 7; i++) begin
                    rt_wt_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1] = temp - ra_rd_even[HALFWORD * i : (HALFWORD * (i + 1)) - 1];
                end
                regWr_en_even = 1;
           end
           COUNT_LEADING_ZEROS: begin
                for(i = 0; i <= 7; i++) begin
                    temp = 0;
                    temp2 = ra_rd_even[WORD * i : (WORD * (i + 1)) - 1];
                    for(j = 0; j <= 31; j++) begin
                        if(temp2[j])
                            break;
                        else
                            temp = temp + 1;
                    end
                    rt_wt_even[WORD * i : (WORD * (i + 1)) - 1] = temp;
                end
                regWr_en_even = 1;
           end
           FORM_SELECT_MASK_FOR_HALFWORD: begin
                for (i = 0, k = 0; i <= 7; i++, k = k + 2) begin
                    if(ra_rd_even[3 * BYTE +: BYTE][i])
                        temp3[HALFWORD * k +: HALFWORD] = 16'd1;
                    else
                        temp3[HALFWORD * k +: HALFWORD] = 16'b0;
                end
                rt_wt_even = temp3;
                regWr_en_even = 1;
           end
           FORM_SELECT_MARK_FOR_WORDS: begin
                for (i = 0, k = 0; i <= 3; i++, k = k + 4) begin
                    if(ra_rd_even[28 : 31][i])
                        temp3[WORD * k +: WORD] = 32'd1;
                    else
                        temp3[WORD * k +: WORD] = 32'b0;
                end
                rt_wt_even = temp3;
                regWr_en_even = 1;
           end
           AND: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] & rb_rd_even[WORD * i +: WORD];
                end
                regWr_en_even = 1;
           end
           AND_WITH_COMPLEMENT: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] & ~rb_rd_even[WORD * i +: WORD];
                end
                regWr_en_even = 1;
           end
           AND_HALFWORD_IMMEDIATE: begin
                temp4 = {6{imm10[0]}, imm10};
                for (i = 0; i <= 7; i++) begin
                    rt_wt_even[HALFWORD * i +: HALFWORD] = ra_rd_even[HALFWORD * i +: HALFWORD] & temp4;
                end
                regWr_en_even = 1;
           end
           AND_WORD_IMMEDIATE: begin
                temp = {22{imm10[0]}, imm10};
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] & temp;
                end
                regWr_en_even = 1;
           end
           OR: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] | rb_rd_even[WORD * i +: WORD];
                end
                regWr_en_even = 1;
           end
           OR_WITH_COMPLEMENT: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] | ~rb_rd_even[WORD * i +: WORD];
                end
                regWr_en_even = 1;
           end
           OR_HALFWORD_IMMEDIATE: begin
                temp4 = {6{imm10[0]}, imm10};
                for (i = 0; i <= 7; i++) begin
                    rt_wt_even[HALFWORD * i +: HALFWORD] = ra_rd_even[HALFWORD * i +: HALFWORD] | temp4;
                end
                regWr_en_even = 1;
           end
           OR_WORD_IMMEDIATE: begin
                temp = {22{imm10[0]}, imm10};
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] | temp;
                end
                regWr_en_even = 1;
           end
           EXCLUSIVE_OR: begin
               for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] ^ rb_rd_even[WORD * i +: WORD];
                end
                regWr_en_even = 1;
           end
           EXCLUSIVE_OR_HALFWORD_IMMEDIATE: begin
               temp4 = {6{imm10[0]}, imm10};
                for (i = 0; i <= 7; i++) begin
                    rt_wt_even[HALFWORD * i +: HALFWORD] = ra_rd_even[HALFWORD * i +: HALFWORD] ^ temp4;
                end
                regWr_en_even = 1;
           end
           EXCLUSIVE_OR_WORD_IMMEDIATE: begin
               temp = {22{imm10[0]}, imm10};
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] ^ temp;
                end
                regWr_en_even = 1;
           end
           NAND: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ~(ra_rd_even[WORD * i +: WORD] & rb_rd_even[WORD * i +: WORD]);
                end
                regWr_en_even = 1;
           end
           NOR: begin
                for (i = 0; i <= 3; i++) begin
                    rt_wt_even[WORD * i +: WORD] = ~(ra_rd_even[WORD * i +: WORD] | rb_rd_even[WORD * i +: WORD]);
                end
                regWr_en_even = 1;
           end
           COMPARE_EQUAL_HALFWORD: begin
                for(i = 0; i <= 7; i++) begin
                    if(ra_rd_even[HALFWORD * i +: HALFWORD] = rb_rd_even[HALFWORD * i +: HALFWORD])
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd1;
                    else
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_EQUAL_HALFWORD_IMMEDIATE: begin
                temp4 = {6{imm10[0]}, imm10};
                for(i = 0; i <= 7; i++) begin
                    if(ra_rd_even[HALFWORD * i +: HALFWORD] = temp4)
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd1;
                    else
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_EQUAL_WORD: begin
                for(i = 0; i <= 3; i++) begin
                    if(ra_rd_even[WORD * i +: WORD] = rb_rd_even[WORD * i +: WORD])
                        rt_wt_even[WORD * i +: WORD] = 32'd1;
                    else
                        rt_wt_even[WORD * i +: WORD] = 32'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_EQUAL_WORD_IMMEDIATE: begin
                temp = {22{imm10[0]}, imm10};
                for(i = 0; i <= 3; i++) begin
                    if(ra_rd_even[WORD * i +: WORD] = temp)
                        rt_wt_even[WORD * i +: WORD] = 32'd1;
                    else
                        rt_wt_even[WORD * i +: WORD] = 32'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_GREATER_THAN_HALFWORD: begin
                for(i = 0; i <= 7; i++) begin
                    if(ra_rd_even[HALFWORD * i +: HALFWORD] > rb_rd_even[HALFWORD * i +: HALFWORD])
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd1;
                    else
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE: begin
                temp4 = {6{imm10[0]}, imm10};
                for(i = 0; i <= 7; i++) begin
                    if(ra_rd_even[HALFWORD * i +: HALFWORD] > temp4)
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd1;
                    else
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_GREATER_THAN_WORD: begin
                for(i = 0; i <= 3; i++) begin
                    if(ra_rd_even[WORD * i +: WORD] > rb_rd_even[WORD * i +: WORD])
                        rt_wt_even[WORD * i +: WORD] = 32'd1;
                    else
                        rt_wt_even[WORD * i +: WORD] = 32'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_GREATER_THAN_WORD_IMMEDIATE: begin
                temp = {22{imm10[0]}, imm10};
                for(i = 0; i <= 3; i++) begin
                    if(ra_rd_even[WORD * i +: WORD] > temp)
                        rt_wt_even[WORD * i +: WORD] = 32'd1;
                    else
                        rt_wt_even[WORD * i +: WORD] = 32'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_LOGICAL_GREATER_THAN_HALFWORD: begin
                for(i = 0; i <= 7; i++) begin
                    if($unsigned(ra_rd_even[HALFWORD * i +: HALFWORD]) > $unsigned(rb_rd_even[HALFWORD * i +: HALFWORD]))
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd1;
                    else
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE: begin
                temp4 = {6{imm10[0]}, imm10};
                for(i = 0; i <= 7; i++) begin
                    if($unsigned(ra_rd_even[HALFWORD * i +: HALFWORD]) > $unsigned(temp4))
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd1;
                    else
                        rt_wt_even[HALFWORD * i +: HALFWORD] = 16'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_LOGICAL_GREATER_THAN_WORD: begin
                for(i = 0; i <= 3; i++) begin
                    if($unsigned(ra_rd_even[WORD * i +: WORD]) > $unsigned(rb_rd_even[WORD * i +: WORD]))
                        rt_wt_even[WORD * i +: WORD] = 32'd1;
                    else
                        rt_wt_even[WORD * i +: WORD] = 32'd0;
                end
                regWr_en_even = 1;
           end
           COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE: begin
                temp = {22{imm10[0]}, imm10};
                for(i = 0; i <= 3; i++) begin
                    if($unsigned(ra_rd_even[WORD * i +: WORD]) > $unsigned(temp))
                        rt_wt_even[WORD * i +: WORD] = 32'd1;
                    else
                        rt_wt_even[WORD * i +: WORD] = 32'd0;
                end
                regWr_en_even = 1;
           end
           default: 
       endcase

       fx1_stage1_result = {unit_id, regWr_en_even, addr_rt_wt_even, rt_wt_even};
       
   end

endmodule