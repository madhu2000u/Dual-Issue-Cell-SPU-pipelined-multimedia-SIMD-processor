`include "../rtl/constants.sv"
// `include "../rtl/spuMainModule.sv"
module spuTb ();
    
    logic                                   clk, reset;
    logic                                   br_first_instr;    //This signal sent by decode stage indicates to the execution stage if the first instruction of the dual-fetch (in order) is branch or not. If branch is taken (which will be found out later in the execution stages in oddPipe, it has to flush off the following instruction that was issued into the even pipe since it is the wrong instruction after branch is taken)
    logic [0 : UNIT_ID_SIZE - 1]            unit_id_even, unit_id_odd;
    logic [0 : INTERNAL_OPCODE_SIZE - 1]    opcode_even, opcode_odd;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_ra_rd_even, addr_rb_rd_even, addr_rc_rd_even, addr_ra_rd_odd, addr_rb_rd_odd, addr_rc_rd_odd;
    logic [0 : IMM7 - 1]                    imm7_even, imm7_odd;
    logic [0 : IMM10 - 1]                   imm10_even, imm10_odd;
    logic [0 : IMM16 - 1]                   imm16_odd;
    logic [0 : IMM18 - 1]                   imm18_odd;
    logic [0 : REG_ADDR_WIDTH - 1]          addr_rt_wt_even, addr_rt_wt_odd;
    logic [0 : QUADWORD - 1]                rt_wt_even, rt_wt_odd;
    logic                                   regWr_en_even, regWr_en_odd;
    logic [0:QUADWORD-1]                    ra_rd_even, rb_rd_even, rc_rd_even, ra_rd_odd, rb_rd_odd;
    logic [0 : WORD - 1]                    PC, PC_out;
    logic                                   branch_taken;
    logic init, init2;
    
    initial clk = 0;
    always #5 clk = ~clk;

    spuMainModule dut(clk,
    reset,
    // unit_id_even,
    // unit_id_odd,
    // opcode_even,
    // opcode_even,
    // opcode_even,
    // opcode_odd,
    /*regWr_en_even,*/
    // addr_ra_rd_even,
    // addr_rb_rd_even,
    // addr_rc_rd_even,
    // addr_rt_wt_even,
    // addr_ra_rd_odd,
    // addr_rb_rd_odd,
    // addr_rc_rd_odd,
    // addr_rt_wt_odd,
    // imm7_even,
    // imm7_odd,
    // imm10_even,
    // imm10_odd,
    // imm16_odd,
    // imm18_odd,
    PC_out,
    branch_taken,
    br_first_instr,
    init,
    init2);

    initial begin
        reset = 1;
        @(posedge clk);
        reset = 0;
        repeat(100) begin
            @(posedge clk);
        end
        $stop;
    end


    // int even_q[$], odd_q[$];

    // initial begin
    //     reset = 1;
    //     PC = 0;
    //     @(posedge clk);
    //     reset = 0;
    //     unit_id = 1;
    //     opcode_even = ADD_WORD_IMMEDIATE;
    //     addr_ra_rd_even = 0;
    //     addr_rt_wt_even = 7'd1;
    //     imm10_even = -10'd5;
    //     // @(posedge clk);
    //     // opcode_even = ADD_WORD_IMMEDIATE;
    //     // addr_ra_rd_even = 1;
    //     // addr_rt_wt_even = 7'd2;
    //     // imm10_even = 10'd3;
    //     @(posedge clk);
    //     repeat(9) begin
    //         opcode_even = NOP;
    //         unit_id = 0;
    //         addr_rt_wt_even = 0;
    //         @(posedge clk);
    //     end
    // end
    //     opcode_even = ADD_WORD_IMMEDIATE;
    //     addr_ra_rd_even = 1;
    //     addr_rt_wt_even = 7'd2;
    //     imm10_even = -10'd4;
    //     @(posedge clk);
    //     repeat(3) begin
    //         opcode_even = NOP;
    //         unit_id = 0;
    //         addr_rt_wt_even = 0;
    //         @(posedge clk);
    //     end
    //     opcode_even = SUBTRACT_FROM_WORD;
    //     addr_ra_rd_even = 2;
    //     addr_rb_rd_even = 1;
    //     addr_rt_wt_even = 7'd3;
    //     @(posedge clk);
    //     opcode_even = NOP;
    //     unit_id = 0;
    //     addr_rt_wt_even = 0;
    //     repeat(9) begin
    //         @(posedge clk);
    //     end
    //     opcode_even = NOP;
    //     unit_id = 0;
    //     addr_rt_wt_even = 0;

    //     opcode_odd = STORE_QUADWORD_D;
    //     imm10_odd = 10;
    //     addr_ra_rd_odd = 2;
    //     addr_rc_rd_odd = 3;
    //     @(posedge clk);
    //     opcode_odd = STORE_QUADWORD_X;
    //     addr_ra_rd_odd = 2;
    //     addr_rb_rd_odd = 3;
    //     addr_rc_rd_odd = 1; 
    //     @(posedge clk);
    //     opcode_odd = STORE_QUADWORD_A;
    //     imm16_odd = 10;
    //     addr_rc_rd_odd = 2;
    //     @(posedge clk);
    //     // repeat(5) begin
    //     //     @(posedge clk);
    //     // end
    //     opcode_odd = LOAD_QUADWORD_D;
    //     imm10_odd = 10;
    //     addr_ra_rd_odd = 2;
    //     addr_rt_wt_odd = 5;
    //     @(posedge clk);
    //     opcode_odd = LNOP; addr_rt_wt_odd = 0;
    //     repeat(3) begin
    //         @(posedge clk);
    //     end

    //     //Even to even fw
    //     opcode_even = ADD_WORD; unit_id = 1; addr_ra_rd_even = 3; addr_rb_rd_even = 2; addr_rt_wt_even = 2; opcode_odd = LNOP; addr_ra_rd_odd = 2; addr_rt_wt_odd = 12; imm7_odd = 2;
    //     @(posedge clk);        
    //     repeat(3) begin
    //         opcode_even = NOP;
    //         unit_id = 0;
    //         addr_rt_wt_even = 0;
    //         addr_ra_rd_even = 0; addr_rb_rd_even = 0;
    //         @(posedge clk);
    //     end
    //     opcode_even = COMPARE_EQUAL_WORD; unit_id = 1; addr_ra_rd_even = 1; addr_rb_rd_even = 2; addr_rt_wt_even = 0; opcode_odd = LNOP; addr_ra_rd_odd = 2; addr_rt_wt_odd = 12; imm7_odd = 2;
    //     @(posedge clk);
    //     repeat(9) begin
    //         opcode_even = NOP;
    //         unit_id = 0;
    //         addr_rt_wt_even = 0;
    //         @(posedge clk);
    //     end

    //     //Even to odd fw
    //     opcode_even = ADD_WORD; unit_id = 1; addr_ra_rd_even = 3; addr_rb_rd_even = 2; addr_rt_wt_even = 2; opcode_odd = LNOP; addr_ra_rd_odd = 2; addr_rt_wt_odd = 12; imm7_odd = 2;
    //     @(posedge clk);        
    //     repeat(3) begin
    //         opcode_even = NOP;
    //         unit_id = 0;
    //         addr_rt_wt_even = 0;
    //         addr_ra_rd_even = 0; addr_rb_rd_even = 0;
    //         @(posedge clk);
    //     end
    //     opcode_odd = SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE; unit_id = 1;  addr_ra_rd_even = 0; addr_rb_rd_even = 0; addr_rt_wt_even = 0; opcode_even = NOP; addr_ra_rd_odd = 2; addr_rt_wt_odd = 3; imm7_odd = 2;
    //     @(posedge clk);
    //     repeat(9) begin
    //         opcode_odd = LNOP;
    //         unit_id = 0;
    //         addr_rt_wt_even = 0;
    //         @(posedge clk);
    //     end
        
        

    //     //Odd to Even fw test
    //     opcode_even = NOP; unit_id = 0; addr_rt_wt_even = 0; opcode_odd = ROTATE_QUADWORD_BY_BYTES_IMMEDIATE; addr_ra_rd_odd = 2; addr_rt_wt_odd = 12; imm7_odd = 2;
    //     @(posedge clk);
    //     opcode_odd = LNOP; unit_id = 0; addr_rt_wt_odd = 0;
    //     repeat(3) begin
    //         @(posedge clk);
    //     end
    //     opcode_even = SHIFT_LEFT_WORD; addr_ra_rd_even = 12; addr_rb_rd_even = 1; addr_rt_wt_even = 10;
    //     @(posedge clk);
    //     repeat(9) begin
    //         opcode_even = NOP;
    //         unit_id = 0;
    //         addr_rt_wt_even = 0;
    //         @(posedge clk);
    //     end
        

    //     //odd to odd fw
    //     opcode_even = NOP; unit_id = 0; addr_rt_wt_even = 0;
    //     opcode_odd = LOAD_QUADWORD_X; addr_ra_rd_odd = 2; addr_rb_rd_odd = 3; addr_rt_wt_odd = 11;
    //     @(posedge clk);
    //     repeat(6) begin
    //         opcode_odd = LNOP;
    //         unit_id = 0;
    //         addr_rt_wt_odd = 0;
    //         @(posedge clk);
    //     end
    //     opcode_odd = SHIFT_LEFT_QUADWORD_BY_BITS_IMMEDIATE; addr_ra_rd_odd = 11; addr_rt_wt_odd = 0; unit_id = 5; imm7_odd = 4;
    //     @(posedge clk);
    //     repeat(9) begin
    //         opcode_odd = LNOP;
    //         unit_id = 0;
    //         addr_rt_wt_odd = 0;
    //         @(posedge clk);
    //     end


    //     // //odd to even fw
    //     // opcode_even = NOP; unit_id = 0; addr_rt_wt_even = 0;
    //     // opcode_odd = SHIFT_LEFT_QUADWORD_BY_BITS; addr_ra_rd_odd = 11; addr_rt_wt_odd = 12; unit_id = 5; imm7_odd = 4;
    //     // @(posedge clk);
    //     // repeat(4) begin
    //     //     opcode_odd = LNOP;
    //     //     unit_id = 0;
    //     //     addr_rt_wt_odd = 0;
    //     //     @(posedge clk);
    //     // end
    //     // opcode_even = FLOATING_ADD; addr_ra_rd_even = 12; addr_rb_rd_even = 5; addr_rt_wt_even = 13;
    //     // @(posedge clk);
    //     // repeat(9) begin
    //     //     opcode_even = NOP; unit_id = 0; addr_ra_rd_even = 0; addr_rb_rd_even = 5;addr_rt_wt_even = 0;
    //     //     opcode_odd = LNOP;
    //     //     unit_id = 0;
    //     //     addr_rt_wt_odd = 0;
    //     //     @(posedge clk);
    //     // end

    //     //Flush Test
    //     opcode_odd = BRANCH_RELATIVE_AND_SET_LINK; addr_rc_rd_odd = 0; br_first_instr = 1;
    //     opcode_even = MULTIPLY_AND_ADD; addr_ra_rd_even = 1; addr_rb_rd_even = 2; addr_rc_rd_even = 5; addr_rt_wt_even = 6;
    //     @(posedge clk)
    //     repeat(9) begin
    //         opcode_even = NOP; unit_id = 0; addr_ra_rd_even = 0; addr_rb_rd_even = 5;addr_rt_wt_even = 0;
    //         opcode_odd = LNOP;
    //         unit_id = 0;
    //         addr_rt_wt_odd = 0;
    //         @(posedge clk);
    //     end

    //     //load random values to registerfile
    //     for(int i = 0; i < 128; i++) begin
    //         unit_id = 1;
    //         opcode_even = ADD_WORD_IMMEDIATE;
    //         addr_ra_rd_even = 127;
    //         addr_rt_wt_even = i;
    //         imm10_even = $random;
    //         @(posedge clk);
    //     end
        
    //     repeat(16) begin
    //         opcode_even = NOP; unit_id = 0; addr_ra_rd_even = 0; addr_rb_rd_even = 5;addr_rt_wt_even = 0;
    //         opcode_odd = LNOP;
    //         unit_id = 0;
    //         addr_rt_wt_odd = 0;
    //         @(posedge clk);
    //     end


    //     //Start test
        
    //     for(int i = 1; i <= 48; i++)begin
    //             even_q.push_back(i);
    //     end
    //     for(int i = 66; i <= 69; i++)begin
    //             even_q.push_back(i);
    //     end
    //     even_q.push_back(90);
    //     even_q.push_back(91);
    //    for(int i = 57; i <= 60; i++)begin
    //             even_q.push_back(i);
    //     end
    //     for(int i = 61; i <= 65; i++)begin
    //             even_q.push_back(i);
    //     end

    //     for(int i = 70; i <= 89; i++)begin
    //             odd_q.push_back(i);
    //     end
    //     for(int i = 94; i <= 96; i++)begin
    //             odd_q.push_back(i);
    //     end
    //     even_q.push_back(92);
    //     odd_q.push_back(93);
    //     for(int i = 49; i <= 56; i++)begin
    //             odd_q.push_back(i);
    //     end

    //     for(int i = 0; even_q.size() > 0; i++) begin
    //         opcode_even = even_q.pop_front(); addr_ra_rd_even = i; addr_rb_rd_even = i + 1; addr_rc_rd_even = i + 2; addr_rt_wt_even = i + 3;
    //         opcode_odd = odd_q.pop_front(); addr_ra_rd_odd = i; addr_rb_rd_odd = i + 1; addr_rc_rd_odd = i + 2; addr_rt_wt_odd = i + 4;
    //         imm7_even = $random;
    //         imm10_even = $random;
    //         imm7_odd = $random;
    //         imm10_odd = $random;
    //         imm16_odd = $random;
    //         imm18_odd = $random;
    //         @(posedge clk);
    //     end


    //     $finish;
    // end

    
endmodule