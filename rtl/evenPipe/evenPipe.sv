module evenPipe (
    unit_id,
    opcode,
    regWr_en_even,
    ra_rd_even,
    rb_rd_even,
    rt_wt_even,
    addr_rt_wt_even,
    imm10
);

    input [0 : UNIT_ID_SIZE - 1] unit_id;
    input [0 : INTERNAL_OPCODE_SIZE - 1] opcode;
    input signed [0 : QUADWORD - 1] ra_rd_even, rb_rd_even, rc_rd_even, rt_wt_even;

    input logic regWr_en_even;
    input logic [0 : REG_ADDR_WIDTH - 1] addr_rt_wt_even;
    input logic [0 : IMM10 - 1] imm10;
    input logic [0 : IMM7 - ] imm7;

    logic [0 : (UNIT_ID_SIZE + 1 + REG_ADDR_WIDTH + QUADWORD) - 1] fx1_stage1_result, fx2_stage1_result;
    logic [0 : HALFWORD - 1] temp4;
    logic [0 : WORD - 1] temp, temp2;
    logic [0 : WORD] temp1[3];          //carry generate instr requires additional 1 bit to place the carry bit. (other instr that require this also uses temp1)
    logic [0 : QUADWORD - 1] temp3;
    logic [0 : HALFWORD - 1] s, t, r;   //temporary registers notations are followed as per IBM's Synergistic Processing Unit (SPU) ISA description maual for better clarity
    logic [0 : BYTE - 1] b, c;

    shortreal fp_temp;



   always_comb begin : evenPipeExecution  
       case (opcode)
            //SimpleFixed_1_Unit
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

            //SimpleFixed_2_Unit
            SHIFT_LEFT_HALFWORD: begin
                    for(i = 0; i <= 7; i++) begin
                        s = rb_rd_even[HALFWORD * i +: HALFWORD] & 16'h001F;
                        t = ra_rd_even[HALFWORD * i +: HALFWORD];
                        for(j = 0; j < HALFWORD; j++) begin
                            if((j + s) < HALFWORD)
                                r[j] = t[j + s];     //if shift value specified by register RB is 4, it means the nth bit in register RA gets the (n + 4)th bit's value which is basically shifting left
                            else
                                r[j] = 0;       //the end bits don't any value on their right to shift from, so they are padded with zeros.
                        end
                        rt_wt_even[HALFWORD * i +: HALFWORD] = r;
                    end
                    regWr_en_even = 1
                end
                SHIFT_LEFT_WORD_IMMEDIATE: begin
                    if(imm7[2 : 6] <= 15) begin
                        for (i = 0; i <= 7; i++) begin
                            rt_wt_even[HALFWORD * i +: HALFWORD] = ra_rd_even[HALFWORD * i +: HALFWORD] << imm7[2 : 6];         //behavioural description of system verilog
                        end
                    end
                    else begin
                        rt_wt_even = 0;                         
                    end
                    regWr_en_even = 1;
                end
                SHIFT_LEFT_WORD: begin
                    for (i = 0; i <= 3; i++) begin
                            if(rb_rd_even[(WORD * i) + 26 +: 6] <= 31)        //bits 26 to 31 of each of the four word slots of the 128-bit register RB
                                rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] << imm7[2 : 6];
                            else
                                rt_wt_even[WORD * i +: WORD] = 0;
                    end
                    regWr_en_even = 1;
                end
                SHIFT_LEFT_WORD_IMMEDIATE: begin
                    if(imm7[1 : 6] <= 31) begin
                        for (i = 0; i <= 3; i++) begin
                            rt_wt_even[WORD * i +: WORD] = ra_rd_even[WORD * i +: WORD] << imm7[1 : 6];
                        end
                    end
                    else begin
                        rt_wt_even = 0; 
                    end
                    regWr_en_even = 1;
                end
                ROTATE_HALFWORD: begin
                    for (i = 0; i <= 7; i++) begin
                        s = rb_rd_even[HALFWORD * i +: HALFWORD] & 16'h000F;
                        t = ra_rd_even[HALFWORD * i +: HALFWORD];
                        for (j = 0; j <= 15; j++) begin
                            if([j + s] < 16)
                                r[j] = t[j + s];
                            else
                                r[j] = t[j + s -16]
                        end
                        rt_wt_even[HALFWORD * i +: HALFWORD];
                    end
                    regWr_en_even = 1;
                end
                ROTATE_HALFWORD_IMMEDIATE: begin
                    s = {9{imm7[0]}, imm7} & 16'h000F;
                    for (i = 0; i <= 7; i++) begin
                        t = ra_rd_even[HALFWORD * i +: HALFWORD];
                        for (j = 0; j <= 15; j++) begin
                            if([j + s] < 16)
                                r[j] = t[j + s];
                            else
                                r[j] = t[j + s - 16]
                        end
                        rt_wt_even[HALFWORD * i +: HALFWORD];
                    end
                    regWr_en_even = 1;
                end
                ROTATE_WORD: begin
                    for (i = 0; i <= 3; i++) begin
                        s = rb_rd_even[WORD * i +: WORD] & 32'h0000001F;
                        t = ra_rd_even[WORD * i +: WORD];
                        for (j = 0; j <= 31; j++) begin
                            if([j + s] < 32)
                                r[j] = t[j + s];
                            else
                                r[j] = t[j + s - 32]
                        end
                        rt_wt_even[WORD * i +: WORD];
                    end
                    regWr_en_even = 1;
                end
                ROTATE_WORD_IMMEDIATE: begin
                    s = {25{imm7[0]}, imm7} & 32'h0000001F;
                    for (i = 0; i <= 3; i++) begin
                        t = ra_rd_even[WORD * i +: WORD];
                        for (j = 0; j <= 31; j++) begin
                            if([j + s] < 32)
                                r[j] = t[j + s];
                            else
                                r[j] = t[j + s - 32]
                        end
                        rt_wt_even[WORD * i +: WORD];
                    end
                    regWr_en_even = 1;
                end

                //Byte Unit
                COUNT_ONES_IN_BYTES: begin
                    for (i = 0; i <= 15; i++) begin
                        c = 0;
                        b = ra_rd_even[BYTE * i +: BYTE];
                        for (j = 0; j <= 7; j++) begin
                            if(b[j] == 1)
                                c = c + 1;
                        end
                        rt_wt_even[BYTE * i +: BYTE];
                    end
                    regWr_en_even = 1;
                end
                ABSOLUTE_DIFFERENCES_OF_BYTES: begin
                    for (i = 0; i <= 15; i++) begin
                        if($unsigned(ra_rd_even) > $unsigned[rb_rd_even])
                            rt_wt_even[BYTE * i +: BYTE] = rb_rd_even[BYTE * i +: BYTE] - ra_rd_even[BYTE * i +: BYTE];
                        else
                            rt_wt_even[BYTE * i +: BYTE] = ra_rd_even[BYTE * i +: BYTE] - rb_rd_even[BYTE * i +: BYTE];
                    end
                    regWr_en_even = 1;
                end
                AVERAGE_BYTES: begin
                    for (i = 0; i <= 15; i++) begin
                        rt_wt_even[BYTE * i +: BYTE] = ((({8'h0, ra_rd_even[BYTE * i +: BYTE]} + {8'h0, rb_rd_even[BYTE * i +: BYTE]}) + 1)[7 : 14]);
                    end
                    regWr_en_even = 1;
                end
                SUM_BYTES_INTO_HALFWORD: begin
                    for (i = 0; i <= 6; i = i + 2) begin
                        rt_wt_even[HALFWORD * i * 2 +: HALFWORD] = rb_rd_even[BYTE * i * 2 +: BYTE] + rb_rd_even[(BYTE * i * 2) + 1 +: BYTE] + rb_rd_even[(BYTE * i * 2) + 2 +: BYTE] + rb_rd_even[(BYTE * i * 2) + 3 +: BYTE];
                        rt_wt_even[HALFWORD * (i + 1) * 2 +: HALFWORD] = ra_rd_even[BYTE * i * 2 +: BYTE] + ra_rd_even[(BYTE * i * 2) + 1 +: BYTE] + ra_rd_even[(BYTE * i * 2) + 2 +: BYTE] + ra_rd_even[(BYTE * i * 2) + 3 +: BYTE];
                    end
                    regWr_en_even = 1;
                end

                //Single Precision Floating Point Unit
                FLOATING_ADD: begin
                    for (i = 0; i <= 3; i++) begin
                        fp_temp = $bitstoshortreal(ra_rd_even[WORD * i +: WORD]) + $bitstoshortreal(rb_rd_even[WORD * i +: WORD]);
                        if(fp_temp < - Smax)
                            rt_wt_even[WORD * i +: WORD] = -$shortrealtobits(Smax);
                        else if(fp_temp > Smax)
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(Smax);
                        else if(fp_temp < Smin)
                            rt_wt_even[WORD * i +: WORD] = 0;
                        else
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(fp_temp);
                    end
                    regWr_en_even = 1;
                end
                FLOATING_SUBTRACT: begin
                    for (i = 0; i <= 3; i++) begin
                        fp_temp = $bitstoshortreal(ra_rd_even[WORD * i +: WORD]) - $bitstoshortreal(rb_rd_even[WORD * i +: WORD]);
                        if(fp_temp < - Smax)
                            rt_wt_even[WORD * i +: WORD] = -$shortrealtobits(Smax);
                        else if(fp_temp > Smax)
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(Smax);
                        else if(fp_temp < Smin)
                            rt_wt_even[WORD * i +: WORD] = 0;
                        else
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(fp_temp);
                    end
                    regWr_en_even = 1;
                end
                FLOATING_MULTIPLY_AND_ADD: begin
                    for (i = 0; i <= 3; i++) begin
                        fp_temp = $bitstoshortreal(ra_rd_even[WORD * i +: WORD]) * $bitstoshortreal(rb_rd_even[WORD * i +: WORD]) + $bitstoshortreal(rc_rd_even[WORD * i +: WORD]);
                        if(fp_temp < - Smax)
                            rt_wt_even[WORD * i +: WORD] = -$shortrealtobits(Smax);
                        else if(fp_temp > Smax)
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(Smax);
                        else if(fp_temp < Smin)
                            rt_wt_even[WORD * i +: WORD] = 0;
                        else
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(fp_temp);
                    end
                    regWr_en_even = 1;
                end
                FLOATING_NEGATIVE_MULTIPLY_AND_SUBSTRACT: begin
                    for (i = 0; i <= 3; i++) begin
                        fp_temp = $bitstoshortreal(rc_rd_even[WORD * i +: WORD]) - ($bitstoshortreal(ra_rd_even[WORD * i +: WORD]) * $bitstoshortreal(rb_rd_even[WORD * i +: WORD]));
                        if(fp_temp < - Smax)
                            rt_wt_even[WORD * i +: WORD] = -$shortrealtobits(Smax);
                        else if(fp_temp > Smax)
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(Smax);
                        else if(fp_temp < Smin)
                            rt_wt_even[WORD * i +: WORD] = 0;
                        else
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(fp_temp);
                    end
                    regWr_en_even = 1;
                end
                FLOATING_MULTIPLY_AND_SUBTRACT: begin
                    for (i = 0; i <= 3; i++) begin
                        fp_temp = $bitstoshortreal(ra_rd_even[WORD * i +: WORD]) * $bitstoshortreal(rb_rd_even[WORD * i +: WORD]) - $bitstoshortreal(rc_rd_even[WORD * i +: WORD]);
                        if(fp_temp < - Smax)
                            rt_wt_even[WORD * i +: WORD] = -$shortrealtobits(Smax);
                        else if(fp_temp > Smax)
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(Smax);
                        else if(fp_temp < Smin)
                            rt_wt_even[WORD * i +: WORD] = 0;
                        else
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(fp_temp);
                    end
                    regWr_en_even = 1;
                end
                FLAOTING_MULTIPLY: begin
                    for (i = 0; i <= 3; i++) begin
                        fp_temp = $bitstoshortreal(ra_rd_even[WORD * i +: WORD]) * $bitstoshortreal(rb_rd_even[WORD * i +: WORD]);
                        if(fp_temp < - Smax)
                            rt_wt_even[WORD * i +: WORD] = -$shortrealtobits(Smax);
                        else if(fp_temp > Smax)
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(Smax);
                        else if(fp_temp < Smin)
                            rt_wt_even[WORD * i +: WORD] = 0;
                        else
                            rt_wt_even[WORD * i +: WORD] = $shortrealtobits(fp_temp);
                    end
                    regWr_en_even = 1;
                end

                //Single Precision Interger Unit
                MULTIPLY: begin
                    for (i = 0; i <= 3; i++) begin
                        rt_wt_even[WORD * i +: WORD] = ra_rd_even[(WORD * i) + HALFWORD +: HALFWORD] * rb_rd_even[(WORD * i) + HALFWORD +: HALFWORD];
                    end
                    regWr_en_even = 1;
                end
                MULTIPLY_UNSIGNED: begin
                    for (i = 0; i <= 3; i++) begin
                        rt_wt_even[WORD * i +: WORD] = $unsigned(ra_rd_even[(WORD * i) + HALFWORD +: HALFWORD]) * $unsigned(rb_rd_even[(WORD * i) + HALFWORD +: HALFWORD]);
                    end
                    regWr_en_even = 1;
                end
                MULTIPLY_IMMEDIATE: begin
                    t = {6{imm10[0]}, imm10};
                    for (i = 0; i <= 3; i++) begin
                        rt_wt_even[WORD * i +: WORD] = ra_rd_even[(WORD * i) + HALFWORD +: HALFWORD] * t;
                    end
                    regWr_en_even = 1;
                end
                MULTIPLY_UNSIGNED_IMMEDIATE: begin
                    t = {6{imm10[0]}, imm10};
                    for (i = 0; i <= 3; i++) begin
                        rt_wt_even[WORD * i +: WORD] = $unsigned(ra_rd_even[(WORD * i) + HALFWORD +: HALFWORD]) * $unsigned(t);
                    end
                    regWr_en_even = 1;
                end
                MULTIPLY_AND_ADD: begin
                    for (i = 0; i <= 3; i++) begin
                        rt_wt_even[WORD * i +: WORD] = ra_rd_even[(WORD * i) + HALFWORD +: HALFWORD] * rb_rd_even[(WORD * i) + HALFWORD +: HALFWORD] + rc_rd_even[WORD * i +: WORD];
                    end
                end
            default: 
       endcase

       fx1_stage1_result = {unit_id, regWr_en_even, addr_rt_wt_even, rt_wt_even};
       
   end

endmodule